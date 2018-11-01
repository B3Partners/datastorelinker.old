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
import javax.servlet.ServletContext;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.SimpleMessage;
import net.sourceforge.stripes.util.Log;
import net.sourceforge.stripes.validation.SimpleError;
import net.sourceforge.stripes.validation.Validate;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.publish.GeoserverPublisher;
import nl.b3p.datastorelinker.publish.MapserverPublisher;
import nl.b3p.datastorelinker.publish.PublishStatus;
import nl.b3p.datastorelinker.publish.Publisher;
import nl.b3p.datastorelinker.util.NameableComparer;
import nl.b3p.geotools.data.linker.util.DataStoreUtil;
import nl.b3p.geotools.data.linker.util.DataTypeList;
import org.hibernate.Session;

/**
 *
 * @author Meine Toonen
 * @author mprins
 */
@Transactional
public class OutputServicesAction extends DefaultAction {

    private final static Log log = Log.getInstance(OutputServicesAction.class);
    private final static String MAIN_JSP = "/WEB-INF/jsp/management/outputServicesAdmin.jsp";
    private final static String PUBLISH_JSP = "/WEB-INF/jsp/main/output_services/publish.jsp";
    private final static String LIST_JSP = "/WEB-INF/jsp/main/output_services/list.jsp";
    private List<Database> databases;
    private List<String> tables;
    private String selectedTables;
    private Long selectedDatabaseId;
    @Validate
    private String publisherType;
    
    private String namePublisher;

    @DefaultHandler
    public Resolution view() {
        list();
        return new ForwardResolution(MAIN_JSP);
    }

    public Resolution publish() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        Database selectedDatabase = (Database) session.get(Database.class, selectedDatabaseId);

        try {
            DataTypeList dataTypeList = DataStoreUtil.getDataTypeList(selectedDatabase.toGeotoolsDataStoreParametersMap());

            if (dataTypeList != null) {
                tables = dataTypeList.getGood();

            } else {
                throw new Exception("Error getting datatypes from DataStore.");
            }
        } catch (Exception e) {
            String tablesError = "Fout bij ophalen tabellen. ";
            log.error(tablesError + e.getMessage());
        }
        return new ForwardResolution(PUBLISH_JSP);
    }

    public Resolution createComplete() {
        Publisher publisher = null;
        if (publisherType.equals(Publisher.PUBLISHER_TYPE_GEOSERVER)) {
            publisher = new GeoserverPublisher();
        } else if (publisherType.equals(Publisher.PUBLISHER_TYPE_MAPSERVER)) {
            publisher = new MapserverPublisher();
        } else {
            throw new IllegalArgumentException("Publisher type not yet implemented");
        }

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Database database = em.find(Database.class, selectedDatabaseId);

        if (database.getType() == Database.Type.POSTGIS || database.getType() == Database.Type.ORACLE) {
            ServletContext c = getContext().getServletContext();
            publisher.setStrSRS(c.getInitParameter("publisher.serviceSRS"));
            if (selectedTables != null) {
                String[] tablesToPublish = selectedTables.split(",");

                String host = c.getInitParameter("publisher.serverUrl");
                String serviceName = c.getInitParameter("publisher.serviceName");
                String userName = c.getInitParameter("publisher.serviceUser");
                String password = c.getInitParameter("publisher.servicePassword");
                String defaultStyle = c.getInitParameter("publisher.defaultPolygonStyle");
                PublishStatus status = publisher.publishDB(host, userName, password,
                        database.getType(), database.getHost(), database.getPort(), database.getUsername(), database.getPassword(),
                        database.getSchema(), database.getDatabaseName(), tablesToPublish, serviceName, defaultStyle, c);

                getContext().getValidationErrors().add("Status", new SimpleError(status.toString()));
                
            }
            getContext().getMessages().add(new SimpleMessage("Gelukt"));//
        } else {
            getContext().getValidationErrors().add("Databasetype", new SimpleError("Database mag alleen van type postgis of oracle zijn."));
        }

        list();

        return new ForwardResolution(LIST_JSP);
    }

    public void list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();


        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            databases = session.createQuery("from Database where inout_type = :inouttype")
                    .setParameter("inouttype", Inout.TYPE_OUTPUT)
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

    public String getPublisherType() {
        return publisherType;
    }

    public void setPublisherType(String publisherType) {
        this.publisherType = publisherType;
    }

    public List<String> getTables() {
        return tables;
    }

    public void setTables(List<String> tables) {
        this.tables = tables;
    }

    public String getSelectedTables() {
        return selectedTables;
    }

    public void setSelectedTables(String selectedTables) {
        this.selectedTables = selectedTables;
    } 
    //</editor-fold>

    public String getNamePublisher() {
        return namePublisher;
    }

    public void setNamePublisher(String namePublisher) {
        this.namePublisher = namePublisher;
    }
}
