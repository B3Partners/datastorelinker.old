/*
 * B3P Gisviewer is an extension to Flamingo MapComponents making
 * it a complete webbased GIS viewer and configuration tool that
 * works in cooperation with B3P Kaartenbalie.
 *
 * Copyright 2006, 2007, 2008 B3Partners BV
 * 
 * This file is part of B3P Gisviewer.
 * 
 * B3P Gisviewer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * B3P Gisviewer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with B3P Gisviewer.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.b3p.datastorelinker.security;

import java.security.Principal;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import nl.b3p.wms.capabilities.Roles;
import nl.b3p.wms.capabilities.ServiceProvider;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.securityfilter.filter.SecurityRequestWrapper;

public class GisPrincipal implements Principal {
    public static final String URL_AUTH = "code";
    private static final Log log = LogFactory.getLog(GisPrincipal.class);
    private String name;
    private String password;
    /*TODO ipv code misschien hele kaartenbalie url??? */
    private String code;
    private Set roles;
    private ServiceProvider sp;

    public GisPrincipal(String name, List roles) {
        this.name = name;
        this.roles = new HashSet();
        this.roles.addAll(roles);
    }

    public GisPrincipal(String name, String password, String code, ServiceProvider sp) {
        this.name = name;
        this.password = password;
        this.code = code;
        this.sp = sp;
        if (sp == null) {
            return;
        }
        this.roles = new HashSet();
        Set sproles = sp.getAllRoles();
        if (sproles == null || sproles.isEmpty()) {
            return;
        }
        Iterator it = sproles.iterator();
        while (it.hasNext()) {
            Roles role = (Roles) it.next();
            String sprole = role.getRole();
            if (sprole != null && sprole.length() > 0) {
                roles.add(sprole);
            }
        }
    }

    public String getName() {
        return name;
    }

    public String getPassword() {
        return password;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public boolean isInRole(String role) {
        if (roles==null){
            return false;
        }
        return roles.contains(role);
    }

    public Set getRoles() {
        return roles;
    }

    public String toString() {
        return "GisPrincipal[name=" + name + "]";
    }

    /* TODO: implement equals/hashCode */
    public ServiceProvider getSp() {
        return sp;
    }

    public void setSp(ServiceProvider sp) {
        this.sp = sp;
    }   

    public static GisPrincipal getGisPrincipal(HttpServletRequest request) {
        Principal user = request.getUserPrincipal();
        if (!(user instanceof GisPrincipal && request instanceof SecurityRequestWrapper)) {
            return null;
        }
        GisPrincipal gp = (GisPrincipal) user;

        String code = request.getParameter(URL_AUTH);
        if (code != null && code.length() != 0) {
            if (gp!=null && code.equals(gp.getCode())) {
                return gp;
            }

            // user is using different code, so invalidate session and login again
            HttpSession session = request.getSession();
            session.invalidate();
            //String url = GisSecurityRealm.createCapabilitiesURL(code);
            //gp = GisSecurityRealm.authenticateHttp(url, ConfigServlet.ANONYMOUS_USER, null, code);
        }

        // log in found principal
        if (gp != null) {
            SecurityRequestWrapper srw = (SecurityRequestWrapper) request;
            srw.setUserPrincipal(gp);
            log.debug("Automatic login for user: " + gp.name);
        }
        return gp;
    }
}
