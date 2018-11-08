package nl.b3p.datastorelinker.gui.stripes;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import javax.persistence.EntityManager;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.LocalizableMessage;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.json.JSONErrorResolution;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.util.DefaultErrorResolution;
import nl.b3p.datastorelinker.util.NameableComparer;
import nl.b3p.geotools.data.linker.DataStoreLinker;
import nl.b3p.geotools.data.linker.util.DataStoreUtil;
import nl.b3p.geotools.data.linker.util.DataTypeList;
import org.geotools.data.DataStore;
import org.geotools.data.Query;
import org.geotools.feature.FeatureCollection;
import org.geotools.feature.FeatureIterator;
import org.hibernate.Session;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;
import org.opengis.feature.type.AttributeDescriptor;

/**
 *
 * @author Boy de Wit
 */
@Transactional
public class InputAction extends DefaultAction {
    private final static Log log = Log.getInstance(InputAction.class);

    private final static String LIST_JSP = "/WEB-INF/jsp/main/input/database/list.jsp";
    private final static String TABLE_LIST_JSP = "/WEB-INF/jsp/main/input/table/list.jsp";
    private final static String CREATE_DATABASE_JSP = "/WEB-INF/jsp/main/input/database/create.jsp";
    private final static String CREATE_FILE_JSP = "/WEB-INF/jsp/main/input/file/create.jsp";
    private final static String EXAMPLE_RECORD_JSP = "/WEB-INF/jsp/main/actions/exampleRecord.jsp";
    private final static String ADMIN_JSP = "/WEB-INF/jsp/management/inputAdmin.jsp";

    private List<Inout> inputs;
    private Long selectedInputId;

    private List<Database> databases;
    private Long selectedDatabaseId;

    private String selectedFilePath;
    //private String selectedFileDirectory;

    private List<String> tables;
    private List<String> failedTables;
    private String selectedTable;

    private List<String> columnNames;
    private List<Object> recordValues;

    @DefaultHandler
    public Resolution admin() {
        list();
        return new ForwardResolution(ADMIN_JSP);
    }

    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            inputs = session.createQuery("from Inout where input_output_type = :type"
                + " and input_output_datatype = :datatype")
                .setParameter("type", Inout.TYPE_INPUT)
                .setParameter("datatype", Inout.TYPE_DATABASE)
                .list();
        } else {
            inputs = session.createQuery("from Inout where input_output_type = :type"
                + " and input_output_datatype = :datatype and organization_id = :orgid")
                .setParameter("type", Inout.TYPE_INPUT)
                .setParameter("datatype", Inout.TYPE_DATABASE)
                .setParameter("orgid", getUserOrganiztionId())
                .list();
        }
        
        Collections.sort(inputs, new NameableComparer());

        return new ForwardResolution(LIST_JSP);
    }

    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        if (selectedInputId != null && selectedInputId > 0) {
            session.delete(session.get(Inout.class, selectedInputId));
        }

        return list();
    }

    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout input = (Inout)session.get(Inout.class, selectedInputId);
        selectedTable = input.getTableName();

        switch(input.getDatatype()) {
            case DATABASE:
                selectedDatabaseId = input.getDatabase().getId();
                return createDatabaseInput();
            /*case FILE:
                selectedFileId = input.getFile().getId();
                selectedFileDirectory = input.getFile().getDirectory();
                return createFileInput();*/
            default:
                log.error("Unknown input type.");
                return null;
        }
    }

    public Resolution createDatabaseInput() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        /* show all to beheerder but organization only for plain users */
        if (isUserAdmin()) {
            databases = session.createQuery("from Database where inout_type = :type")
                .setParameter("type", Inout.TYPE_INPUT)
                .list();
        } else {
            databases = session.createQuery("from Database where inout_type = :type"
                    + " and organization_id = :orgid")
                .setParameter("type", Inout.TYPE_INPUT)
                .setParameter("orgid", getUserOrganiztionId())
                .list();
        }

        Collections.sort(databases, new NameableComparer());
        
        return new ForwardResolution(CREATE_DATABASE_JSP);
    }

    public Resolution createFileInput() {
        return new ForwardResolution(CREATE_FILE_JSP);
    }

    public Resolution createDatabaseInputComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Database selectedDatabase = (Database)session.get(Database.class, selectedDatabaseId);

        Inout dbInput = null;
        if (selectedInputId == null)
            dbInput = new Inout();
        else
            dbInput = (Inout)session.get(Inout.class, selectedInputId);

        dbInput.setType(Inout.Type.INPUT);
        dbInput.setDatatype(Inout.Datatype.DATABASE);
        dbInput.setDatabase(selectedDatabase);
        dbInput.setTableName(selectedTable);
        
        /* add organizationid and userid if the dbInput is new. 
         * Else the user that made the dbInput will stay the owner */
        if(dbInput.getUserId() == null && dbInput.getOrganizationId() == null){
            dbInput.setOrganizationId(getUserOrganiztionId());
            dbInput.setUserId(getUserId());
        }

        if (selectedInputId == null)
            selectedInputId = (Long)session.save(dbInput);

        return list();
    }

    public Resolution createTablesList() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        if (selectedInputId != null) {
            Inout input = (Inout)session.get(Inout.class, selectedInputId);
            // only prefill selected table if we have saved this db with the input we are editing
            if (selectedDatabaseId.equals(input.getDatabase().getId()))
                selectedTable = input.getTableName();
        }

        Database selectedDatabase = (Database)session.get(Database.class, selectedDatabaseId);

        try {
            DataTypeList dataTypeList = DataStoreUtil.getDataTypeList(selectedDatabase.toGeotoolsDataStoreParametersMap());

            if (dataTypeList != null) {

                tables = dataTypeList.getGood();
                failedTables = dataTypeList.getBad();

                return new ForwardResolution(TABLE_LIST_JSP);
            } else {
                throw new Exception("Error getting datatypes from DataStore.");
            }
        } catch(Exception e) {
            String tablesError = "Fout bij ophalen tabellen. ";
            log.error(tablesError + e.getMessage());
            return new DefaultErrorResolution(tablesError);
        }
    }

    public Resolution getTypeNames() {
        log.debug("getTypeNames");
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        DataStore ds = null;
        try {
            Inout input = null;
            if (selectedFilePath == null) {
                input = (Inout)session.get(Inout.class, selectedInputId);
            } else {
                String fullPath = FileAction.getFileNameFromPPFileName(selectedFilePath, getContext());
                input = new Inout();
                input.setFile(fullPath);
                
                ActionsAction.setExternalFileName(fullPath);
            }
            
            String tableName = null;
            if (input.getDatabase() != null) {
                ds = DataStoreLinker.openDataStore(input.getDatabase());
                tableName = input.getTableName();
            } else if (input.getFile() != null) {
                ds = DataStoreLinker.openDataStore(input.getFile());
            } else {
                throw new Exception("unsupported input type.");
            }
            
            SimpleFeature feature = null;
            
            try {
                feature = getExampleFeature(ds, tableName);
            } catch (Exception fEx) {                
            }
            
            /* Fix for reading from input table with no records */
            List<AttributeDescriptor> srcAttrDesc = new ArrayList(); 
            if (feature != null) {
                srcAttrDesc = feature.getFeatureType().getAttributeDescriptors();
            } else {
                srcAttrDesc = ds.getFeatureSource(tableName).getSchema().getAttributeDescriptors();
            }            

            List<AttributeDescriptor> attrDescs = new ArrayList<AttributeDescriptor>(srcAttrDesc.size());
            for (AttributeDescriptor ad : srcAttrDesc) {
                attrDescs.add(ad);
            }
            Collections.sort(attrDescs, new Comparator<AttributeDescriptor>() {
                public int compare(AttributeDescriptor o1, AttributeDescriptor o2) {
                    String o1Name = o1.getLocalName();
                    String o2Name = o2.getLocalName();
                    return o1Name == null ? 0 : o1Name.compareTo(o2Name);
                }
            });
            
            /* Kolommen ook klaarzetten voor Actieblokken action zodat
             * uitvoer mappen blok opgebouwd kan worden */
            String[] inputColumns = null;
            int i = 0;
            if (attrDescs != null && attrDescs.size() > 0) {
                inputColumns = new String[attrDescs.size()];
            }            
            
            JSONObject colNames = new JSONObject();
            for (AttributeDescriptor desc : attrDescs) {
                String col = desc.getLocalName();
                String type = desc.getType().getBinding().getSimpleName();
                colNames.put(col, type);
                inputColumns[i] = "inputmapping." + col;
                
                i++;
            }
            
            if (inputColumns != null) {
                ActionsAction.setInputColumns(inputColumns);
            }
            
            return new JSONResolution(colNames);
        } catch (Exception e) {
            log.error(e);
            String message = e.getMessage() + "<p>" + new LocalizableMessage("attributeReadErrorAdvice").getMessage(getContext().getLocale()) + "</p>";
            
            return new JSONErrorResolution(message, new LocalizableMessage("attributeReadError"), getContext());
        } finally {
            if (ds != null) {
                ds.dispose();
            }
        }
    }

    public Resolution getExampleRecord() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout input = (Inout)session.get(Inout.class, selectedInputId);
        
        DataStore ds = null;
        
        try {
            
            String tableName = null;
            if (input.getDatabase() != null) {
                ds = DataStoreLinker.openDataStore(input.getDatabase());
                tableName = input.getTableName();
            } else if (input.getFile() != null) {
                ds = DataStoreLinker.openDataStore(input.getFile());
            } else {
                throw new Exception("unsupported input type.");
            }
            SimpleFeature feature = getExampleFeature(ds, tableName);

            columnNames = new ArrayList<String>();
            for (AttributeDescriptor desc : feature.getFeatureType().getAttributeDescriptors()) {
                String col = desc.getLocalName();
                String type = desc.getType().getBinding().getSimpleName();
                columnNames.add(col + "(" + type + ")");
            }
            recordValues = feature.getAttributes();
        } catch (Exception e) {
            log.error(e);
            return new DefaultErrorResolution(e.getMessage());
        } finally {
            if (ds != null) {
                ds.dispose();
            }
        }
        
        return new ForwardResolution(EXAMPLE_RECORD_JSP);
    }

    private SimpleFeature getExampleFeature(DataStore ds, String tableName) throws Exception {
        //log.debug((Object[])ds.getTypeNames());
        if (tableName == null) {
            if (ds.getTypeNames().length == 0)
                throw new IllegalArgumentException("no typeNames");
            tableName = ds.getTypeNames()[0];
        }

        Query q = new Query();
        q.setMaxFeatures(1);
        FeatureCollection<SimpleFeatureType, SimpleFeature> fc =
                ds.getFeatureSource(tableName).getFeatures(q);

        FeatureIterator iterator = fc.features();
        try {
            if (iterator.hasNext())
                return (SimpleFeature)iterator.next();
        } finally {
            iterator.close();
        }

        throw new Exception("Geen features gevonden.");
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

    public String getSelectedFilePath() {
        return selectedFilePath;
    }

    public void setSelectedFilePath(String selectedFilePath) {
        this.selectedFilePath = selectedFilePath;
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

    public List<String> getColumnNames() {
        return columnNames;
    }

    public void setColumnNames(List<String> columnNames) {
        this.columnNames = columnNames;
    }

    public List<Object> getRecordValues() {
        return recordValues;
    }

    public void setRecordValues(List<Object> recordValues) {
        this.recordValues = recordValues;
    }

}
