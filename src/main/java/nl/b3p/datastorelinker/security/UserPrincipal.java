package nl.b3p.datastorelinker.security;

import java.security.Principal;
import javax.servlet.http.HttpServletRequest;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.securityfilter.filter.SecurityRequestWrapper;

/**
 *
 * @author Boy de Wit
 */
public class UserPrincipal implements Principal {
    
    private static final Log log = LogFactory.getLog(UserPrincipal.class);
    
    private Integer userId;
    private String userName;
    private Boolean userIsAdmin;
    private Integer userOrganizationId;

    public UserPrincipal() {
    }

    public UserPrincipal(String userName, Boolean userIsAdmin, Integer userOrganizationId) {
        this.userName = userName;
        this.userIsAdmin = userIsAdmin;
        this.userOrganizationId = userOrganizationId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Boolean getUserIsAdmin() {
        return userIsAdmin;
    }

    public void setUserIsAdmin(Boolean userIsAdmin) {
        this.userIsAdmin = userIsAdmin;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Integer getUserOrganizationId() {
        return userOrganizationId;
    }

    public void setUserOrganizationId(Integer userOrganizationId) {
        this.userOrganizationId = userOrganizationId;
    }

    public String getName() {
        return userName;
    }
    
    public static UserPrincipal getUserPrincipal(HttpServletRequest request) {
        Principal user = request.getUserPrincipal();
        if (!(user instanceof UserPrincipal && request instanceof SecurityRequestWrapper)) {
            return null;
        }
        
        UserPrincipal up = (UserPrincipal) user;
        
        if (up != null) {
            SecurityRequestWrapper srw = (SecurityRequestWrapper) request;
            srw.setUserPrincipal(up);
            log.debug("Automatic login for user: " + up.getUserName());
        }
        
        return up;
    }    
}
