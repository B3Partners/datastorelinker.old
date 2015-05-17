package nl.b3p.datastorelinker.gui.stripes;

import java.io.File;
import java.security.Principal;
import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.services.FormUtils;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Organization;
import nl.b3p.datastorelinker.entity.Users;
import nl.b3p.datastorelinker.security.UserPrincipal;
import nl.b3p.ogc.utils.KBCrypter;
import org.hibernate.Session;

/**
 *
 * @author Boy de Wit
 */
@Transactional
public class AuthorizationAction extends DefaultAction {
    private final static Log log = Log.getInstance(AuthorizationAction.class);
    
    /* vars voor organisatie form */
    private final static String ADMIN_ORG_JSP = "/WEB-INF/jsp/management/authOrgAdmin.jsp";
    private final static String LIST_ORGS_JSP = "/WEB-INF/jsp/main/auth/orgs/list.jsp";
    private final static String CREATE_ORG_JSP = "/WEB-INF/jsp/main/auth/orgs/create.jsp";    

    /* vars voor organisatie crud */
    private List<Organization> orgs;
    private Integer selectedOrgId;    
    private Organization selectedOrg;
    
    /* vars voor organisatie forms */
    private String orgName;    
    private String orgUploadPath;  
    
    /* vars voor users form */
    private final static String ADMIN_USERS_JSP = "/WEB-INF/jsp/management/authUsersAdmin.jsp";
    private final static String LIST_USERS_JSP = "/WEB-INF/jsp/main/auth/users/list.jsp";
    private final static String CREATE_USER_JSP = "/WEB-INF/jsp/main/auth/users/create.jsp"; 
    
    /* vars voor users crud */
    private List<Users> userList;
    private Integer selectedUserId;    
    private Users selectedUser;
    
    /* vars voor users forms */
    private String userName;    
    private String userPassword;
    private String userPasswordAgain;
    private Boolean userIsAdmin = false;
    private Integer userOrgId;

    @DefaultHandler
    public Resolution admin_org() {
        list_orgs();
        return new ForwardResolution(ADMIN_ORG_JSP);
    }
    
    public Resolution admin_users() {
        list_users();
        return new ForwardResolution(ADMIN_USERS_JSP);
    }
    
    public Resolution list_orgs() {
        orgs = getOrganizations();

        return new ForwardResolution(LIST_ORGS_JSP);
    }
    
    public Resolution list_users() {
        userList = getUsers();

        return new ForwardResolution(LIST_USERS_JSP);
    }
    
    public static List<Users> getUsers() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        List users = sess.createQuery("from Users order by name").list();
        
        return users;
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
        
        /* Cannot remove default beheerder organization */
        if (selectedOrgId != null && selectedOrgId == 1) {
            return list_orgs();
        }
        
        if (selectedOrgId != null) {
            Organization org = (Organization)sess.get(Organization.class, selectedOrgId);        
            sess.delete(org);
        }

        return list_orgs();
    }
    
    public Resolution deleteUser() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        /* Cannot remove default beheerder user */
        if (selectedUserId != null && selectedUserId == 1) {
            return list_orgs();
        }
        
        /* User can not remove himself */
        Principal principal = getContext().getRequest().getUserPrincipal();
        if (principal != null && principal instanceof UserPrincipal) {
            UserPrincipal user = (UserPrincipal) principal;
            if(user.getUserId().equals(selectedUserId)){
                return list_orgs();
            }
        }
        
        if (selectedUserId != null) {
            Users user = (Users)sess.get(Users.class, selectedUserId);
            sess.delete(user);
        }

        return list_users();
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
    
    public Resolution updateUser() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        if (selectedUserId != null) {
            selectedUser = (Users)sess.get(Users.class, selectedUserId);
        }
        
        orgs = getOrganizations();

        return new ForwardResolution(CREATE_USER_JSP);
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
        org.setName(orgName);
        
        /* upload folder aanmaken voor organisatie */ 
        String uploadFolder = orgName.replace(" ", "_").toLowerCase();        
        File file = new File(getUploadPath() + File.separator + uploadFolder);
        if (!file.exists()) {
            file.mkdir();
        }
        
        org.setUploadPath(uploadFolder);
        
        if (selectedOrgId == null) {
            selectedOrgId = (Integer)sess.save(org);
        } else {
            sess.update(org);
        }

        return list_orgs();
    }
    
    public Resolution createUser() {
        /* Lijstje organisaties klaarzetten */
        orgs = getOrganizations();
        
        return new ForwardResolution(CREATE_USER_JSP);
    }
    
    public Resolution createUserComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        if (selectedUserId != null) {
            selectedUser = (Users)sess.get(Users.class, selectedUserId);
        }  

        Users user = null;
        if (selectedUser == null) {
            user = new Users();
        } else {
            user = selectedUser;
        }
        
        Organization org = null;
        if (userOrgId != null) {
            org = (Organization)sess.get(Organization.class, userOrgId);
        }
        
        if (org != null) {            
            user.setOrganization(org);
        }
        
        user.setName(userName);        
        
        if (userPassword != null && userPassword.equals(userPasswordAgain)) {
            user.setPassword(encryptUserPassword(userPassword));
        }    
        
        user.setIsAdmin(userIsAdmin);                  
        
        if (selectedUserId == null) {
            selectedUserId = (Integer)sess.save(user);
        } else {
            sess.update(user);
        }

        return list_users();
    }
    
    private String encryptUserPassword(String password) {
        String encpw = null;
        
        try {
            encpw = KBCrypter.encryptText(FormUtils.nullIfEmpty(password));
        } catch (Exception ex) {
            log.debug("Fout tijdens encrypten van wachtwoord.");
        }
        
        return encpw;
    }

    public List<Organization> getOrgs() {
        return orgs;
    }

    public void setOrgs(List<Organization> orgs) {
        this.orgs = orgs;
    }

    public Integer getSelectedOrgId() {
        return selectedOrgId;
    }

    public void setSelectedOrgId(Integer selectedOrgId) {
        this.selectedOrgId = selectedOrgId;
    }

    public Organization getSelectedOrg() {
        return selectedOrg;
    }

    public void setSelectedOrg(Organization selectedOrg) {
        this.selectedOrg = selectedOrg;
    }

    public String getOrgName() {
        return orgName;
    }

    public void setOrgName(String orgName) {
        this.orgName = orgName;
    }

    public String getOrgUploadPath() {
        return orgUploadPath;
    }

    public void setOrgUploadPath(String orgUploadPath) {
        this.orgUploadPath = orgUploadPath;
    }

    public Users getSelectedUser() {
        return selectedUser;
    }

    public void setSelectedUser(Users selectedUser) {
        this.selectedUser = selectedUser;
    }

    public Integer getSelectedUserId() {
        return selectedUserId;
    }

    public void setSelectedUserId(Integer selectedUserId) {
        this.selectedUserId = selectedUserId;
    }

    public Boolean getUserIsAdmin() {
        return userIsAdmin;
    }

    public void setUserIsAdmin(Boolean userIsAdmin) {
        this.userIsAdmin = userIsAdmin;
    }

    public List<Users> getUserList() {
        return userList;
    }

    public void setUserList(List<Users> userList) {
        this.userList = userList;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserPassword() {
        return userPassword;
    }

    public void setUserPassword(String userPassword) {
        this.userPassword = userPassword;
    }

    public String getUserPasswordAgain() {
        return userPasswordAgain;
    }

    public void setUserPasswordAgain(String userPasswordAgain) {
        this.userPasswordAgain = userPasswordAgain;
    }

    public Integer getUserOrgId() {
        return userOrgId;
    }

    public void setUserOrgId(Integer userOrgId) {
        this.userOrgId = userOrgId;
    }
}