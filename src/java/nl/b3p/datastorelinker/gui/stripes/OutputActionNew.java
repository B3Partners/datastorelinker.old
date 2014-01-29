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
import org.geotools.data.FeatureSource;
import org.geotools.feature.DefaultFeatureCollection;
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
public class OutputActionNew extends DatabaseOutputAction {
    private final static Log log = Log.getInstance(OutputActionNew.class);

    private final static String LIST_JSP = "/WEB-INF/jsp/main/output_new/database/list.jsp";
    private final static String TABLE_LIST_JSP = "/WEB-INF/jsp/main/output_new/table/list.jsp";
    private final static String CREATE_DATABASE_JSP = "/WEB-INF/jsp/main/output_new/database/create.jsp";
    private final static String CREATE_FILE_JSP = "/WEB-INF/jsp/main/output_new/file/create.jsp";
    private final static String EXAMPLE_RECORD_JSP = "/WEB-INF/jsp/main/actions/exampleOutputRecord.jsp";
    private final static String ADMIN_JSP = "/WEB-INF/jsp/management/outputAdminNew.jsp";

    private List<Inout> inputs;
    private Long selectedOutputId;

    private List<Database> databases;
    private Long selectedDatabaseId;

    private String selectedFilePath;
    //private String selectedFileDirectory;

    private List<String> tables;
    private List<String> failedTables;
    private String selectedTable;

    private List<String> outputColumnNames;
    private List<Object> outputRecordValues;
    
    private String selectedTemplateOutput;

    @DefaultHandler
    @Override
    public Resolution admin() {
        list();
        return new ForwardResolution(ADMIN_JSP);
    }

    @Override
    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
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

        return new ForwardResolution(LIST_JSP);
    }

    @Override
    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        session.delete(session.get(Inout.class, selectedOutputId));

        return list();
    }

    @Override
    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout input = (Inout)session.get(Inout.class, selectedOutputId);
        selectedTable = input.getTableName();
        selectedTemplateOutput = input.getTemplateOutput();

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
        if (selectedOutputId == null)
            dbInput = new Inout();
        else
            dbInput = (Inout)session.get(Inout.class, selectedOutputId);

        dbInput.setType(Inout.Type.OUTPUT);
        dbInput.setDatatype(Inout.Datatype.DATABASE);
        dbInput.setDatabase(selectedDatabase);
        dbInput.setTableName(selectedTable);
        
        dbInput.setOrganizationId(getUserOrganiztionId());
        dbInput.setUserId(getUserId());
        
        if (selectedTemplateOutput != null) {
            dbInput.setTemplateOutput(selectedTemplateOutput);
        }

        if (selectedOutputId == null)
            selectedOutputId = (Long)session.save(dbInput);

        return list();
    }

    public Resolution createTablesList() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        if (selectedOutputId != null) {
            Inout input = (Inout)session.get(Inout.class, selectedOutputId);
            // only prefill selected table if we have saved this db with the input we are editing
            if (selectedDatabaseId.equals(input.getDatabase().getId())) {
                selectedTemplateOutput = input.getTemplateOutput();
                selectedTable = input.getTableName();
            }              
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
            
            if (selectedOutputId != null) {
                input = (Inout)session.get(Inout.class, selectedOutputId);
                
                if (input.getTemplateOutput() != null) {
                    ActionsAction.setTemplateOutputType(input.getTemplateOutput());
                }
                
                /* Bij uitvoertype NO_TABLE dan verders niet teruggeven */
                if (input.getTemplateOutput() != null && input.getTemplateOutput().equals(Inout.TEMPLATE_OUTPUT_NO_TABLE)) {
                    return null;
                }
                
                /* Tabelnaam alvast voorinvullen voor Tabel hernoemen blok */
                if (input.getTemplateOutput() != null && input.getTemplateOutput().equals(Inout.TEMPLATE_OUTPUT_USE_TABLE)) {
                    ActionsAction.setOutputTablename(input.getTableName());                    
                }
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

            FeatureSource<SimpleFeatureType, SimpleFeature> source =
                ds.getFeatureSource(tableName);
        
            List<AttributeDescriptor> srcAttrDesc = source.getSchema().getAttributeDescriptors();                        
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
            String[] outputColumns = null;
            int i = 0;
            if (attrDescs != null && attrDescs.size() > 0) {
                outputColumns = new String[attrDescs.size()];
            }  
            
            JSONObject colNames = new JSONObject();
            for (AttributeDescriptor desc : attrDescs) {
                String col = desc.getLocalName();
                String type = desc.getType().getBinding().getSimpleName();
                colNames.put(col, type);
                
                outputColumns[i] = "outputmapping." + col;
                
                i++;
            }
            
            if (outputColumns != null) {
                ActionsAction.setOutputColumns(outputColumns);
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

        Inout input = (Inout)session.get(Inout.class, selectedOutputId);
        
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
            
            FeatureSource<SimpleFeatureType, SimpleFeature> source =
                ds.getFeatureSource(tableName);
        
            List<AttributeDescriptor> kolommen = source.getSchema().getAttributeDescriptors();

            outputColumnNames = new ArrayList<String>();
            for (AttributeDescriptor desc : kolommen) {
                String col = desc.getLocalName();
                String type = desc.getType().getBinding().getSimpleName();
                outputColumnNames.add(col + "(" + type + ")");
            }
            outputRecordValues = new ArrayList<Object>(); //feature.getAttributes();
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
        if (tableName == null) {
            if (ds.getTypeNames().length == 0)
                throw new IllegalArgumentException("no typeNames");
            tableName = ds.getTypeNames()[0];
        }               

        DefaultFeatureCollection fc = (DefaultFeatureCollection)ds.getFeatureSource(tableName).getFeatures();

        FeatureIterator<SimpleFeature> iterator = (FeatureIterator)fc.iterator();
        try {
            if (iterator.hasNext())
                return iterator.next();
        } finally {
            fc.close(iterator);
        }

        throw new Exception("Geen features gevonden.");
    }

    public List<Inout> getInputs() {
        return inputs;
    }

    public void setInputs(List<Inout> inputs) {
        this.inputs = inputs;
    }

    @Override
    public List<Database> getDatabases() {
        return databases;
    }

    @Override
    public void setDatabases(List<Database> databases) {
        this.databases = databases;
    }

    @Override
    public Long getSelectedDatabaseId() {
        return selectedDatabaseId;
    }

    @Override
    public void setSelectedDatabaseId(Long selectedDatabaseId) {
        this.selectedDatabaseId = selectedDatabaseId;
    }

    public String getSelectedFilePath() {
        return selectedFilePath;
    }

    public void setSelectedFilePath(String selectedFilePath) {
        this.selectedFilePath = selectedFilePath;
    }

    public Long getSelectedOutputId() {
        return selectedOutputId;
    }

    public void setSelectedOutputId(Long selectedOutputId) {
        this.selectedOutputId = selectedOutputId;
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

    public List<String> getOutputColumnNames() {
        return outputColumnNames;
    }

    public void setOutputColumnNames(List<String> outputColumnNames) {
        this.outputColumnNames = outputColumnNames;
    }

    public List<Object> getOutputRecordValues() {
        return outputRecordValues;
    }

    public void setOutputRecordValues(List<Object> outputRecordValues) {
        this.outputRecordValues = outputRecordValues;
    }

    public String getSelectedTemplateOutput() {
        return selectedTemplateOutput;
    }

    public void setSelectedTemplateOutput(String selectedTemplateOutput) {
        this.selectedTemplateOutput = selectedTemplateOutput;
    }
}