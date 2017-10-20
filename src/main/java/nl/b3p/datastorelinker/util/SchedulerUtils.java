/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.util;

import java.util.List;
import javax.servlet.ServletContext;
import net.sourceforge.stripes.util.Log;
import org.quartz.JobExecutionContext;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.ee.servlet.QuartzInitializerListener;
import org.quartz.impl.StdSchedulerFactory;

/**
 *
 * @author Erik van de Pol
 * @author mprins
 */
public class SchedulerUtils {
    // save servlet context for use in quartz threads
    public static StdSchedulerFactory schedulerFactory = null;
    
    private final static Log log = Log.getInstance(SchedulerUtils.class);

    public static Scheduler getScheduler(ServletContext context) throws SchedulerException {
        if (schedulerFactory == null) {
            schedulerFactory = (StdSchedulerFactory)
                context.getAttribute(QuartzInitializerListener.QUARTZ_FACTORY_KEY);
        }
       if (schedulerFactory == null) {
            throw new SchedulerException("No quartz factory available!");
        }
        
        return schedulerFactory.getScheduler();
    }

    public static DataStoreLinkJob getProcessJob(ServletContext context, String jobUUID) {
        try {
            Scheduler scheduler = getScheduler(context);

            log.debug("triggers:");
            List<JobExecutionContext> jecs = scheduler.getCurrentlyExecutingJobs();
            for (JobExecutionContext jec : jecs) {
                log.debug(jec.getTrigger().getKey().getName());
                if (jec.getTrigger().getKey().getName().equals(jobUUID)) {
                    return (DataStoreLinkJob)jec.getJobInstance();
                }
            }
        } catch (SchedulerException ex) {
            log.error(ex.getMessage());
        }
        return null;
    }
}
