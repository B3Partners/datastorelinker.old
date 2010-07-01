/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;
import javax.persistence.EntityManager;
import javax.servlet.ServletContext;
import net.sf.json.JSON;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.json.ActionModel;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.json.ProgressMessage;
import nl.b3p.datastorelinker.json.SuccessMessage;
import nl.b3p.datastorelinker.util.DataStoreLinkJob;
import nl.b3p.datastorelinker.util.Mappable;
import nl.b3p.datastorelinker.util.MarshalUtils;
import nl.b3p.geotools.data.linker.Status;
import org.hibernate.Session;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.TriggerUtils;
import org.quartz.ee.servlet.QuartzInitializerListener;
import org.quartz.impl.StdSchedulerFactory;

/**
 *
 * @author Erik van de Pol
 */
public class ProcessAction extends DefaultAction {

    private final static Log log = Log.getInstance(ProcessAction.class);

    
    private final static String JSP = "/pages/main/process/overview.jsp";
    private final static String LIST_JSP = "/pages/main/process/list.jsp";
    private final static String CREATE_JSP = "/pages/main/process/create.jsp";
    private final static String EXECUTE_JSP = "/pages/main/process/execute.jsp";
    
    private List<Process> processes;
    private Long selectedProcessId;
    
    private List<Inout> inputs;
    private Long selectedInputId;

    private List<Inout> inputsFile;
    private List<Inout> inputsDB;
    
    private List<Inout> outputs;
    private Long selectedOutputId;

    private String actionsList;
    private String jobUUID;

    @Transactional
    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        // moet even wat hulp krijgen om die order by's goed te krijgen
        // (te maken met de dot-notation voor joins die niet werkt zoals ik denk dat ie werkt.).
        processes = session.createQuery("from Process order by name").list();

        return new ForwardResolution(LIST_JSP);
    }

    @DefaultHandler
    public Resolution overview() {
        list();
        return new ForwardResolution(JSP);
    }

    @Transactional
    public Resolution create() {//throws Exception {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        inputs = session.createQuery("from Inout where type.id = 1").list();
        //inputsFile = session.createQuery("from Inout where typeId = 1 and datatypeId = 2").list();
        //inputsDB = session.createQuery("from Inout where typeId = 1 and datatypeId = 1").list();
        outputs = session.createQuery("from Inout where type.id = 2").list();

        if (actionsList == null)
            actionsList = new JSONArray().toString();

        //log.debug("actionsList:");
        //log.debug(actionsList);
        
        //throw new Exception("qweqwe"); // error test

        return new ForwardResolution(CREATE_JSP);
    }

    @Transactional
    public Resolution createComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout input = (Inout)session.get(Inout.class, selectedInputId);
        Inout output = (Inout)session.get(Inout.class, selectedOutputId);

        nl.b3p.datastorelinker.entity.Process process;
        if (selectedProcessId == null)
            process = new nl.b3p.datastorelinker.entity.Process();
        else
            process = (nl.b3p.datastorelinker.entity.Process)
                    session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);
        
        // TODO: custom name:
        process.setName(input.getName() + " -> " + output.getName());
        process.setInput(input);
        process.setOutput(output);
        if (actionsList == null || actionsList.trim().equals(""))
            actionsList = new JSONArray().toString();

        JSONArray actionsListJSONArray = JSONArray.fromObject(actionsList);
        log.debug("actionsListJSONArray: " + actionsListJSONArray);

        JSON actionsListJSON = JSONSerializer.toJSON(actionsListJSONArray);
        XMLSerializer xmlSerializer = new XMLSerializer();
        xmlSerializer.setArrayName("actions");
        xmlSerializer.setElementName("action");
        xmlSerializer.setExpandableProperties(new String[] {
            "parameter"
        });
        xmlSerializer.setTypeHintsEnabled(false);
        String actionsListXml = xmlSerializer.write(actionsListJSON);
        log.debug(actionsListXml);

        process.setActionsString(actionsListXml);
        //log.debug("actionsList: " + actionsList);

        if (selectedProcessId == null)
            selectedProcessId = (Long)session.save(process);
        //else // automatic saveOrUpdate
            //session.saveOrUpdate(process);
        
        return list();
    }

    @Transactional
    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        selectedInputId = process.getInput().getId();
        selectedOutputId = process.getOutput().getId();

        String xmlActions = process.getActionsString();
        JSON jsonActions = new XMLSerializer().read(xmlActions);
        JSONArray jsonArrayActions = JSONArray.fromObject(jsonActions);
        actionsList = jsonArrayActions.toString();
        //log.debug(actionsList);

        return create();
    }

    @Transactional
    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        session.delete(session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId));
        
        return list();
    }

    @Transactional
    public Resolution execute() throws Exception {
        log.debug("Executing process with id: " + selectedProcessId);

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        String processString = MarshalUtils.marshalProcess(process);
        //log.debug(processString);

        try {
            String generatedJobUUID = "job" + UUID.randomUUID().toString();
            JobDetail jobDetail = new JobDetail(generatedJobUUID, DataStoreLinkJob.class);
            jobDetail.getJobDataMap().put("process", processString);
            
            Trigger trigger = TriggerUtils.makeImmediateTrigger(generatedJobUUID, 0, 0);
            //Trigger trigger = new SimpleTrigger("nowTrigger", new Date());
            Scheduler scheduler = getScheduler();
            scheduler.scheduleJob(jobDetail, trigger);
            
            //log.debug(result);
            return new JSONResolution(new SuccessMessage(true, generatedJobUUID, null));
        } catch(Exception e) {
            log.error(e.getMessage());
            return new JSONResolution(new SuccessMessage(false, e.getMessage(), null));
        }
    }

    public Resolution executionProgress() {
        DataStoreLinkJob dslJob = getProcessJob();

        if (dslJob == null || dslJob.getDataStoreLinker() == null) {
            //log.debug("dslJob: " + dslJob);
            //if (dslJob != null)
                //log.debug("dslJob.getDataStoreLinker(): " + dslJob.getDataStoreLinker());

            log.warn("dslJob or dslJob.getDataStoreLinker() null!");
            return new JSONResolution(new ProgressMessage(0));
        } else {
            Status dslStatus = dslJob.getDataStoreLinker().getStatus();

            int totalFeatureCount = dslStatus.getTotalFeatureCount();
            int totalFeatureSize = dslStatus.getTotalFeatureSize();

            //log.debug("Gedaan: " + totalFeatureCount + " / " + totalFeatureSize);

            int percentage = (int)Math.floor(100.0 * (double)totalFeatureCount / (double)totalFeatureSize);
            //log.debug("execution progress report: " + percentage + "%");
            ProgressMessage progressMessage = new ProgressMessage(percentage);
            if (percentage >= 100)
                progressMessage.setMessage(dslJob.getDataStoreLinker().getFinishedMessage());
            
            return new JSONResolution(progressMessage);
        }
    }

    public Resolution cancel() {
        DataStoreLinkJob dslJob = getProcessJob();

        if (dslJob == null) {
            return new JSONResolution(new SuccessMessage(false));
        } else {
            dslJob.getDataStoreLinker().getStatus().setInterrupted(true);
            
            return new JSONResolution(new SuccessMessage(true));
        }
    }

    private Scheduler getScheduler() throws SchedulerException {
        ServletContext context = getContext().getServletContext();
        StdSchedulerFactory factory = (StdSchedulerFactory)
                context.getAttribute(QuartzInitializerListener.QUARTZ_FACTORY_KEY);

        return factory.getScheduler();
    }

    private DataStoreLinkJob getProcessJob() {
        try {
            Scheduler scheduler = getScheduler();

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

    //TODO: test: is output DB PostGIS (itt alleen Postgres)?

    public List<Process> getProcesses() {
        return processes;
    }

    public void setProcesses(List<Process> processes) {
        this.processes = processes;
    }

    public List<Inout> getInputs() {
        return inputs;
    }

    public void setInputs(List<Inout> inputs) {
        this.inputs = inputs;
    }

    public List<Inout> getOutputs() {
        return outputs;
    }

    public void setOutputs(List<Inout> outputs) {
        this.outputs = outputs;
    }

    public List<Inout> getInputsFile() {
        return inputsFile;
    }

    public void setInputsFile(List<Inout> inputsFile) {
        this.inputsFile = inputsFile;
    }

    public List<Inout> getInputsDB() {
        return inputsDB;
    }

    public void setInputsDB(List<Inout> inputsDB) {
        this.inputsDB = inputsDB;
    }

    public Long getSelectedInputId() {
        return selectedInputId;
    }

    public void setSelectedInputId(Long selectedInputId) {
        this.selectedInputId = selectedInputId;
    }

    public Long getSelectedOutputId() {
        return selectedOutputId;
    }

    public void setSelectedOutputId(Long selectedOutputId) {
        this.selectedOutputId = selectedOutputId;
    }

    public Long getSelectedProcessId() {
        return selectedProcessId;
    }

    public void setSelectedProcessId(Long selectedProcessId) {
        this.selectedProcessId = selectedProcessId;
    }

    public String getActionsList() {
        return actionsList;
    }

    public void setActionsList(String actionsList) {
        this.actionsList = actionsList;
    }

    public String getJobUUID() {
        return jobUUID;
    }

    public void setJobUUID(String jobUUID) {
        this.jobUUID = jobUUID;
    }

}
