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
import net.sourceforge.stripes.validation.Validate;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.publish.GeoserverPublisher;
import nl.b3p.datastorelinker.publish.Publisher;
import nl.b3p.datastorelinker.util.NameableComparer;
import org.hibernate.Session;

/**
 *
 * @author Meine Toonen
 */
@Transactional
public class OutputServicesAction extends DefaultAction {

    private final static String MAIN_JSP = "/WEB-INF/jsp/management/outputServicesAdmin.jsp";
    private final static String PUBLISH_JSP = "/WEB-INF/jsp/main/output_services/publish.jsp";
    private final static String LIST_JSP = "/WEB-INF/jsp/main/output_services/list.jsp";
    
    private List<Inout> inputs;
    private Long selectedDatabaseId;
    
    @Validate
    private String publisherType;

    @DefaultHandler
    public Resolution view() {
        list();
        return new ForwardResolution(MAIN_JSP);
    }
    
    public Resolution publish(){
        
        return new ForwardResolution(PUBLISH_JSP);
    }
    
    
    public Resolution createComplete(){
        Publisher publisher = null;
        if(publisherType.equals(Publisher.PUBLISHER_TYPE_GEOSERVER)){
            publisher = new GeoserverPublisher();
        }else {
            throw new IllegalArgumentException("Publisher type not yet implemented");
        }
        
        publisher.publishDb(MAIN_JSP, MAIN_JSP, MAIN_JSP, MAIN_JSP, MAIN_JSP, MAIN_JSP, MAIN_JSP, MAIN_JSP, MAIN_JSP, MAIN_JSP);
        
        list();
        return new ForwardResolution(LIST_JSP);
    }
    
    public void list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

       
        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            inputs = session.createQuery("from Inout where input_output_type = :type")
                .setParameter("type", Inout.TYPE_OUTPUT)
                .list();
        } else {
            inputs = session.createQuery("from Inout where input_output_type = :type"
                + " and organization_id = :orgid")
                .setParameter("type", Inout.TYPE_OUTPUT)
                .setParameter("orgid", getUserOrganiztionId())
                .list();
        }
        
        Collections.sort(inputs, new NameableComparer());

    }

    //<editor-fold defaultstate="collapsed" desc="Getters and setters">
    public List<Inout> getInputs() {
        return inputs;
    }

    public void setInputs(List<Inout> inputs) {
        this.inputs = inputs;
    }

    public Long getSelectedDatabaseId() {
        return selectedDatabaseId;
    }

    public void setSelectedDatabaseId(Long selectedDatabaseId) {
        this.selectedDatabaseId = selectedDatabaseId;
    }

    public String getPublisherType() {
        return publisherType;
    }

    public void setPublisherType(String publisherType) {
        this.publisherType = publisherType;
    }

    //</editor-fold>

}
