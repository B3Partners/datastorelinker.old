/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.security.Principal;
import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.ActionBeanContext;
import nl.b3p.datastorelinker.security.UserPrincipal;

/**
 *
 * @author Erik van de Pol
 */
public class DefaultAction implements ActionBean {
    private ActionBeanContext context;
    
    public void setContext(ActionBeanContext context) {
        this.context = context;
    }

    public ActionBeanContext getContext() {
        return context;
    }
    
    protected boolean isUserAdmin() {
        Principal principal = getContext().getRequest().getUserPrincipal();
        if (principal != null && principal instanceof UserPrincipal) {
            UserPrincipal user = (UserPrincipal) principal;
            
            if (user.getUserIsAdmin()) {
                return true;
            }
        } 
        
        return false;
    }
    
    protected Integer getUserOrganiztionId() {
        Principal principal = getContext().getRequest().getUserPrincipal();
        if (principal != null && principal instanceof UserPrincipal) {
            UserPrincipal user = (UserPrincipal) principal;
            
            return user.getUserOrganizationId();
        } 
        
        return null;
    }
    
    protected Integer getUserId() {
        Principal principal = getContext().getRequest().getUserPrincipal();
        if (principal != null && principal instanceof UserPrincipal) {
            UserPrincipal user = (UserPrincipal) principal;
            
            return user.getUserId();
        } 
        
        return null;
    }
    
    protected String getUploadPath() {
        String path = getContext().getServletContext().getInitParameter("uploadDirectory");
        
        return path;
    }
}
