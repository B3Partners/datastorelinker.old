package nl.b3p.datastorelinker.gui.stripes;

import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Organization;
import org.hibernate.Session;

/**
 *
 * @author Boy de Wit
 */
@Transactional
public class AuthorizationAction extends DefaultAction {
    private final static Log log = Log.getInstance(AuthorizationAction.class);

    /* vars voor formwards */
    private final static String LIST_ORGS_JSP = "/WEB-INF/jsp/main/auth/orgs/list.jsp";
    private final static String CREATE_ORG_JSP = "/WEB-INF/jsp/main/auth/orgs/create.jsp";
    private final static String ADMIN_JSP = "/WEB-INF/jsp/management/authAdmin.jsp";

    /* vars voor crud */
    private List<Organization> orgs;
    private Long selectedOrgId;    
    private Organization selectedOrg;
    
    /* vars voor forms */
    private String name;
    private String upload_path;           

    @DefaultHandler
    public Resolution admin() {
        list_orgs();
        return new ForwardResolution(ADMIN_JSP);
    }

    public Resolution list_orgs() {
        orgs = getOrganizations();

        return new ForwardResolution(LIST_ORGS_JSP);
    }
    
    public static List<Organization> getOrganizations() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        List orgs = sess.createQuery("from Organization order by name").list();
        
        return orgs;
    }

    public Resolution deleteOrganization() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        sess.delete(sess.get(Organization.class, selectedOrgId));

        return list_orgs();
    }

    public Resolution updateOrganization() {
        /* Geselecteerde organisatie ophalen */
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        if (selectedOrgId != null) {
            selectedOrg = (Organization)sess.get(Organization.class, selectedOrgId);
        }

        return new ForwardResolution(CREATE_ORG_JSP);
    }

    public Resolution createOrganization() {
        return new ForwardResolution(CREATE_ORG_JSP);
    }

    public Resolution createOrganizationComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        if (selectedOrgId != null) {
            selectedOrg = (Organization)sess.get(Organization.class, selectedOrgId);
        }  

        Organization org = null;
        if (selectedOrg == null) {
            org = new Organization();
        } else {
            org = selectedOrg;
        } 

        /* Fill and save org */
        org.setName(name);
        org.setUploadPath(upload_path);
        
        if (selectedOrgId == null) {
            selectedOrgId = (Long)sess.save(org);
        } else {
            sess.update(org);
        }

        return list_orgs();
    }

    public List<Organization> getOrgs() {
        return orgs;
    }

    public void setOrgs(List<Organization> orgs) {
        this.orgs = orgs;
    }

    public Long getSelectedOrgId() {
        return selectedOrgId;
    }

    public void setSelectedOrgId(Long selectedOrgId) {
        this.selectedOrgId = selectedOrgId;
    }

    public Organization getSelectedOrg() {
        return selectedOrg;
    }

    public void setSelectedOrg(Organization selectedOrg) {
        this.selectedOrg = selectedOrg;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getUpload_path() {
        return upload_path;
    }

    public void setUpload_path(String upload_path) {
        this.upload_path = upload_path;
    }
}