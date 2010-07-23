/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.text.ParseException;
import java.util.Date;
import java.util.UUID;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Schedule;
import nl.b3p.datastorelinker.entity.ScheduleType;
import nl.b3p.datastorelinker.util.DataStoreLinkJob;
import nl.b3p.datastorelinker.util.DefaultErrorResolution;
import nl.b3p.datastorelinker.util.MarshalUtils;
import nl.b3p.datastorelinker.util.SchedulerUtils;
import org.apache.commons.lang.StringUtils;
import org.hibernate.Session;
import org.quartz.CronTrigger;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;

/**
 *
 * @author Erik van de Pol
 */
public class PeriodicalProcessAction extends DefaultAction {
    private final static Log log = Log.getInstance(PeriodicalProcessAction.class);

    protected final static String EXECUTE_PERIODICALLY_JSP = "/pages/main/cron/executePeriodically.jsp";
    protected final static String LIST_JSP = "/pages/main/process/list.jsp";

    // cron expression sequence:
    protected final static int SECONDS = 0;
    protected final static int MINUTES = 1;
    protected final static int HOURS = 2;
    protected final static int DAY_OF_MONTH = 3;
    protected final static int MONTH = 4;
    protected final static int DAY_OF_WEEK = 5;
    protected final static int YEAR = 6;

    // parsed time string sequence:
    protected final static int PARSE_HOURS = 0;
    protected final static int PARSE_MINUTES = 1;

    protected Long selectedProcessId;

    protected Integer cronType;
    protected Date fromDate;

    protected Integer onMinute;
    protected String onTime;
    protected Integer onDayOfTheWeek;
    protected Integer onDayOfTheMonth;
    protected Integer onMonth;
    
    //protected Boolean onLastDayOfTheMonth;

    // advanced
    protected String cronExpression;

    @Transactional
    public Resolution executePeriodically() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        Schedule schedule = process.getSchedule();

        if (schedule != null) {
            cronType = schedule.getScheduleType().getId();
            cronExpression = schedule.getCronExpression();
            fromDate = schedule.getFromDate();

            if (cronType != 6/*!.equals("advanced")*/)
                decodeCronExpression(cronExpression);
        }

        return new ForwardResolution(EXECUTE_PERIODICALLY_JSP);
    }

    @Transactional
    public Resolution executePeriodicallyComplete() {
        log.debug("Periodically executing process with id: " + selectedProcessId);

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        Schedule schedule = null;
        if (process.getSchedule() != null)
            schedule = process.getSchedule();
        else
            schedule = new Schedule();
        schedule.setFromDate(fromDate);
        schedule.setScheduleType((ScheduleType)session.get(ScheduleType.class, cronType));

        try {
            String processString = MarshalUtils.marshalProcess(process);
            //log.debug(processString);

            String uuid = UUID.randomUUID().toString();

            String jobName = "job" + uuid;
            JobDetail jobDetail = new JobDetail(jobName, DataStoreLinkJob.class);
            jobDetail.getJobDataMap().put("process", processString);

            String triggerName = "trig" + uuid;
            
            String cronExpressionString = null;
            if (cronType == 6/*.equals("advanced")*/) {
                if (cronExpression != null) // advanced option
                    cronExpressionString = cronExpression;
                else 
                    throw new Exception("Expected advanced cron expression; not found.");
            }
            else {
                cronExpressionString = createCronExpression();
            }

            // Quartz scheduler:
            log.debug("fromDate:" + fromDate);// fromDate kan null zijn
            // Als fromDate == null dan automatisch fromDate == NOW
            //TODO: time-zone mee geven aan trigger. Nodig als server in een andere timezone staat.
            Trigger trigger = new CronTrigger(triggerName, null, jobName, null, fromDate, null, cronExpressionString);

            Scheduler scheduler = SchedulerUtils.getScheduler(getContext().getServletContext());
            scheduler.scheduleJob(jobDetail, trigger);

            // Eigen schedule bijhouden:
            schedule.setCronExpression(cronExpressionString);
            schedule.setJobName(jobName);
            if (process.getSchedule() == null)
                session.save(schedule);
            process.setSchedule(schedule);

            return new ForwardResolution(nl.b3p.datastorelinker.gui.stripes.ProcessAction.class, "list");
        } catch(ParseException pe) {
            return new DefaultErrorResolution(
                    "Verkeerde of niet ondersteunde Cron expressie: " +
                    pe.getLocalizedMessage() +
                    "\n\nBekijk de Cron expressie handleiding voor uitleg over Cron expressies.");
        } catch(Exception e) {
            log.error(e);
            return new DefaultErrorResolution(e.getLocalizedMessage());
        }
    }

    @Transactional
    public Resolution cancelExecutePeriodically() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        Schedule schedule = process.getSchedule();
        if (schedule != null) {
            try {
                // try to unschedule from Quartz
                Scheduler scheduler = SchedulerUtils.getScheduler(getContext().getServletContext());
                scheduler.deleteJob(schedule.getJobName(), null);

                // if success, we remove the schedule from our own tables
                session.delete(process.getSchedule());
                process.setSchedule(null);
            } catch (SchedulerException ex) {
                log.error(ex);
            }
        }
        
        return new ForwardResolution(nl.b3p.datastorelinker.gui.stripes.ProcessAction.class, "list");
    }

    // only use this method for non-advanced cron expressions created by createCronExpression() !
    // assumes defaults as in createCronExpression();
    protected void decodeCronExpression(String cronExpressionToDecode) {
        String[] cronArray = cronExpressionToDecode.split(" ");

        /*if (!cronArray[MONTH].equals("*"))
            cronType = 5;//"year";
        else if (!cronArray[DAY_OF_MONTH].equals("*") && !cronArray[DAY_OF_MONTH].equals("?"))
            cronType = 4;//"month";
        else if (!cronArray[DAY_OF_WEEK].equals("*") && !cronArray[DAY_OF_WEEK].equals("?"))
            cronType = 3;//"week";
        else if (!cronArray[HOURS].equals("*"))
            cronType = 2;//"day";
        else
            cronType = 1;//"hour";*/

        try {
            if (cronType == 5)//.equals("year"))
                onMonth = Integer.valueOf(cronArray[MONTH]);
            if (cronType == 5/*.equals("year")*/ || cronType == 4/*.equals("month")*/) {
                try {
                    onDayOfTheMonth = Integer.valueOf(cronArray[DAY_OF_MONTH]);
                } catch(NumberFormatException nfe) { onDayOfTheMonth = null; } // last day of the month
            }
            if (cronType == 3/*.equals("week")*/)
                onDayOfTheWeek = Integer.valueOf(cronArray[DAY_OF_WEEK]);

            Integer minutes = Integer.valueOf(cronArray[MINUTES]);
            if (cronType == 1/*.equals("hour")*/)
                onMinute = minutes;
            else {
                Integer hours = Integer.valueOf(cronArray[HOURS]);
                String minutesStr = minutes < 10 ? "0" + minutes : minutes.toString();
                String hoursStr = hours < 10 ? "0" + hours : hours.toString();
                onTime = hoursStr + ":" + minutesStr;
            }
        } catch(NumberFormatException nfe) {
            log.error("Error decoding cron expression from dsl DB.", nfe);
        }
    }

    protected String createCronExpression() {
        Object[] cronArgs = new Object[7];
        //defaults:
        cronArgs[SECONDS] = "0";
        cronArgs[MINUTES] = "*";
        cronArgs[HOURS] = "*";
        cronArgs[DAY_OF_MONTH] = "*";
        cronArgs[MONTH] = "*";
        cronArgs[DAY_OF_WEEK] = "?";
        cronArgs[YEAR] = "*";

        if (onMinute != null)
            cronArgs[MINUTES] = onMinute;

        int[] parsedTime = parseTime();
        if (parsedTime != null) {
            cronArgs[MINUTES] = parsedTime[PARSE_MINUTES];
            cronArgs[HOURS] = parsedTime[PARSE_HOURS];
        }

        if (onDayOfTheMonth != null) {
            cronArgs[DAY_OF_WEEK] = "?"; // Quartz 1.8.3: Support for specifying both a day-of-week AND a day-of-month parameter is not implemented.
            cronArgs[DAY_OF_MONTH] = onDayOfTheMonth;
        } else if (cronType == 4/*.equals("month")*/ || cronType == 5/*.equals("year")*/) {
            cronArgs[DAY_OF_WEEK] = "?"; // Quartz 1.8.3: Support for specifying both a day-of-week AND a day-of-month parameter is not implemented.
            cronArgs[DAY_OF_MONTH] = "L"; // last day of the month
        }

        if (onMonth != null)
            cronArgs[MONTH] = onMonth;

        if (onDayOfTheWeek != null) {
            cronArgs[DAY_OF_WEEK] = onDayOfTheWeek;
            cronArgs[DAY_OF_MONTH] = "?"; // Quartz 1.8.3: Support for specifying both a day-of-week AND a day-of-month parameter is not implemented.
        }

        String cronExpressionString = StringUtils.join(cronArgs, " ");
        log.debug("cronExpression: " + cronExpressionString);

        return cronExpressionString;
    }

    protected int[] parseTime() {
        if (onTime == null || onTime.length() != 5)
            return null;

        int[] parsedTime = new int[2];

        String[] splitTime = onTime.split(":");
        try {
            parsedTime[PARSE_HOURS] = Integer.parseInt(splitTime[PARSE_HOURS]);
            parsedTime[PARSE_MINUTES] = Integer.parseInt(splitTime[PARSE_MINUTES]);
        } catch(NumberFormatException nfe) {
            log.error("Ongeldige tijd geprobeerd te parsen. Tijd: " + onTime != null ? onTime : "null", nfe);
            return null;
        }

        return parsedTime;
    }

    public Resolution executePeriodicallyCompleteAdvanced() {
        return new ForwardResolution(EXECUTE_PERIODICALLY_JSP);
    }

    public String getCronExpression() {
        return cronExpression;
    }

    public void setCronExpression(String cronExpression) {
        this.cronExpression = cronExpression;
    }

    public Integer getOnDayOfTheMonth() {
        return onDayOfTheMonth;
    }

    public void setOnDayOfTheMonth(Integer onDayOfTheMonth) {
        this.onDayOfTheMonth = onDayOfTheMonth;
    }

    public Integer getOnDayOfTheWeek() {
        return onDayOfTheWeek;
    }

    public void setOnDayOfTheWeek(Integer onDayOfTheWeek) {
        this.onDayOfTheWeek = onDayOfTheWeek;
    }

    /*public Boolean getOnLastDayOfTheMonth() {
        return onLastDayOfTheMonth;
    }

    public void setOnLastDayOfTheMonth(Boolean onLastDayOfTheMonth) {
        this.onLastDayOfTheMonth = onLastDayOfTheMonth;
    }*/

    public Integer getOnMinute() {
        return onMinute;
    }

    public void setOnMinute(Integer onMinute) {
        this.onMinute = onMinute;
    }

    public Integer getOnMonth() {
        return onMonth;
    }

    public void setOnMonth(Integer onMonth) {
        this.onMonth = onMonth;
    }

    public String getOnTime() {
        return onTime;
    }

    public void setOnTime(String onTime) {
        this.onTime = onTime;
    }

    public Long getSelectedProcessId() {
        return selectedProcessId;
    }

    public void setSelectedProcessId(Long selectedProcessId) {
        this.selectedProcessId = selectedProcessId;
    }

    public Date getFromDate() {
        return fromDate;
    }

    public void setFromDate(Date fromDate) {
        this.fromDate = fromDate;
    }

    public Integer getCronType() {
        return cronType;
    }

    public void setCronType(Integer cronType) {
        this.cronType = cronType;
    }

}
