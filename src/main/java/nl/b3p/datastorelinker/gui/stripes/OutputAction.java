package nl.b3p.datastorelinker.gui.stripes;

import java.util.Collections;
import java.util.List;
import javax.persistence.EntityManager;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.util.NameableComparer;
import org.hibernate.Session;

/**
 *
 * @author Boy de Wit
 */
@Transactional
public class OutputAction extends DatabaseAction {
    private Log log = Log.getInstance(OutputAction.class);

    private List<Inout> outputs;
    private Long selectedOutputId;

    // dummy variable (not used but necessary; bit of a hack)
    private Boolean drop;
    private Boolean append;
    
    private String checkOutputId;

    @Override
    protected String getAdminJsp() {
        return "/WEB-INF/jsp/management/outputAdmin.jsp";
    }

    @Override
    protected String getCreateJsp() {
        return "/WEB-INF/jsp/main/output/create.jsp";
    }

    @Override
    protected String getListJsp() {
        return "/WEB-INF/jsp/main/output/list.jsp";
    }

    @Override
    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            outputs = session.createQuery("from Inout where input_output_type = :type")
                .setParameter("type", Inout.TYPE_OUTPUT)
                .list();
        } else {
            outputs = session.createQuery("from Inout where input_output_type = :type"
                + " and organization_id = :orgid")
                .setParameter("type", Inout.TYPE_OUTPUT)
                .setParameter("orgid", getUserOrganiztionId())
                .list();
        }
        
        Collections.sort(outputs, new NameableComparer());

        return new ForwardResolution(getListJsp());
    }

    public static List<Inout> findOutputs() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        List<Inout> list = session.getNamedQuery("Inout.find")
                .setParameter("typeName", Inout.Type.OUTPUT)
                .list();
        
        Collections.sort(list, new NameableComparer());
        return list;
    }
    
    public Resolution checkOutputIsUseTableTemplate() {
        JSONObject obj = null;        
        String outputType = null;
        
        if (checkOutputId != null) { 
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            Session session = (Session)em.getDelegate();

            Inout output = (Inout)session.get(Inout.class, new Long(checkOutputId));
            
            if (output != null) {
                outputType = output.getTemplateOutput();
            }
        }
        
        obj = new JSONObject();
        obj.put("type", outputType);
        
        return new JSONResolution(obj);
    }

    @Override
    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout selectedOutput = (Inout)session.get(Inout.class, selectedOutputId);

        selectedDatabaseId = selectedOutput.getDatabase().getId();

        return super.delete();
    }

    @Override
    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        Inout output = (Inout)session.get(Inout.class, selectedOutputId);

        selectedDatabaseId = output.getDatabase().getId();

        return super.update();
    }

    @Override
    public Resolution createComplete() {
        Database database = saveDatabase(Database.TypeInout.OUTPUT);

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout output;
        if (selectedOutputId == null)
            output = new Inout();
        else
            output = (Inout)session.get(Inout.class, selectedOutputId);

        output.setType(Inout.Type.OUTPUT);
        output.setDatatype(Inout.Datatype.DATABASE);
        output.setDatabase(database);
        // no tablename needed.
        
        /* add organizationid and userid if the output is new. 
         * Else the user that made the output will stay the owner */
        if(output.getUserId() == null && output.getOrganizationId() == null){
            output.setOrganizationId(getUserOrganiztionId());
            output.setUserId(getUserId());
        }

        if (selectedOutputId == null)
            selectedOutputId = (Long)session.save(output);

        return list();
    }

    public List<Inout> getOutputs() {
        return outputs;
    }

    public void setOutputs(List<Inout> outputs) {
        this.outputs = outputs;
    }

    public Long getSelectedOutputId() {
        return selectedOutputId;
    }

    public void setSelectedOutputId(Long selectedOutputId) {
        this.selectedOutputId = selectedOutputId;
    }

    public Boolean getDrop() {
        return drop;
    }

    public void setDrop(Boolean drop) {
        this.drop = drop;
    }

    public Boolean getAppend() {
        return append;
    }

    public void setAppend(Boolean append) {
        this.append = append;
    }

    public String getCheckOutputId() {
        return checkOutputId;
    }

    public void setCheckOutputId(String checkOutputId) {
        this.checkOutputId = checkOutputId;
    }
}
