/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Inout;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
public class ProcessOverviewAction extends DefaultAction {

    private final static Log log = Log.getInstance(ProcessOverviewAction.class);
    
    private final static String JSP = "/pages/processOverview.jsp";
    private final static String NEW_PROCESS_JSP = "/pages/newProcess.jsp";
    private final static String EXECUTE_PROCESS_JSP = "/pages/executeProcess.jsp";
    
    private List<Process> processes;
    
    private List<Inout> inputs;
    private List<Inout> inputsFile;
    private List<Inout> inputsDB;
    private List<Inout> outputs;
    
    private Long processId;
    private Long inputId;
    private Long outputId;
    private Long actionsId;
    

    @DefaultHandler
    public Resolution processesOverview() {
        //ValidationErrors errors = new ValidationErrors();

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        // moet even wat hulp krijgen om die order by's goed te krijgen
        // (te maken met de dot-notation voor joins die niet werkt zoals ik denk dat ie werkt.).
        processes = session.createQuery("from Process order by name").list();

        /*if (!errors.isEmpty()) {
        getContext().setValidationErrors(errors);
        return getContext().getSourcePageResolution();
        }*/

        return new ForwardResolution(JSP);
    }

    public Resolution new_() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        inputs = session.createQuery("from Inout where typeId = 1").list();
        inputsFile = session.createQuery("from Inout where typeId = 1 and datatypeId = 2").list();
        inputsDB = session.createQuery("from Inout where typeId = 1 and datatypeId = 1").list();
        outputs = session.createQuery("from Inout where typeId = 2").list();
        
        return new ForwardResolution(NEW_PROCESS_JSP);
    }

    @Transactional
    public Resolution newComplete() {
        log.debug("newComplete; inputId: " + inputId);
        log.debug("newComplete; outputId: " + outputId);
        //log.debug("newComplete; actionsId: " + actionsId);

        // ...

        return processesOverview(); // TODO: auto-select just created process
    }

    public Resolution edit() {
        return new ForwardResolution(JSP);
    }

    public Resolution delete() {
        return new ForwardResolution(JSP);
    }

    public Resolution execute() {
        log.debug("Executing process with id: " + processId);

        // ...
        
        return new ForwardResolution(EXECUTE_PROCESS_JSP);
    }

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

    public Long getProcessId() {
        return processId;
    }

    public void setProcessId(Long processId) {
        this.processId = processId;
    }

    public Long getInputId() {
        return inputId;
    }

    public void setInputId(Long inputId) {
        this.inputId = inputId;
    }

    public Long getOutputId() {
        return outputId;
    }

    public void setOutputId(Long outputId) {
        this.outputId = outputId;
    }

    public Long getActionsId() {
        return actionsId;
    }

    public void setActionsId(Long actionsId) {
        this.actionsId = actionsId;
    }
}
