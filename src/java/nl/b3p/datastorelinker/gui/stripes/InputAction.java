/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.File;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.entity.InoutDatatype;
import nl.b3p.geotools.data.linker.util.DataStoreUtil;
import nl.b3p.geotools.data.linker.util.DataTypeList;
import org.geotools.util.logging.Log4JLoggerFactory;
import org.geotools.util.logging.Logging;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
@Transactional
public class InputAction extends DefaultAction {
    private final static Log log = Log.getInstance(InputAction.class);

    private final static String LIST_JSP = "/pages/main/input/list.jsp";
    private final static String TABLE_LIST_JSP = "/pages/main/input/table/list.jsp";
    private final static String CREATE_DATABASE_JSP = "/pages/main/input/database/create.jsp";
    private final static String CREATE_FILE_JSP = "/pages/main/input/file/create.jsp";

    static {
        Logging.ALL.setLoggerFactory(Log4JLoggerFactory.getInstance());
    }

    private List<Inout> inputs;
    private Long selectedInputId;

    private List<Database> databases;
    private Long selectedDatabaseId;

    private List<File> files;
    private Long selectedFileId;

    private List<String> tables;
    private List<String> failedTables;
    private String selectedTable;

    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        inputs = session.createQuery("from Inout where typeId = 1").list();

        return new ForwardResolution(LIST_JSP);
    }

    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        session.delete(session.get(Inout.class, selectedInputId));

        return list();
    }

    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout input = (Inout)session.get(Inout.class, selectedInputId);
        selectedTable = input.getTableName();

        switch(input.getDatatypeId().getId()) {
            case 1:
                selectedDatabaseId = input.getDatabaseId().getId();
                return createDatabaseInput();
            case 2:
                selectedFileId = input.getFileId().getId();
                return createFileInput();
            default:
                log.error("Unknown input type.");
                return null;
        }
    }

    public Resolution createDatabaseInput() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        databases = session.getNamedQuery("Database.findInput").list();
        
        return new ForwardResolution(CREATE_DATABASE_JSP);
    }

    public Resolution createFileInput() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        files = session.createQuery("from File").list();

        return new ForwardResolution(CREATE_FILE_JSP);
    }

    public Resolution createDatabaseInputComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Database selectedDatabase = (Database)session.get(nl.b3p.datastorelinker.entity.Database.class, selectedDatabaseId);

        Inout dbInput = new Inout();
        dbInput.setTypeId(1); // input
        dbInput.setDatatypeId(new InoutDatatype(1)); // database
        dbInput.setDatabaseId(selectedDatabase);
        dbInput.setTableName(selectedTable);
        String name = selectedDatabase.getName();
        if (selectedTable != null && !selectedTable.equals(""))
            name += " (" + selectedTable + ")";
        dbInput.setName(name);

        selectedInputId = (Long)session.save(dbInput);

        return list();
    }

    public Resolution createFileInputComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        File selectedFile = (File)session.get(nl.b3p.datastorelinker.entity.File.class, selectedFileId);

        Inout fileInput = new Inout();
        fileInput.setTypeId(1); // input
        fileInput.setDatatypeId(new InoutDatatype(2)); // file
        fileInput.setFileId(selectedFile);
        fileInput.setTableName(selectedTable);
        String name = selectedFile.getName();
        if (selectedTable != null && !selectedTable.equals(""))
            name += " (" + selectedTable + ")";
        fileInput.setName(name);

        selectedInputId = (Long)session.save(fileInput);

        return list();
    }

    public Resolution createTablesList() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Database selectedDatabase = (Database)session.get(Database.class, selectedDatabaseId);

        try {
            DataTypeList dataTypeList = DataStoreUtil.getDataTypeList(selectedDatabase.toMap());

            if (dataTypeList != null) {

                tables = dataTypeList.getGood();
                failedTables = dataTypeList.getBad();

                return new ForwardResolution(TABLE_LIST_JSP);
            } else {
                throw new Exception("Error getting datatypes from DataStore.");
            }
        } catch(Exception e) {
            log.error("Tables fetch error: " + e.getMessage());
            // TODO: error to screen? Stripes / jQuery
            return new ForwardResolution(TABLE_LIST_JSP);
        }
    }

    public List<Inout> getInputs() {
        return inputs;
    }

    public void setInputs(List<Inout> inputs) {
        this.inputs = inputs;
    }

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

    public List<File> getFiles() {
        return files;
    }

    public void setFiles(List<File> files) {
        this.files = files;
    }

    public Long getSelectedFileId() {
        return selectedFileId;
    }

    public void setSelectedFileId(Long selectedFileId) {
        this.selectedFileId = selectedFileId;
    }

    public Long getSelectedInputId() {
        return selectedInputId;
    }

    public void setSelectedInputId(Long selectedInputId) {
        this.selectedInputId = selectedInputId;
    }

    public List<String> getTables() {
        return tables;
    }

    public void setTables(List<String> tables) {
        this.tables = tables;
    }

    public String getSelectedTable() {
        return selectedTable;
    }

    public void setSelectedTable(String selectedTable) {
        this.selectedTable = selectedTable;
    }

    public List<String> getFailedTables() {
        return failedTables;
    }

    public void setFailedTables(List<String> failedTables) {
        this.failedTables = failedTables;
    }

    public String getUploadDirectory() {
        return getContext().getServletContext().getInitParameter("uploadDirectory");
    }
    
}
