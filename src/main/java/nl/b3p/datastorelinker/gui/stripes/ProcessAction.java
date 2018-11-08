/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
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
import nl.b3p.datastorelinker.entity.Organization;
import nl.b3p.datastorelinker.entity.Process;
import nl.b3p.datastorelinker.entity.ProcessStatus;
import nl.b3p.datastorelinker.entity.Users;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.json.ProgressMessage;
import nl.b3p.datastorelinker.json.SuccessMessage;
import nl.b3p.datastorelinker.util.DataStoreLinkJob;
import nl.b3p.datastorelinker.util.DefaultErrorResolution;
import nl.b3p.datastorelinker.util.MarshalUtils;
import nl.b3p.datastorelinker.util.NameableComparer;
import nl.b3p.datastorelinker.util.SchedulerUtils;
import nl.b3p.geotools.data.linker.DataStoreLinker;
import nl.b3p.geotools.data.linker.Status;
import org.apache.commons.lang.exception.ExceptionUtils;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;

/**
 *
 * @author Erik van de Pol
 */
@Transactional
public class ProcessAction extends DefaultAction {

    private final static Log log = Log.getInstance(ProcessAction.class);
    
    private final static String JSP = "/WEB-INF/jsp/main/process/overview.jsp";
    private final static String LIST_JSP = "/WEB-INF/jsp/main/process/list.jsp";
    private final static String CREATE_JSP = "/WEB-INF/jsp/main/process/create.jsp";
    private final static String EXECUTE_JSP = "/WEB-INF/jsp/main/process/execute.jsp";
    private final static String PROCESS_DIAGRAM_JSP = "/WEB-INF/jsp/main/process/diagram.jsp";
    
    private List<nl.b3p.datastorelinker.entity.Process> processes;
    private Long selectedProcessId;
    
    private List<Inout> inputs;
    private Long selectedInputId;

    private List<Inout> inputsFile;
    private List<Inout> inputsDB;
    
    private List<Inout> outputs;
    private Long selectedOutputId;

    private boolean drop;
    private boolean append;
    private boolean modify;
    private boolean modifyGeom;

    private String actionsList;
    private String jobUUID;

    private String emailAddress;
    private String subject;
    private String processName;
    private String processRemark;

    private String selectedFilePath;
    
    private Long linkedProcess;
    
    private JSONArray jsonProcesses;
    
    private String filter;
    private String modifyFilter;
    // dummy variable
    private Boolean admin;

    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            processes = session.createQuery("from Process order by name").list();
        } else {
            processes = session.createQuery("from Process where organization_id = :org_id"
                    + " order by name")
                    .setParameter("org_id", getUserOrganiztionId())
                    .list();
        }
        
        /* Gebruikernaam en opmerking zetten voor in overzicht */
        for (nl.b3p.datastorelinker.entity.Process process : processes) {            
            Users user = (Users) session.createQuery("from Users where id = :userid")
                    .setParameter("userid", process.getUserId()).uniqueResult();
            if(process.getLinkedProcess() != null){
                Hibernate.initialize(process.getLinkedProcess());
            }
            if (user != null) {
                process.setUserName(user.getName());
            }
        }
        
        Collections.sort(processes, new NameableComparer());

        return new ForwardResolution(LIST_JSP);
    }
    
    
    /**
     * get a list of processes - processStatuses, convert to JSON 
     * 
     * @return 
     */
    
    public Resolution listToJson() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            processes = session.createQuery("from Process order by name").list();
        } else {
            processes = session.createQuery("from Process where organization_id = :org_id"
                    + " order by name")
                    .setParameter("org_id", getUserOrganiztionId())
                    .list();
        }
        
        /* Gebruikernaam en opmerking zetten voor in overzicht */
        for (nl.b3p.datastorelinker.entity.Process process : processes) {            
            Users user = (Users) session.createQuery("from Users where id = :userid")
                    .setParameter("userid", process.getUserId()).uniqueResult();
            if(process.getLinkedProcess() != null){
                Hibernate.initialize(process.getLinkedProcess());
            }
            if (user != null) {
                process.setUserName(user.getName());
            }
        }
        
        ArrayList<ArrayList<String>> clean_processes = getSimpleProcessList(processes);
        JSONArray processesJson = new JSONArray();
        processesJson.addAll(clean_processes);

        return new JSONResolution(processesJson);
    }

    /**
     * Convert a list of Process objects to a Arraylist of tuples with
     * - processid
     * - processStatus
     * 
     * This will avoid circular references when serializing to JSON
     * @param processes
     * @return 
     */
    private ArrayList<ArrayList<String>> getSimpleProcessList(List<Process> processes){
        
        
        ArrayList<ArrayList<String>> processResultList = new ArrayList<ArrayList<String>>() ;
        
        for (Process process : processes) {
            ArrayList<String> tuple = new ArrayList<String>();
            tuple.add(Long.toString(process.getId()));
            tuple.add(process.getProcessStatus().getProcessStatusType().toString());
            processResultList.add(tuple);
        }
        
        return processResultList;
    };
    @DefaultHandler
    public Resolution overview() {
        list();
        return new ForwardResolution(JSP);
    }

    public Resolution create() {        
        inputs = findInputs();
        outputs = findOutputs();
        
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        /* show all to beheerder but organization only for plain users */
        if(selectedProcessId == null){
            selectedProcessId = -1L;
        }
        if (isUserAdmin()) {
            processes = session.createQuery("from Process where id <> :id order by name").setParameter("id", selectedProcessId).list();
        } else {
            processes = session.createQuery("from Process where organization_id = :org_id and id <> :id"
                    + " order by name")
                    .setParameter("org_id", getUserOrganiztionId()).setParameter("id", selectedProcessId)
                    .list();
        }
        processes = filterPossibleCyclicDependencies(processes, selectedProcessId);
        if (actionsList == null) {
            actionsList = new JSONArray().toString();
        }

        if (emailAddress == null)
            emailAddress = getContext().getServletContext().getInitParameter("defaultToEmailAddress");

        if (subject == null)
            subject = getContext().getServletContext().getInitParameter("defaultSubject");
        
        return new ForwardResolution(CREATE_JSP);
    }    
    
    private List<Process> filterPossibleCyclicDependencies(List<Process> processes, Long selected){
        // loop af
            // zoek naar voren: haal per process alle processen op die de huidige als linked_process hebben en check tegen geselecteerd
            // zoek naar achteren: haal elk linked_process op, en check tegen geselecteerd
        List<Process> filteredList = new ArrayList<Process>();
        for (Process process : processes) {
            boolean backward = traverseBackward(process, selected);
            boolean forward =traverseForward(process, selected); 
            if(!backward && !forward){
                filteredList.add(process);
            }
        }
        return filteredList;
    }
    
    private boolean traverseForward(Process current,Long selected){
        List<Process> found = getLinkedProcesses(current);
        boolean isLinked = false;
        for (Process process : found) {
            if(process.getId().equals(selected) && !process.getLinkedProcess().getId().equals(linkedProcess)){
                isLinked=true;
                break;
            }
        }
        return isLinked;
    }
    
    private boolean traverseBackward(Process current,Long selected){
        boolean isFound = false;
        do{
            if(current.getLinkedProcess() != null ){
                if( current.getLinkedProcess().getId().equals(selected) && !current.getLinkedProcess().getId().equals(linkedProcess)){
                    isFound = true;
                    break;
                }
                current = current.getLinkedProcess();
            }
        }while(current.getLinkedProcess() != null);
        
        return isFound;
    }
    
    private List<Process> getLinkedProcesses(Process linked){
         
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        List<Process>found;
        if (isUserAdmin()) {
            found = session.createQuery("from Process where linked_process = :linked order by name").setParameter("linked", linked).list();
        } else {
            found = session.createQuery("from Process where organization_id = :org_id and linked_process = :linked"
                    + " order by name")
                    .setParameter("org_id", getUserOrganiztionId()).setParameter("linked", linked)
                    .list();
        }
        return found;
    }
    
    /* Deze methode wordt in /main/process/create.jsp aangeroepen. Back-end geeft
     * een JSONArray terug van een aantal actieblokken die je daar via de methode 
     * getDefaultActionBlocks() kunt opgeven. Let op: Als je mapping blokken opgeeft 
     * moet hiervoor eerst invoer/uitvoer kolommen klaargezet zijn. Deze kolommen
     * zijn nodig voor sommige constructors van actie blokken.
     */
    public Resolution createDefaultActionBlocks() {
        JSONArray obj = null;
        
        if (actionsList == null) {         
            obj = ActionsAction.createDefaultActionList(getContext());
        }
        
        return new JSONResolution(obj);
    }
    
    public Resolution processDiagram(){
        list();
        jsonProcesses = new JSONArray();
        for (Process process : processes) {
            JSONObject obj = process.toJSONObject();
            jsonProcesses.add(obj);

        }
        return new ForwardResolution(PROCESS_DIAGRAM_JSP);
    }

    public Resolution createComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout input = null;
        if (selectedFilePath == null) {
            input = (Inout)session.get(Inout.class, selectedInputId);
        } else {
            String fullPath = FileAction.getFileNameFromPPFileName(selectedFilePath, getContext());
            input = (Inout)session.createQuery("from Inout where file = :file")
                    .setParameter("file", fullPath)
                    .uniqueResult();
            if (input == null) {
                input = new Inout();
                input.setType(Inout.Type.INPUT);
                input.setDatatype(Inout.Datatype.FILE);
                input.setFile(fullPath);
                input.setName(selectedFilePath);
                
                input.setOrganizationId(getUserOrganiztionId());
                input.setUserId(getUserId());
                
                session.save(input);
            }
        }
        Inout output = (Inout)session.get(Inout.class, selectedOutputId);

        nl.b3p.datastorelinker.entity.Process process;
        if (selectedProcessId == null) {
            process = new nl.b3p.datastorelinker.entity.Process();
        } else {
            process = (nl.b3p.datastorelinker.entity.Process)
                    session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);
            
            Inout oldInput = process.getInput();
            if (oldInput.getDatatype() == Inout.Datatype.FILE &&
                    !oldInput.getFile().equals(input.getFile()) &&
                    oldInput.getInputProcessList().size() == 1) {
                // if this is the only process using this file input and
                // the input for this process is updated by the user, delete this file input object.
                // cut ties with process first to prevent cascades from kicking in
                // (deleting the process we are updating)
                log.debug("delete file input that is no longer used. (file itself is not deleted)");
                process.getInput().getInputProcessList().clear();
                process.getInput().getOutputProcessList().clear();
                session.delete(process.getInput());
            }
        }
        
        /* add organizationid and userid if the process is new. 
         * Else the user that made the process will stay the owner */
        if(process.getUserId() == null && process.getOrganizationId() == null){
            process.setOrganizationId(getUserOrganiztionId());
            process.setUserId(getUserId()); 
        }
        
        output.setOrganizationId(getUserOrganiztionId());
        output.setUserId(getUserId());
        
        process.setInput(input);
        process.setOutput(output);
        
        process.setActionsString(getActionsListJsonToXmlString());
        process.setDrop(drop);
        process.setAppend(append);
        process.setModify(modify);
        process.setModifyGeom(modifyGeom);
        
        Mail mail = null;
        if (process.getMail() == null)
            mail = new Mail();
        else
            mail = process.getMail();

        mail.setToEmailAddress(emailAddress);
        mail.setSubject(subject);
        //smtp host en from worden vanaf nu standaard leeg gelaten, 
        //als een andere host gebruikt moet worden dan de standaard 
        //dan moet dit in tabel handmatig worden ingesteld.
        //deze kolommen kunnen dus gewoon leeggemaakt worden.
        //mail.setFromEmailAddress(getContext().getServletContext().getInitParameter("defaultFromEmailAddress"));
        //mail.setSmtpHost(getContext().getServletContext().getInitParameter("defaultSmtpHost"));

        if (process.getMail() == null) {
            session.save(mail);
            process.setMail(mail);
        }

        if (process.getProcessStatus() == null) {
            ProcessStatus processStatus = ProcessStatus.getDefault();
            session.save(processStatus);
            process.setProcessStatus(processStatus);
        }
        
        process.setName(processName);
        process.setFilter(filter);
        process.setModifyFilter(modifyFilter);
        process.setRemarks(processRemark);
        if(linkedProcess != null && linkedProcess != -1){
            nl.b3p.datastorelinker.entity.Process link = em.find(Process.class, linkedProcess);
            process.setLinkedProcess(link);
        }else{
            process.setLinkedProcess(null);
        }
        if (selectedProcessId == null)
            selectedProcessId = (Long)session.save(process);

        return list();
    }

    private String getActionsListJsonToXmlString() {
        if (actionsList == null || actionsList.trim().equals("")) {
            actionsList = new JSONArray().toString();
        }         

        JSONArray actionsListJSONArray = JSONArray.fromObject(actionsList);

        ActionsAction.removeViewData(actionsListJSONArray);
        ActionsAction.addExpandableProperty(actionsListJSONArray);

        JSON actionsListJSON = JSONSerializer.toJSON(actionsListJSONArray);
        
        XMLSerializer xmlSerializer = new XMLSerializer();
        xmlSerializer.setArrayName("actions");
        xmlSerializer.setElementName("action");
        xmlSerializer.setExpandableProperties(new String[] {"parameter"});
        xmlSerializer.setTypeHintsEnabled(false);

        String actionsListXml = xmlSerializer.write(actionsListJSON);

        return actionsListXml;
    }

    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        selectedInputId = process.getInput().getId();
        if (process.getInput().getFile() != null && process.getInput().getFile().trim().length() > 0)
            selectedFilePath = FileAction.getFileNameRelativeToUploadDirPP(process.getInput().getFile(), getContext());
        selectedOutputId = process.getOutput().getId();
        actionsList = getActionsListXmlToJsonString(process);
        drop = process.getDrop();
        append = process.getAppend();
        modify = process.getModify();
        modifyGeom = process.getModifyGeom();
        emailAddress = process.getMail().getToEmailAddress();
        subject = process.getMail().getSubject();
        processName = process.getName();
        filter = process.getFilter();
        modifyFilter = process.getModifyFilter();
        processRemark = process.getRemarks();
        if(process.getLinkedProcess() != null){
            linkedProcess = process.getLinkedProcess().getId();
        }
        
        return create();
    }

    private String getActionsListXmlToJsonString(nl.b3p.datastorelinker.entity.Process process) {
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
        ActionsAction.addViewData(jsonArrayActions, getContext());
        log.debug("afterInsert: " + jsonArrayActions);
        //log.debug(actionsList);

        return jsonArrayActions.toString();
    }

    public Resolution delete() {
        PeriodicalProcessAction ppaction = new PeriodicalProcessAction();
        ppaction.cancelExecutePeriodicallyImpl(selectedProcessId, getContext().getServletContext());

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

        log.debug("delete process");
        Inout input = process.getInput();
        if (input.getFile() != null && !input.getFile().trim().equals("")) {
            input.getInputProcessList().remove(process);
        }

        List<nl.b3p.datastorelinker.entity.Process> linkedProcesses = em.createQuery("FROM Process WHERE linked_process = :id").setParameter("id", process).getResultList();
        for (nl.b3p.datastorelinker.entity.Process linked : linkedProcesses) {
            linked.setLinkedProcess(null);
        }    
            
        log.debug("delete process simple");
        session.delete(process);
        
        return list();
    }

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
            JobDetail jobDetail = JobBuilder.newJob(DataStoreLinkJob.class)
                    .withIdentity(generatedJobUUID)
                    .build();
            jobDetail.getJobDataMap().put("processId", process.getId());
            jobDetail.getJobDataMap().put("locale", getContext().getLocale());
            jobDetail.getJobDataMap().put(DataStoreLinkJob.KEY_DEFAULT_SMTP_HOST, getContext().getServletContext().getInitParameter("defaultSmtpHost"));
            jobDetail.getJobDataMap().put(DataStoreLinkJob.KEY_DEFAULT_FROM_ADDRESS, getContext().getServletContext().getInitParameter("defaultFromEmailAddress"));
            
            // Trigger trigger = TriggerUtils.makeImmediateTrigger(generatedJobUUID, 0, 0);
            Trigger trigger = TriggerBuilder.newTrigger()
                    .withIdentity(generatedJobUUID)
                    .forJob(jobDetail)
                    .startNow()
                    .build();
            //Trigger trigger = new SimpleTrigger("nowTrigger", new Date());
            Scheduler scheduler = SchedulerUtils.getScheduler(getContext().getServletContext());
            process.getProcessStatus().setProcessStatusType(ProcessStatus.Type.RUNNING);
            process.getProcessStatus().setExecutingJobUUID(generatedJobUUID);
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
            if (dslJob == null) {
                log.debug("dslJob null!");
                EntityManager em = JpaUtilServlet.getThreadEntityManager();
                Session session = (Session)em.getDelegate();

                ProcessStatus processStatus = (ProcessStatus)
                        session.createQuery("from ProcessStatus where executingJobUUID = :executingJobUUID")
                            .setParameter("executingJobUUID", jobUUID)
                            .uniqueResult();
                if (processStatus != null) {
                    log.debug("job has already finished.");
                    return new JSONResolution(new ProgressMessage(100, processStatus.getMessage()));
                } else {
                    log.debug("job is still starting up.");
                    return new JSONResolution(new ProgressMessage(0));
                }
            }  else {
                DataStoreLinker dsl = dslJob.getDataStoreLinker();
                if (dsl == null) {
                    log.debug("dsl null! dslJob niet, dus bezig met starten van job.");
                    return new JSONResolution(new ProgressMessage(0));
                } else if (dsl.isDisposed()) {
                    ProgressMessage progressMessage = new ProgressMessage(100);
                    progressMessage.setMessage(dsl.getStatus().getNonFatalErrorReport("<br />", 3));
                    return new JSONResolution(progressMessage);
                } else {
                    Status dslStatus = dsl.getStatus();

                    int visitedFeatures = dslStatus.getVisitedFeatures();
                    int totalFeatureSize = dslStatus.getTotalFeatureSize();

                    //log.debug("Gedaan: " + visitedFeatures + " / " + totalFeatureSize);
                    double fraction = 0.0;
                    if (totalFeatureSize > 0) {
                        fraction = (double)visitedFeatures / (double)totalFeatureSize;
                    }
                    int percentage = (int)Math.floor(100 * fraction);
                    ProgressMessage progressMessage = new ProgressMessage(percentage);
                    if (percentage >= 100) {
                        progressMessage = new ProgressMessage(99);
                    }
                    return new JSONResolution(progressMessage);
                }
            }
        } catch(Throwable t) {
            String message = new LocalizableMessage("fatalError").getMessage(getContext().getLocale())
                    + ": " + ExceptionUtils.getRootCauseMessage(t);
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
            String message = new LocalizableMessage("fatalError").getMessage(getContext().getLocale())
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
            String xml = MarshalUtils.marshalProcess(process);
            //String xml = MarshalUtils.marshalProcess(process, MarshalUtils.getDslSchema());
            // TODO: set filename als een geëscapedete procesnaam.
            return new StreamingResolution("text/xml", xml).setFilename("dsl_process.xml");
        } catch(Exception ex) {
            log.error(ex);
            return new DefaultErrorResolution(ex.getLocalizedMessage());
        }
    }
    
    public List<Inout> findInputs() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        List<Inout> list = new ArrayList();
        
        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            list = session.createQuery("from Inout where input_output_type = :type"
                + " and input_output_datatype = :datatype")
                .setParameter("type", Inout.TYPE_INPUT)
                .setParameter("datatype", Inout.TYPE_DATABASE)
                .list();
        } else {
            list = session.createQuery("from Inout where input_output_type = :type"
                + " and input_output_datatype = :datatype and organization_id = :orgid")
                .setParameter("type", Inout.TYPE_INPUT)
                .setParameter("datatype", Inout.TYPE_DATABASE)
                .setParameter("orgid", getUserOrganiztionId())
                .list();
        }
        
        Collections.sort(list, new NameableComparer());
        
        return list;
    }
    
    public List<Inout> findOutputs() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        List<Inout> list = new ArrayList();

        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            list = session.createQuery("from Inout where input_output_type = :type")
                .setParameter("type", Inout.TYPE_OUTPUT)
                .list();
        } else {            
            Organization org = (Organization)session.get(Organization.class, getUserOrganiztionId());
            list = org.getOutputs();
        }
        
        Collections.sort(list, new NameableComparer());
        
        return list;
    }

    //TODO: test: is output DB PostGIS (itt alleen Postgres)? merk je nu bij run als het goed is.

    public List<nl.b3p.datastorelinker.entity.Process> getProcesses() {
        return processes;
    }

    public void setProcesses(List<nl.b3p.datastorelinker.entity.Process> processes) {
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

    public boolean isAppend() {
        return append;
    }

    public void setAppend(boolean append) {
        this.append = append;
    }

    public boolean isDrop() {
        return drop;
    }

    public void setDrop(boolean drop) {
        this.drop = drop;
    }
    
    public boolean isModify(){
        return modify;
    }
    
    public void setModify(boolean modify){
        this.modify = modify;
    }

    public boolean isModifyGeom(){
        return modifyGeom;
    }
    
    public void setModifyGeom(boolean modifyGeom){
        this.modifyGeom =  modifyGeom;
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

    public String getSelectedFilePath() {
        return selectedFilePath;
    }

    public void setSelectedFilePath(String selectedFilePath) {
        this.selectedFilePath = selectedFilePath;
    }

    public String getProcessName() {
        return processName;
    }

    public void setProcessName(String processName) {
        this.processName = processName;
    }
    
    public String getFilter(){
        return filter;
    }
    
    public void setFilter(String filter){
        this.filter = filter;
    }
    
    public String getModifyFilter(){
        return modifyFilter;
    }
    
    public void setModifyFilter(String modifyFilter){
        this.modifyFilter = modifyFilter;
    }
    
    public String getProcessRemark() {
        return processRemark;
    }

    public void setProcessRemark(String processRemark) {
        this.processRemark = processRemark;
    }

    public Long getLinkedProcess() {
        return linkedProcess;
    }

    public void setLinkedProcess(Long linkedProcess) {
        this.linkedProcess = linkedProcess;
    }

    public JSONArray getJsonProcesses() {
        return jsonProcesses;
    }

    public void setJsonProcesses(JSONArray jsonProcesses) {
        this.jsonProcesses = jsonProcesses;
    }
}
