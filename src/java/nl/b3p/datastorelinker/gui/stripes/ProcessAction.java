/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.sql.SQLException;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import javax.persistence.EntityManager;
import net.sf.json.JSON;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.LocalizableMessage;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.StreamingResolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.entity.Mail;
import nl.b3p.datastorelinker.entity.ProcessStatus;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.json.ProgressMessage;
import nl.b3p.datastorelinker.json.SuccessMessage;
import nl.b3p.datastorelinker.util.DataStoreLinkJob;
import nl.b3p.datastorelinker.util.DefaultErrorResolution;
import nl.b3p.datastorelinker.util.MarshalUtils;
import nl.b3p.datastorelinker.util.SchedulerUtils;
import nl.b3p.geotools.data.linker.Status;
import org.hibernate.Session;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.Trigger;
import org.quartz.TriggerUtils;

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

    private Boolean drop;

    private String actionsList;
    private String jobUUID;

    private String emailAddress;
    private String subject;

    // dummy variable
    private Boolean admin;

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

        inputs = session.getNamedQuery("Inout.find")
                .setParameter("typeName", Inout.Type.INPUT)
                .list();
        outputs = session.getNamedQuery("Inout.find")
                .setParameter("typeName", Inout.Type.OUTPUT)
                .list();

        if (actionsList == null)
            actionsList = new JSONArray().toString();

        if (emailAddress == null)
            emailAddress = getContext().getServletContext().getInitParameter("defaultToEmailAddress");

        if (subject == null)
            subject = getContext().getServletContext().getInitParameter("defaultSubject");

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
        process.setActionsString(getCreateActionsListString());
        process.setDrop(drop);
        
        Mail mail = null;
        if (process.getMail() == null)
            mail = new Mail();
        else
            mail = process.getMail();

        mail.setToEmailAddress(emailAddress);
        mail.setSubject(subject);
        mail.setFromEmailAddress(getContext().getServletContext().getInitParameter("defaultFromEmailAddress"));
        mail.setSmtpHost(getContext().getServletContext().getInitParameter("defaultSmtpHost"));

        if (process.getMail() == null) {
            session.save(mail);
            process.setMail(mail);
        }

        if (process.getProcessStatus() == null) {
            ProcessStatus processStatus = ProcessStatus.getDefault();
            session.save(processStatus);
            process.setProcessStatus(processStatus);
        }
        
        if (selectedProcessId == null)
            selectedProcessId = (Long)session.save(process);

        return list();
    }

    private String getCreateActionsListString() {
        if (actionsList == null || actionsList.trim().equals(""))
            actionsList = new JSONArray().toString();

        JSONArray actionsListJSONArray = JSONArray.fromObject(actionsList);
        //log.debug("beforeRemove: " + actionsListJSONArray);
        ActionsAction.removeViewData(actionsListJSONArray);
        //log.debug("afterRemove: " + actionsListJSONArray);
        ActionsAction.addExpandableProperty(actionsListJSONArray);
        //log.debug("afterExpandableProp: " + actionsListJSONArray);

        JSON actionsListJSON = JSONSerializer.toJSON(actionsListJSONArray);
        
        XMLSerializer xmlSerializer = new XMLSerializer();
        xmlSerializer.setArrayName("actions");
        xmlSerializer.setElementName("action");
        xmlSerializer.setExpandableProperties(new String[] {
            "parameter"
        });
        xmlSerializer.setTypeHintsEnabled(false);

        String actionsListXml = xmlSerializer.write(actionsListJSON);
        //log.debug(actionsListXml);
        //log.debug("actionsList: " + actionsList);

        return actionsListXml;
    }

    @Transactional
    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        selectedInputId = process.getInput().getId();
        selectedOutputId = process.getOutput().getId();
        actionsList = getUpdateActionsListString(process);
        drop = process.getDrop();
        emailAddress = process.getMail().getToEmailAddress();
        subject = process.getMail().getSubject();

        return create();
    }

    private String getUpdateActionsListString(nl.b3p.datastorelinker.entity.Process process) {
        String xmlActions = process.getActionsString();
        XMLSerializer xmlSerializer = new XMLSerializer();
        JSON jsonActions = xmlSerializer.read(xmlActions);
        JSONArray jsonArrayActions = JSONArray.fromObject(jsonActions);

        if (jsonArrayActions.size() == 1) {
            if (jsonArrayActions.get(0).toString().equals("null")) {
                // als inhoud leeg is wordt dit verkeerd geserialized. Dit fixen we hier:
                jsonArrayActions.clear();
            } else {
                // als inhoud 1 valide action bevat wordt dit verkeerd geserialized.
                // Er zit dan namelijk 1 "laag" teveel in met de key "action"
                // Dit fixen we hier:
                JSONObject singleActionJSON = jsonArrayActions.getJSONObject(0);
                jsonArrayActions.clear();
                jsonArrayActions.add(singleActionJSON.get("action"));
            }
        }
        log.debug("beforeInsert: " + jsonArrayActions);
        ActionsAction.addViewData(jsonArrayActions);
        log.debug("afterInsert: " + jsonArrayActions);
        //log.debug(actionsList);

        return jsonArrayActions.toString();
    }

    @Transactional
    public Resolution delete() {
        PeriodicalProcessAction ppaction = new PeriodicalProcessAction();
        ppaction.cancelExecutePeriodicallyImpl(selectedProcessId, getContext().getServletContext());

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        session.delete(session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId));
        
        return list();
    }

    @Transactional
    public Resolution execute() {
        log.debug("Executing process with id: " + selectedProcessId);

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        try {
            //String processString = MarshalUtils.marshalProcess(process);
            //log.debug(processString);

            String generatedJobUUID = "job" + UUID.randomUUID().toString();
            JobDetail jobDetail = new JobDetail(generatedJobUUID, DataStoreLinkJob.class);
            jobDetail.getJobDataMap().put("processId", process.getId());//processString);
            
            Trigger trigger = TriggerUtils.makeImmediateTrigger(generatedJobUUID, 0, 0);
            //Trigger trigger = new SimpleTrigger("nowTrigger", new Date());
            Scheduler scheduler = SchedulerUtils.getScheduler(getContext().getServletContext());
            scheduler.scheduleJob(jobDetail, trigger);
            
            //log.debug(result);
            return new JSONResolution(new SuccessMessage(true, generatedJobUUID, null));
        } catch(Exception e) {
            log.error(e.getMessage());
            return new JSONResolution(new SuccessMessage(false, e.getMessage(), null));
        }
    }

    public Resolution executionProgress() {
        DataStoreLinkJob dslJob = SchedulerUtils.getProcessJob(getContext().getServletContext(), jobUUID);

        try {
            if (dslJob == null || dslJob.getDataStoreLinker() == null) {
                //log.debug("dslJob: " + dslJob);
                //if (dslJob != null)
                    //log.debug("dslJob.getDataStoreLinker(): " + dslJob.getDataStoreLinker());

                log.error("dslJob or dslJob.getDataStoreLinker() null!");
                return new JSONResolution(new ProgressMessage(0));
            } else {
                Status dslStatus = dslJob.getDataStoreLinker().getStatus();

                int totalFeatureCount = dslStatus.getTotalFeatureCount();
                int totalFeatureSize = dslStatus.getTotalFeatureSize();

                //log.debug("Gedaan: " + totalFeatureCount + " / " + totalFeatureSize);

                int percentage = (int)Math.floor(100.0 * (double)totalFeatureCount / (double)totalFeatureSize);
                //log.debug("execution progress report: " + percentage + "%");
                ProgressMessage progressMessage = new ProgressMessage(percentage);
                if (percentage >= 100) {
                    //progressMessage.setMessage(dslJob.getDataStoreLinker().getStatus().getFinishedMessage());
                    progressMessage.setMessage(dslJob.getDataStoreLinker().getStatus().getNonFatalErrorReport("<br />", 3));
                }

                return new JSONResolution(progressMessage);
            }
        } catch(Throwable t) {
            String message = new LocalizableMessage("fatalError").getMessage(Locale.getDefault())
                    + ": " + t.getMessage();
            return new JSONResolution(new ProgressMessage(message));
        }
    }

    public Resolution cancel() {
        DataStoreLinkJob dslJob = SchedulerUtils.getProcessJob(getContext().getServletContext(), jobUUID);

        try {
            if (dslJob == null) {
                return new JSONResolution(new SuccessMessage(false));
            } else {
                dslJob.getDataStoreLinker().getStatus().setInterrupted(true);

                return new JSONResolution(new SuccessMessage(true));
            }
        } catch(Throwable t) {
            String message = new LocalizableMessage("fatalError").getMessage(Locale.getDefault())
                    + ": " + t.getMessage();
            return new JSONResolution(new SuccessMessage(false, message, ""));
        }
    }

    public Resolution exportToXml() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        try {
            String xml = MarshalUtils.marshalProcess(process, MarshalUtils.getDslSchema());
            // TODO: set filename als een geëscapedete procesnaam.
            return new StreamingResolution("text/xml", xml).setFilename("dsl_process.xml");
        } catch(Exception ex) {
            log.error(ex);
            return new DefaultErrorResolution(ex.getLocalizedMessage());
        }
    }

    //TODO: test: is output DB PostGIS (itt alleen Postgres)? merk je nu bij run als het goed is.

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

    public Boolean getDrop() {
        return drop;
    }

    public void setDrop(Boolean drop) {
        this.drop = drop;
    }

    public String getEmailAddress() {
        return emailAddress;
    }

    public void setEmailAddress(String emailAddress) {
        this.emailAddress = emailAddress;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public Boolean getAdmin() {
        return admin;
    }

    public void setAdmin(Boolean admin) {
        this.admin = admin;
    }

}
