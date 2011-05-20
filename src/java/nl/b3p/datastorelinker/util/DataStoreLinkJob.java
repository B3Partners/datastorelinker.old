/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.util;

import java.util.Locale;
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

/**
 *
 * @author Erik van de Pol
 */
public class DataStoreLinkJob implements Job {

    private final static Log log = LogFactory.getLog(DataStoreLinkJob.class);
    private DataStoreLinker dsl = null;
    private nl.b3p.datastorelinker.entity.Process process = null;
    private Long processId = null;
    private Throwable fatalException = null;

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
     * @param processStatus
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
        
        Locale locale = Locale.getDefault();
        try {
            log.debug("Quartz started process");
            processId = jec.getJobDetail().getJobDataMap().getLong("processId");
            locale = (Locale)jec.getJobDetail().getJobDataMap().get("locale");

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

            // We keep this thread alive for 10 seconds
            // to let the execution progress polling system know we are done.
            // For some obscure reason wait() does not wait.
            /*try {
            synchronized(this) {
            log.debug("start wait");
            this.wait(10000);
            if (log != null) // server could be shutting down; leaving us without a logger.
            log.debug("woken up from wait");
            }
            } catch (InterruptedException intEx) {
            log.debug("wait interrupted");
            }*/
        }
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
