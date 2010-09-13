/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.util;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.datastorelinker.entity.ProcessStatus;
import nl.b3p.geotools.data.linker.DataStoreLinker;
import org.hibernate.Session;
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
    private nl.b3p.datastorelinker.entity.Process process = null;
    private Long processId = null;
    private Throwable fatalException = null;

    public synchronized DataStoreLinker getDataStoreLinker() throws Throwable {
        DataStoreLinker tempDsl = dsl;
        // if job is finished and in wait() mode, we let the job continue/terminate.
        notify();
        if (fatalException != null)
            throw fatalException;
        return tempDsl;
    }

    /**
     * Only this method is transactional since execution of the process (execute(JobExecutionContext jec))
     * could take hours or longer, depending on the input size.
     * @param processStatus
     */
    private void setProcessStatus(ProcessStatus processStatus) throws Exception {
        if (processId == null) {
            log.error("processId was null when attempting to write status to it. " + processStatus);
        } else {
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            EntityTransaction tx = em.getTransaction();
            log.debug("Starting transaction for default persistence unit.");
            tx.begin();

            try {
                Session session = (Session)em.getDelegate();

                process = (nl.b3p.datastorelinker.entity.Process)
                        session.get(nl.b3p.datastorelinker.entity.Process.class, processId);

                log.debug("process status: " + processStatus);

                if (process.getProcessStatus() == null) {
                    session.save(processStatus);
                    process.setProcessStatus(processStatus);
                } else {
                    process.getProcessStatus().setMessage(processStatus.getMessage());
                    process.getProcessStatus().setProcessStatusType(processStatus.getProcessStatusType());
                }

                if (tx.isActive()) {
                    log.debug("Committing active transaction");
                    tx.commit();
                } else {
                    log.debug("Transaction is not active - not committing");
                }
            } catch (Exception e1) {
                if (!tx.isActive()) {
                    log.debug("Exception occurred but the transaction is not active - not rolling back");
                } else {
                    log.error("Exception occurred - rolling back active transaction");
                    try {
                        tx.rollback();
                    } catch (Exception e2) {
                        /* log de exception maar swallow deze verder, omdat alleen
                         * wordt gerollback()'d indien er al een eerdere exception
                         * was gethrowed. Die wordt door deze te swallowen verder
                         * gethrowed.
                         */
                        log.error("Exception rolling back transaction", e2);
                    }
                    throw e1;
                }
            } finally  {
                JpaUtilServlet.closeThreadEntityManager();
            }
        }
    }

    public void execute(JobExecutionContext jec) throws JobExecutionException {
        ProcessStatus finishedStatus = null;
        try {
            log.debug("Quartz started process");
            //String xmlProcess
            processId = jec.getJobDetail().getJobDataMap().getLong("processId");//.getString("process");
            
            setProcessStatus(new ProcessStatus(ProcessStatus.Type.RUNNING));
            //log.debug(xmlProcess);
            //nl.b3p.datastorelinker.entity.Process process = null;

            /*ClassLoader savedClassLoader = Thread.currentThread().getContextClassLoader();
            Thread.currentThread().setContextClassLoader(this.getClass().getClassLoader());

            log.debug("savedClassLoader: " + savedClassLoader.toString());
            log.debug("this.getClass().getClassLoader(): " + this.getClass().getClassLoader().toString());
            log.debug("parent savedClassLoader: " + savedClassLoader.getParent().toString());
            log.debug("parent this.getClass().getClassLoader(): " + this.getClass().getClassLoader().getParent().toString());
            */
            
            //process = MarshalUtils.unmarshalProcess(xmlProcess);

            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            Session session = (Session)em.getDelegate();

            process = (nl.b3p.datastorelinker.entity.Process)
                    session.get(nl.b3p.datastorelinker.entity.Process.class, processId);

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
            finishedStatus = new ProcessStatus(ProcessStatus.Type.CANCELED_BY_USER);
        } catch (Exception ex) {
            log.error(ex);

            fatalException = ExceptionUtils.getUltimateCause(ex);
            
            finishedStatus = new ProcessStatus(
                    ProcessStatus.Type.LAST_RUN_FATAL_ERROR,
                    ExceptionUtils.getReadableExceptionMessage(fatalException));
        } finally {
            //Thread.currentThread().setContextClassLoader(savedClassLoader);

            if (dsl != null) { // dsl finished with error if dsl == null
                if (finishedStatus == null) {
                    log.debug("Error-count: " + dsl.getStatus().getErrorCount());
                    if (dsl.getStatus().getErrorCount() <= 0)
                        finishedStatus = new ProcessStatus(ProcessStatus.Type.LAST_RUN_OK);
                    else
                        finishedStatus = new ProcessStatus(ProcessStatus.Type.LAST_RUN_OK_WITH_ERRORS, dsl.getStatus().getNonFatalErrorReport("<br />", 3));
                }
                try {
                    dsl.dispose();
                } catch (Exception ex) {
                    log.error(ex, "Could not dispose DataStoreLinker.");
                }
            }
            
            try {
                setProcessStatus(finishedStatus);
            } catch(Exception e) {
                log.error(e);
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
