package nl.b3p.datastorelinker.security;

import java.security.Principal;
import javax.persistence.EntityManager;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.services.FormUtils;
import nl.b3p.datastorelinker.entity.Users;
import nl.b3p.ogc.utils.KBCrypter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Session;
import org.securityfilter.filter.SecurityRequestWrapper;
import org.securityfilter.realm.ExternalAuthenticatedRealm;
import org.securityfilter.realm.FlexibleRealmInterface;

public class GisSecurityRealm implements FlexibleRealmInterface, ExternalAuthenticatedRealm {
    private static final Log log = LogFactory.getLog(GisSecurityRealm.class);
    
    private static final String FORM_USERNAME = "j_username";
    private static final String FORM_PASSWORD = "j_password";

    public Principal authenticate(SecurityRequestWrapper request) {
        String username = FormUtils.nullIfEmpty(request.getParameter(FORM_USERNAME));
        String password = FormUtils.nullIfEmpty(request.getParameter(FORM_PASSWORD));
        
        return authenticateHttp(username, password);
    }   
    
    public Principal authenticate(String username, String password) {
        return authenticateHttp(username, password);
    }

    public Principal getAuthenticatedPrincipal(String username, String password) {
        return authenticateHttp(username, password);
    }

    public static UserPrincipal authenticateHttp(String username, String password) {
        /* Kijken in users tabel */
        String encpw = encryptUserPassword(password);
        
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session sess = (Session)em.getDelegate();

        Users user = (Users)sess.createQuery("from Users where name = :name and"
                + " password = :passw")
                .setParameter("name", username)
                .setParameter("passw", encpw)
                .setMaxResults(1)
                .uniqueResult();
        
        if (user != null) {
            UserPrincipal up = new UserPrincipal();
            up.setUserId(user.getId());
            up.setUserName(user.getName());
            up.setUserIsAdmin(user.getIsAdmin());
            up.setUserOrganizationId(user.getOrganization().getId()); 
            
            log.debug("Login: " + up.getUserName());
            
            return up;
        }        
        
        return null;
    }    

    public boolean isUserInRole(Principal principal, String rolename) {        
        if (principal instanceof UserPrincipal) {
            UserPrincipal user = (UserPrincipal) principal;
            
            if (user.getUserIsAdmin()) {
                return true;
            }
            
            if (!user.getUserIsAdmin() && rolename.equals("gebruiker")) {
                return true;
            }
        }
        
        return false;
    }
    
    private static String encryptUserPassword(String password) {
        String encpw = null;
        
        try {
            encpw = KBCrypter.encryptText(FormUtils.nullIfEmpty(password));
        } catch (Exception ex) {
            log.debug("Fout tijdens encrypten van wachtwoord.");
        }
        
        return encpw;
    }
}
