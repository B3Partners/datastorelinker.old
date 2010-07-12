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
 */
public class SchedulerUtils {
    private final static Log log = Log.getInstance(SchedulerUtils.class);

    public static Scheduler getScheduler(ServletContext context) throws SchedulerException {
        StdSchedulerFactory factory = (StdSchedulerFactory)
                context.getAttribute(QuartzInitializerListener.QUARTZ_FACTORY_KEY);

        return factory.getScheduler();
    }

    public static DataStoreLinkJob getProcessJob(ServletContext context, String jobUUID) {
        try {
            Scheduler scheduler = getScheduler(context);

            List<JobExecutionContext> jecs = scheduler.getCurrentlyExecutingJobs();
            for (JobExecutionContext jec : jecs) {
                if (jec.getTrigger().getName().equals(jobUUID)) {
                    return (DataStoreLinkJob)jec.getJobInstance();
                }
            }
        } catch (SchedulerException ex) {
            log.error(ex.getMessage());
        }
        return null;
    }
}
