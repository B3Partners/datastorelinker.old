/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.util;

import java.util.List;
import java.util.Locale;
import java.util.UUID;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import net.sourceforge.stripes.action.LocalizableMessage;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.datastorelinker.entity.ProcessStatus;
import nl.b3p.geotools.data.linker.DataStoreLinker;
import nl.b3p.geotools.data.linker.Status;
import org.hibernate.Session;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.apache.commons.lang.exception.ExceptionUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.quartz.TriggerUtils;

/**
 *
 * @author Erik van de Pol
 */
public class DataStoreLinkJob implements Job {

    private final static Log log = LogFactory.getLog(DataStoreLinkJob.class);
    private DataStoreLinker dsl = null;
    private nl.b3p.datastorelinker.entity.Process process = null;
    private Long processId = null;
    private Locale locale = Locale.getDefault();;
    private Throwable fatalException = null;
    public static final String KEY_DEFAULT_SMTP_HOST = "defaultSmtpHost";
    public static final String KEY_DEFAULT_FROM_ADDRESS = "defaultFromEmailAddress";

    public synchronized void setFatalException(Throwable fatalException) {
        this.fatalException = fatalException;
    }

    public synchronized DataStoreLinker getDataStoreLinker() throws Throwable {
        if (fatalException != null) {
            throw fatalException;
        }
        DataStoreLinker tempDsl = dsl;
        // if job is finished and in wait() mode, we let the job continue/terminate.
        /*if (tempDsl != null) {
            this.notify();
        }*/
        return tempDsl;
    }

    /**
     * Only this method is transactional since execution of the process (execute(JobExecutionContext jec))
     * could take hours or longer, depending on the input size.
     */
    private void setProcessStatus(ProcessStatus processStatus) throws Exception {
        if (processId == null) {
            log.error("processId was null when attempting to write status to it. " + processStatus);
        } else {
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            EntityTransaction tx = null;

            try {
                tx = em.getTransaction();
                log.debug("Starting transaction for default persistence unit.");
                tx.begin();

                Session session = (Session) em.getDelegate();

                process = (nl.b3p.datastorelinker.entity.Process) session.get(nl.b3p.datastorelinker.entity.Process.class, processId);

                log.debug("process status: " + processStatus);

                if (process.getProcessStatus() == null) {
                    session.save(processStatus);
                    process.setProcessStatus(processStatus);
                } else {
                    process.getProcessStatus().setMessage(processStatus.getMessage());
                    process.getProcessStatus().setProcessStatusType(processStatus.getProcessStatusType());
                }

                tx.commit();
            } catch (Exception e) {
                tryRollback(tx);
                throw e;
            } finally {
                JpaUtilServlet.closeThreadEntityManager();
            }
        }
    }

    public void execute(JobExecutionContext jec) throws JobExecutionException {
        ProcessStatus finishedStatus = null;
        EntityTransaction tx = null;
        
        // get the old scheduler instance to reuse in linked jobs
        Scheduler oldScheduler = jec.getScheduler();
        
        try {
            log.debug("Quartz started process");
            processId = jec.getJobDetail().getJobDataMap().getLong("processId");
            
            Locale providedLocale = (Locale)jec.getJobDetail().getJobDataMap().get("locale");
            if (providedLocale != null) {
                locale = providedLocale;
            }
            String providedSmtpHost
                    = (String) jec.getJobDetail().getJobDataMap().get(KEY_DEFAULT_SMTP_HOST);
            if (providedSmtpHost != null && !providedSmtpHost.isEmpty()) {
                DataStoreLinker.DEFAULT_SMTPHOST = providedSmtpHost;
            }
            String providedFromAddress
                    = (String) jec.getJobDetail().getJobDataMap().get(KEY_DEFAULT_FROM_ADDRESS);
            if (providedFromAddress != null && !providedFromAddress.isEmpty()) {
                DataStoreLinker.DEFAULT_FROM = providedFromAddress;
            }
 
            setProcessStatus(new ProcessStatus(ProcessStatus.Type.RUNNING));

            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            tx = em.getTransaction();
            tx.begin();

            Session session = (Session) em.getDelegate();

            process = (nl.b3p.datastorelinker.entity.Process) session.get(nl.b3p.datastorelinker.entity.Process.class, processId);

            /* Deze niet aan het einde van methode plaatsen om zo de transactie zo kort
             * mogelijk open te houden */
            tx.commit();

            if (process != null) {
                log.debug("Xml for process unmarshalled.");
                synchronized (this) {
                    dsl = new DataStoreLinker(process);
                }
                dsl.process();
                log.debug("Dsl process done!");
            }

        } catch (InterruptedException intEx) {
            tryRollback(tx);
            
            log.info("User canceled the process");
            
            finishedStatus = new ProcessStatus(ProcessStatus.Type.CANCELED_BY_USER);
        } catch (Exception ex) {
            tryRollback(tx);

            setFatalException(ex);
            log.warn("Fatal Exception: ", fatalException);

            finishedStatus = new ProcessStatus(
                    ProcessStatus.Type.LAST_RUN_FATAL_ERROR,
                    new LocalizableMessage("fatalError").getMessage(locale) + ": "
                        + ExceptionUtils.getRootCauseMessage(fatalException));
        } finally {
            JpaUtilServlet.closeThreadEntityManager();

            if (dsl != null) { // dsl finished with error if dsl == null
                if (finishedStatus == null) {
                    Status status = dsl.getStatus();
                    log.debug("Error-count: " + status.getErrorCount());
                    if (status.getErrorCount() == 0) {
                        if (status.getProcessedFeatures() == 0) {
                            finishedStatus = new ProcessStatus(ProcessStatus.Type.LAST_RUN_OK_WITH_ERRORS, status.getNonFatalErrorReport("<br />", 3));
                        } else {// if (status.getProcessedFeatures() == status.getVisitedFeatures()) {
                            finishedStatus = new ProcessStatus(ProcessStatus.Type.LAST_RUN_OK, status.getNonFatalErrorReport("<br />", 3));
                        }
                    } else {
                        finishedStatus = new ProcessStatus(ProcessStatus.Type.LAST_RUN_OK_WITH_ERRORS, status.getNonFatalErrorReport("<br />", 3));
                    }
                }
                try {
                    dsl.dispose();
                } catch (Exception ex) {
                    log.error("Could not dispose DataStoreLinker.", ex);
                }
            }

            try {
                setProcessStatus(finishedStatus);
            } catch (Exception e) {
                log.error("", e);
            }

        }
        
        //check linked processes
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        List<nl.b3p.datastorelinker.entity.Process> linkedProcesses = em.createQuery("FROM Process WHERE linked_process = :id").setParameter("id", this.process.getId()).getResultList();
        if (linkedProcesses != null && !linkedProcesses.isEmpty()) {
            if (finishedStatus.getProcessStatusType() == ProcessStatus.Type.LAST_RUN_OK
                    || finishedStatus.getProcessStatusType() == ProcessStatus.Type.LAST_RUN_OK_WITH_ERRORS) {
                try {
                    for (nl.b3p.datastorelinker.entity.Process linked : linkedProcesses) {
                        log.info("Schedule linked process: " + linked.getName() + " from parent process: " + this.process.getName());
                        scheduleDslJobImmediatelyWithOldScheduler(linked, oldScheduler);
                    }
                } catch (Exception ex) {
                    //geen verder foutmelding naar gebruiker, misschien later aparte status toevoegen
                    log.error("Linked process schedule could not be created: ", ex);
                }
            } else {
                log.error("Linked process not started due to errors in previous process.");
            }
        }
    }
   
    public void scheduleDslJobImmediately(nl.b3p.datastorelinker.entity.Process process) throws SchedulerException, Exception {

        String generatedJobUUID = "job" + UUID.randomUUID().toString();
        JobDetail jobDetail = JobBuilder.newJob(DataStoreLinkJob.class)
                .withIdentity(generatedJobUUID)
                .build();
        jobDetail.getJobDataMap().put("processId", process.getId());
        jobDetail.getJobDataMap().put("locale", locale);
        //already provided by parent job: host and email

        //Trigger trigger = TriggerUtils.makeImmediateTrigger(generatedJobUUID, 0, 0);
        Trigger trigger = TriggerBuilder.newTrigger()
                .forJob(jobDetail)
                .startNow()
                .build();
        // null context means the context should have been saved earlier
        Scheduler scheduler = SchedulerUtils.getScheduler(null);
        
        // open the transaction manager to save the generated UUID code before scheduling the job
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        EntityTransaction tx = null;
        tx = em.getTransaction();
        try {

            tx.begin();
            process.getProcessStatus().setExecutingJobUUID(generatedJobUUID);

            tx.commit();
        } catch (Exception e) {
            tryRollback(tx);
            throw e;
        } finally {
            JpaUtilServlet.closeThreadEntityManager();
        }
        
        // run the job
        scheduler.scheduleJob(jobDetail, trigger);
    }
        /**
         * Run a linked process immediately.
         * 
         * Reuse the scheduler from the previous class because the linkjob 
         * does not have access to the servlet context and will throw a 
         * NullPointerException when trying to get schedulerFactory in 
         * SchedulerUtils.
         * 
         * @param process Process
         * @param oldScheduler Scheduler
         * @throws SchedulerException
         * @throws Exception 
         */
        public void scheduleDslJobImmediatelyWithOldScheduler(nl.b3p.datastorelinker.entity.Process process, Scheduler oldScheduler) throws SchedulerException, Exception {

        String generatedJobUUID = "job" + UUID.randomUUID().toString();
            JobDetail jobDetail = JobBuilder.newJob(DataStoreLinkJob.class)
                    .withIdentity(generatedJobUUID)
                    .build();
        jobDetail.getJobDataMap().put("processId", process.getId());

        jobDetail.getJobDataMap().put("locale", locale);
        //already provided by parent job: host and email

            //Trigger trigger = TriggerUtils.makeImmediateTrigger(generatedJobUUID, 0, 0);
            Trigger trigger = TriggerBuilder.newTrigger()
                    .forJob(jobDetail)
                    .startNow()
                    .build();
        
        // open the transaction manager to save the generated UUID code before scheduling the job
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        EntityTransaction tx = null;
        tx = em.getTransaction();
        try {

            tx.begin();
            process.getProcessStatus().setExecutingJobUUID(generatedJobUUID);

            tx.commit();
        } catch (Exception e) {
            tryRollback(tx);
            throw e;
        } finally {
            JpaUtilServlet.closeThreadEntityManager();
        }
        
        // run the job
        oldScheduler.scheduleJob(jobDetail, trigger);
    }

    
    private void tryRollback(EntityTransaction tx) {
        if (tx != null && tx.isActive()) {
            log.error("Exception occurred - rolling back active transaction");
            try {
                tx.rollback();
            } catch (Exception e) {
                log.error("Exception rolling back transaction", e);
            }
        }
    }
}
