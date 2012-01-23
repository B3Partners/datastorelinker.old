package nl.b3p.datastorelinker.gui.stripes;

import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import net.sourceforge.stripes.validation.Validate;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.entity.Organization;
import nl.b3p.datastorelinker.json.JSONResolution;
import org.hibernate.Session;

/**
 *
 * @author Boy de Wit
 */
@Transactional
public class OutputRightsAction extends DefaultAction {
    private final static Log log = Log.getInstance(OutputRightsAction.class);
    
    /* jsp's */
    private final static String ADMIN_RIGHTS_JSP = "/WEB-INF/jsp/management/outputRightsAdmin.jsp";
    private final static String LIST_OUTPUTS_JSP = "/WEB-INF/jsp/main/output_rights/list.jsp";
    private final static String CREATE_RIGHTS_JSP = "/WEB-INF/jsp/main/output_rights/create.jsp";    

    /* vars */
    private List<Inout> outputs;
    private List<Organization> orgs;
    
    private Integer selectedOutputId;
    private Inout selectedOutput;
    
    /* vars voor organisatie forms */
    @Validate(required=false, on="createOutputRightsComplete")
    private String organizationIds;
    
    private List<Organization> selectedOrgIds;

    @DefaultHandler
    public Resolution admin() {
        list();
        return new ForwardResolution(ADMIN_RIGHTS_JSP);
    }
    
    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        outputs = sess.createQuery("from Inout where input_output_type = :type")
                .setParameter("type", Inout.TYPE_OUTPUT)
                .list();

        return new ForwardResolution(LIST_OUTPUTS_JSP);
    }

    public Resolution updateOutputRights() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        if (selectedOutputId != null) {
            selectedOutput = (Inout)sess.get(Inout.class, new Long(selectedOutputId));
            selectedOrgIds = selectedOutput.getOrganizations();
        }
        
        orgs = sess.createQuery("from Organization order by name").list();  

        return new ForwardResolution(CREATE_RIGHTS_JSP);
    }
    
    public Resolution fillSelectedOrganizationIds() {
        JSONArray jsonArray = null;
        
        if (selectedOutputId != null) { 
            jsonArray = new JSONArray();
            
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            Session session = (Session)em.getDelegate();

            Inout output = (Inout)session.get(Inout.class, new Long(selectedOutputId));
            
            if (output != null) {
                List<Organization> lijst = output.getOrganizations();
                
                for (Organization org : lijst) {
                    JSONObject obj = new JSONObject();
                    obj.put("id", org.getId());
                    
                    jsonArray.add(obj);
                }
            }
        }
        
        return new JSONResolution(jsonArray);
    }

    public Resolution createOutputRights() {
        return new ForwardResolution(CREATE_RIGHTS_JSP);
    }

    public Resolution createOutputRightsComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();
        
        if (selectedOutputId != null) {
            selectedOutput = (Inout)sess.get(Inout.class, new Long(selectedOutputId));
        }  
        
        /* Opslaan rechten voor gekozen organisaties */
        List<Organization> list = new ArrayList();        
        if (organizationIds != null && !organizationIds.equals("") && selectedOutput != null) { 
            String[] ids = organizationIds.trim().split(",");
            
            for (String id : ids) {
                if (id != null && !id.equals("")) {
                    Organization org = (Organization)sess.get(Organization.class, new Integer(id));
                    list.add(org);
                }
            }
            
            selectedOutput.setOrganizations(list);
            sess.save(selectedOutput);
        } else {
            selectedOutput.setOrganizations(null);
            sess.save(selectedOutput);
        }

        return list();
    }

    public List<Inout> getOutputs() {
        return outputs;
    }

    public void setOutputs(List<Inout> outputs) {
        this.outputs = outputs;
    }

    public Inout getSelectedOutput() {
        return selectedOutput;
    }

    public void setSelectedOutput(Inout selectedOutput) {
        this.selectedOutput = selectedOutput;
    }

    public Integer getSelectedOutputId() {
        return selectedOutputId;
    }

    public void setSelectedOutputId(Integer selectedOutputId) {
        this.selectedOutputId = selectedOutputId;
    }

    public List<Organization> getOrgs() {
        return orgs;
    }

    public void setOrgs(List<Organization> orgs) {
        this.orgs = orgs;
    }

    public String getOrganizationIds() {
        return organizationIds;
    }

    public void setOrganizationIds(String organizationIds) {
        this.organizationIds = organizationIds;
    }

    public List<Organization> getSelectedOrgIds() {
        return selectedOrgIds;
    }

    public void setSelectedOrgIds(List<Organization> selectedOrgIds) {
        this.selectedOrgIds = selectedOrgIds;
    }
}