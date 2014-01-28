/*
 * Copyright (C) 2014 B3Partners B.V.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.util.Collections;
import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.util.NameableComparer;
import org.hibernate.Session;

/**
 *
 * @author Meine Toonen
 */
public class OutputServicesAction extends DefaultAction {

    private final static String MAIN_JSP = "/WEB-INF/jsp/management/outputServicesAdmin.jsp";
    private final static String PUBLISH_JSP = "/WEB-INF/jsp/main/output_services/publish.jsp";
    
    private List<Database> databases;
    private Long selectedDatabaseId;

    @DefaultHandler
    public Resolution view() {
        list();
        return new ForwardResolution(MAIN_JSP);
    }
    
    public Resolution publish(){
        
        return new ForwardResolution(PUBLISH_JSP);
    }

    public void list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            databases = session.createQuery("from Database where inout_type = :type")
                    .setParameter("type", Inout.TYPE_OUTPUT)
                    .list();
        } else {
            databases = session.createQuery("from Database where inout_type = :type"
                    + " and organization_id = :orgid")
                    .setParameter("type", Inout.TYPE_OUTPUT)
                    .setParameter("orgid", getUserOrganiztionId())
                    .list();
        }

        Collections.sort(databases, new NameableComparer());
    }

    //<editor-fold defaultstate="collapsed" desc="Getters and setters">
    public List<Database> getDatabases() {
        return databases;
    }

    public void setDatabases(List<Database> databases) {
        this.databases = databases;
    }

    public Long getSelectedDatabaseId() {
        return selectedDatabaseId;
    }

    public void setSelectedDatabaseId(Long selectedDatabaseId) {
        this.selectedDatabaseId = selectedDatabaseId;
    }

    //</editor-fold>
}
