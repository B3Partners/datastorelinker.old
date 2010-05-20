/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.entity;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;

/**
 *
 * @author Erik van de Pol
 */
@Entity
@Table(name = "database")
@NamedQueries({
    @NamedQuery(name = "Database.findAll", query = 
        "SELECT d FROM Database d"),
    @NamedQuery(name = "Database.findInput", query =
        "select distinct d from Database d left join d.inoutList l where l.typeId = null or l.typeId = 1")/*,
    @NamedQuery(name = "Database.findOutput", query =
        "select distinct d from Database d left join d.inoutList l where l.typeId = 2")*/
})
public class Database implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @Column(name = "id")
    @GeneratedValue
    private Long id;
    @Basic(optional = false)
    @Column(name = "name")
    private String name;
    @Column(name = "host")
    private String host;
    @Column(name = "database_name")
    private String databaseName;
    @Column(name = "username")
    private String username;
    @Column(name = "password")
    private String password;
    @Column(name = "schema")
    private String schema;
    @Column(name = "port")
    private Integer port;
    @Column(name = "instance")
    private String instance;
    @Column(name = "alias")
    private String alias;
    @Column(name = "url")
    private String url;
    @Column(name = "srs")
    private String srs;
    @Column(name = "col_x")
    private String colX;
    @Column(name = "col_y")
    private String colY;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "databaseId")
    private List<Inout> inoutList;
    @JoinColumn(name = "type_id", referencedColumnName = "id")
    @ManyToOne(optional = false)
    private DatabaseType typeId;

    public Database() {
    }

    public Database(Long id) {
        this.id = id;
    }

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<String, Object>();

        addToMapIfNotNull(map, "dbtype", typeId.getName());
        addToMapIfNotNull(map, "host", host);
        addToMapIfNotNull(map, "port", port);
        addToMapIfNotNull(map, "database", databaseName);
        addToMapIfNotNull(map, "user", username);
        addToMapIfNotNull(map, "passwd", password);
        // Oracle specific:
        addToMapIfNotNull(map, "schema", schema);
        addToMapIfNotNull(map, "instance", instance);
        // MS Access specific:
        addToMapIfNotNull(map, "url", url);
        addToMapIfNotNull(map, "srs", srs);
        // TODO: check of deze ok zijn!
        addToMapIfNotNull(map, "column_x", colX);
        addToMapIfNotNull(map, "column_y", colY);

        return map;
    }

    private void addToMapIfNotNull(Map<String, Object> map, String key, Object value) {
        if (key != null && value != null)
            map.put(key, value);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public String getSchema() {
        return schema;
    }

    public void setSchema(String schema) {
        this.schema = schema;
    }

    public Integer getPort() {
        return port;
    }

    public void setPort(Integer port) {
        this.port = port;
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

    public List<Inout> getInoutList() {
        return inoutList;
    }

    public void setInoutList(List<Inout> inoutList) {
        this.inoutList = inoutList;
    }

    public DatabaseType getTypeId() {
        return typeId;
    }

    public void setTypeId(DatabaseType typeId) {
        this.typeId = typeId;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (id != null ? id.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Database)) {
            return false;
        }
        Database other = (Database) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "nl.b3p.datastorelinker.entity.Database[id=" + id + "]";
    }

}
