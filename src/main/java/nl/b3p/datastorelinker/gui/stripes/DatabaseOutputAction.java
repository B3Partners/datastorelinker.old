package nl.b3p.datastorelinker.gui.stripes;

import java.util.Collections;
import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.DontValidate;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.json.SuccessMessage;
import nl.b3p.datastorelinker.json.JSONErrorResolution;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.util.NameableComparer;
import nl.b3p.geotools.data.linker.DataStoreLinker;
import org.geotools.data.DataStore;
import org.hibernate.Session;

/**
 *
 * @author Boy de Wit
 */
@Transactional
public class DatabaseOutputAction extends DefaultAction {

    private Log log = Log.getInstance(DatabaseOutputAction.class);

    private Boolean admin;

    private List<Database> databases;
    private Database selectedDatabase;
    protected Long selectedDatabaseId;
    // PostGIS specific:
    private Database.Type dbType;
    private String host;
    private String databaseName;
    private String username;
    private String password;
    private Integer port;
    private String schema;
    // Oracle specific (plus above):
    private String alias;
    // MS Access specific:
    private String url;
    private String srs;
    private String colX;
    private String colY;
    //wfs specific
    private String timeout;
    private String buffersize;

    @DefaultHandler
    public Resolution admin() {
        setAdmin(true);
        list();
        return new ForwardResolution(getAdminJsp());
    }

    protected String getAdminJsp() {
        return "/WEB-INF/jsp/management/databaseOutAdmin.jsp";
    }

    protected String getCreateJsp() {
        return "/WEB-INF/jsp/main/database_out/create.jsp";
    }

    protected String getListJsp() {
        return "/WEB-INF/jsp/main/database_out/list.jsp";
    }

    @DontValidate
    public Resolution create() {
        return new ForwardResolution(getCreateJsp());
    }

    // Always returns input databases! Should be overridden if necessary
    public Resolution list() {
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

        return new ForwardResolution(getListJsp());
    }

    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        session.delete(session.get(Database.class, selectedDatabaseId));

        return list();
    }

    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        selectedDatabase = (Database) session.get(Database.class, selectedDatabaseId);

        return create();
    }

    public Resolution createComplete() {
        Database db = saveDatabase(Database.TypeInout.OUTPUT);
        selectedDatabaseId = db.getId();

        return list();
    }

    protected Database saveDatabase(Database.TypeInout typeInout) {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        Database database = getDatabase(false);
        database.setTypeInout(typeInout);

        /* add organizationid and userid if the database is new. 
         * Else the user that made the database will stay the owner */
        if(database.getUserId() == null && database.getOrganizationId() == null){
            database.setOrganizationId(getUserOrganiztionId());
            database.setUserId(getUserId());
        }

        // TODO: wat als DB met ongeveer zelfde inhoud al aanwezig is? waarschuwing? Custom naamgeving issue eerst oplossen hiervoor
        if (selectedDatabaseId == null) {
            session.save(database);
        }

        return database;
    }

    protected Database getDatabase(boolean alwaysCreateNewDB) {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        Database database;
        if (selectedDatabaseId == null || alwaysCreateNewDB) {
            database = new Database();
        } else {
            database = (Database) session.get(Database.class, selectedDatabaseId);
            database.reset();
        }

        database.setType(dbType);

        switch (dbType) {
            case ORACLE:
                database.setHost(host);
                database.setDatabaseName(databaseName);
                database.setUsername(username);
                database.setPassword(password);
                database.setPort(port);
                database.setSchema(schema);
                database.setAlias(alias);
                break;
            case MSACCESS:
                database.setUrl(url);
                database.setSrs(srs);
                database.setColX(colX);
                database.setColY(colY);
                break;
            case POSTGIS:
                database.setHost(host);
                database.setDatabaseName(databaseName);
                database.setUsername(username);
                database.setPassword(password);
                database.setPort(port);
                database.setSchema(schema);
                break;
            case WFS:
                database.setUrl(url);
                database.setDatabaseName(url);
                database.setUsername(username);
                database.setPassword(password);
                database.setTimeout(timeout);
                database.setBuffersize(buffersize);
                break;
            default:
                log.error("Unsupported database type");
                return null;
        }
        return database;
    }

    public Resolution testConnection() {
        DataStore dataStore = null;
        try {
            dataStore = DataStoreLinker.openDataStore(getDatabase(true));
            if (dataStore == null)
                throw new Exception("Datastore is null");

            // Oracle DataStore will only only complain about invalid user/pw if we use the next line:
            String[] typeNames = dataStore.getTypeNames();

        } catch (Exception e) {
            log.debug("db connection error", e);
            return new JSONErrorResolution(e.getMessage(), "Databaseconnectie fout");
        } finally {
            if (dataStore != null)
                dataStore.dispose();
            }
        log.debug("db connection success");
        return new JSONResolution(new SuccessMessage());
    }

    public List<Database> getDatabases() {
        return databases;
    }

    public void setDatabases(List<Database> databases) {
        this.databases = databases;
    }

    public Database.Type getDbType() {
        return dbType;
    }

    public void setDbType(Database.Type dbType) {
        this.dbType = dbType;
    }

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public String getDatabaseName() {
        return databaseName;
    }

    public void setDatabaseName(String databaseName) {
        this.databaseName = databaseName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Integer getPort() {
        return port;
    }

    public void setPort(Integer port) {
        this.port = port;
    }

    public String getSchema() {
        return schema;
    }

    public void setSchema(String schema) {
        this.schema = schema;
    }

    public String getAlias() {
        return alias;
    }

    public void setAlias(String alias) {
        this.alias = alias;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getSrs() {
        return srs;
    }

    public void setSrs(String srs) {
        this.srs = srs;
    }

    public String getColX() {
        return colX;
    }

    public void setColX(String colX) {
        this.colX = colX;
    }

    public String getColY() {
        return colY;
    }

    public void setColY(String colY) {
        this.colY = colY;
    }
    
    public String getTimeout(){
        return timeout;
    }
    
    public void setTimeout(String timeout){
        this.timeout = timeout;
    }
    
    public String getBuffersize(){
        return buffersize;
    }
    
    public void setBuffersize(String buffersize){
        this.buffersize = buffersize;
    }
    
    public Long getSelectedDatabaseId() {
        return selectedDatabaseId;
    }

    public void setSelectedDatabaseId(Long selectedDatabaseId) {
        this.selectedDatabaseId = selectedDatabaseId;
    }

    public Database getSelectedDatabase() {
        return selectedDatabase;
    }

    public void setSelectedDatabase(Database selectedDatabase) {
        this.selectedDatabase = selectedDatabase;
    }

    public Boolean getAdmin() {
        return admin;
    }

    public void setAdmin(Boolean admin) {
        this.admin = admin;
    }

}
