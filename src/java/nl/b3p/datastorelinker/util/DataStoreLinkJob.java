/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.util;

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
    private Exception fatalException = null;

    public synchronized DataStoreLinker getDataStoreLinker() throws Exception {
        DataStoreLinker tempDsl = dsl;
        // if job is finished and in wait() mode, we let the job continue/terminate.
        notify();
        if (fatalException != null)
            throw fatalException;
        return tempDsl;
    }

    public void execute(JobExecutionContext jec) throws JobExecutionException {
        try {
            log.debug("Quartz started process");
            String xmlProcess = jec.getJobDetail().getJobDataMap().getString("process");
            log.debug(xmlProcess);
            nl.b3p.datastorelinker.entity.Process process = null;

            /*ClassLoader savedClassLoader = Thread.currentThread().getContextClassLoader();
            Thread.currentThread().setContextClassLoader(this.getClass().getClassLoader());

            log.debug("savedClassLoader: " + savedClassLoader.toString());
            log.debug("this.getClass().getClassLoader(): " + this.getClass().getClassLoader().toString());
            log.debug("parent savedClassLoader: " + savedClassLoader.getParent().toString());
            log.debug("parent this.getClass().getClassLoader(): " + this.getClass().getClassLoader().getParent().toString());
            */
            
            process = MarshalUtils.unmarshalProcess(xmlProcess);

            if (process != null) {
                log.debug("Xml for process unmarshalled.");
                synchronized(this) {
                    dsl = new DataStoreLinker(process);
                }
                //throw new Exception("test: oeps!");
                dsl.process();
                log.debug("Dsl process done!");
            }
        } catch (InterruptedException intEx) {
            //log.info(intEx, "Process interrupted.");
            log.info("User canceled the process");
        } catch (Exception ex) {
            // TODO: polling must check / know that a fatal eror has occured.
            fatalException = ex;
            log.error(ex);
        } finally {
            //Thread.currentThread().setContextClassLoader(savedClassLoader);

            if (dsl != null) {
                try {
                    dsl.dispose();
                } catch (Exception ex) {
                    log.error(ex, "Could not dispose DataStoreLinker.");
                }
            }

            // We keep this thread alive for 10 seconds
            // to let the execution progress polling system know we are done.
            // Possible problem: server is shut down before this method finishes; Leaving a job not marked finished.
            try {
                synchronized(this) {
                    wait(10000);
                    if (log != null) // server could be shutting down; leaving us without a logger.
                        log.debug("woken up from wait");
                }
            } catch (InterruptedException intEx) {}
        }
    }

}
