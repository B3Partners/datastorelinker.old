/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.io.Serializable;
import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.DontValidate;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.DatabaseType;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
public class DatabaseAction extends DefaultAction {
    protected static Log log = Log.getInstance(DatabaseAction.class);

    protected static String CREATE_JSP = "/pages/main/database/create.jsp";
    protected static String LIST_JSP = "/pages/main/database/list.jsp";

    private List<Database> databases;
    private Long selectedDatabaseId;

    // PostGIS specific:
    private Integer dbType;
    private String host;
    private String databaseName;
    private String username;
    private String password;
    private Integer port;
    private String schema;
    // Oracle specific (plus above):
    private String instance;
    private String alias;
    // MS Access specific:
    private String url;
    private String srs;
    private String colX;
    private String colY;

    @DontValidate
    public Resolution create() {
        return new ForwardResolution(CREATE_JSP);
    }

    public Resolution createComplete() {
        Database db = saveDatabase();
        selectedDatabaseId = db.getId();

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        databases = session.createQuery("from Database").list();

        return new ForwardResolution(LIST_JSP);
    }

    protected Database saveDatabase() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Database database = new Database();
        // TODO: serverside en clientside validation

        DatabaseType dbt = (DatabaseType)session.createQuery("from DatabaseType where id = :id")
                .setParameter("id", dbType)
                .uniqueResult();

        database.setName(host + "/" + databaseName);
        database.setTypeId(dbt);

        switch(dbt.getId()) {
            case 1: // Oracle
                database.setHost(host);
                database.setDatabaseName(databaseName);
                database.setUsername(username);
                database.setPassword(password);
                database.setPort(port);
                database.setSchema(schema);
                database.setInstance(instance);
                database.setAlias(alias);
                break;
            case 2: // MS Access
                database.setUrl(url);
                database.setSrs(srs);
                database.setColX(colX);
                database.setColY(colY);
                break;
            case 3: // PostGIS
                database.setHost(host);
                database.setDatabaseName(databaseName);
                database.setUsername(username);
                database.setPassword(password);
                database.setPort(port);
                database.setSchema(schema);
                break;
            default:
                log.error("Unsupported database type");
                return null;
        }

        // TODO: wat als DB met ongeveer zelfde inhoud al aanwezig is? waarschuwing?
        session.save(database);
        
        return database;
     }

    public List<Database> getDatabases() {
        return databases;
    }

    public void setDatabases(List<Database> databases) {
        this.databases = databases;
    }

    public Integer getDbType() {
        return dbType;
    }

    public void setDbType(Integer dbType) {
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

    public String getInstance() {
        return instance;
    }

    public void setInstance(String instance) {
        this.instance = instance;
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

    public Long getSelectedDatabaseId() {
        return selectedDatabaseId;
    }

    public void setSelectedDatabase(Long selectedDatabaseId) {
        this.selectedDatabaseId = selectedDatabaseId;
    }

}
