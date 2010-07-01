/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.util;

import java.util.logging.Level;
import java.util.logging.Logger;
import net.sourceforge.stripes.util.Log;
import nl.b3p.geotools.data.linker.DataStoreLinker;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 *
 * @author Erik van de Pol
 */
public class DataStoreLinkJob implements Job {
    private final static Log log = Log.getInstance(DataStoreLinkJob.class);

    private DataStoreLinker dsl = null;

    public synchronized DataStoreLinker getDataStoreLinker() {
        DataStoreLinker tempDsl = dsl;
        // if job is finished and in wait() mode, we let the job continue/terminate.
        notify();
        return tempDsl;
    }

    public void execute(JobExecutionContext jec) throws JobExecutionException {
        log.debug("Quartz started process");
        String xmlProcess = jec.getJobDetail().getJobDataMap().getString("process");
        log.debug(xmlProcess);
        nl.b3p.datastorelinker.entity.Process process = null;

        ClassLoader savedClassLoader = Thread.currentThread().getContextClassLoader();
        Thread.currentThread().setContextClassLoader(this.getClass().getClassLoader());

        log.debug("savedClassLoader: " + savedClassLoader.toString());
        log.debug("this.getClass().getClassLoader(): " + this.getClass().getClassLoader().toString());
        log.debug("parent savedClassLoader: " + savedClassLoader.getParent().toString());
        log.debug("parent this.getClass().getClassLoader(): " + this.getClass().getClassLoader().getParent().toString());
        
        try {
            process = MarshalUtils.unmarshalProcess(xmlProcess);

            if (process != null) {
                log.debug("Xml for process unmarshalled.");
                synchronized(this) {
                    dsl = new DataStoreLinker(process);
                }
                dsl.process();
            }
        } catch (InterruptedException intEx) {
            //log.info(intEx, "Process interrupted.");
            log.info("User canceled the process");
        } catch (Exception ex) {
            // TODO: polling must check / know that a fatal eror has occured.
            throw new JobExecutionException(ex);
        } finally {
            Thread.currentThread().setContextClassLoader(savedClassLoader);

            if (dsl != null) {
                try {
                    dsl.dispose();
                } catch (Exception ex) {
                    log.error(ex, "Could not dispose DataStoreLinker.");
                }
            }

            // We keep this thread alive for 10 seconds
            // to let the execution progress polling system know we are done.
            try {
                synchronized(this) {
                    wait(10000);
                    log.debug("woken up from wait");
                }
            } catch (InterruptedException intEx) {}
        }
    }

}
