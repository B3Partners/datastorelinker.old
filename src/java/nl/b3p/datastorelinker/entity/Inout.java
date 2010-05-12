/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.entity;

import java.io.Serializable;
import java.util.List;
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
@Table(name = "inout")
@NamedQueries({
    @NamedQuery(name = "Inout.findAll", query = "SELECT i FROM Inout i")})
public class Inout implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @Column(name = "id")
    @GeneratedValue
    private Long id;
    @Basic(optional = false)
    @Column(name = "type_id")
    private int typeId;
    @Column(name = "table_name")
    private String tableName;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "inputId")
    private List<Process> processList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "outputId")
    private List<Process> processList1;
    @JoinColumn(name = "database_id", referencedColumnName = "id")
    @ManyToOne
    private Database databaseId;
    @JoinColumn(name = "file_id", referencedColumnName = "id")
    @ManyToOne
    private File fileId;
    @JoinColumn(name = "datatype_id", referencedColumnName = "id")
    @ManyToOne(optional = false)
    private InoutDatatype datatypeId;
    @Basic(optional = false)
    @Column(name = "name")
    private String name;

    public Inout() {
    }

    public Inout(Long id) {
        this.id = id;
    }

    public Inout(Long id, int typeId) {
        this.id = id;
        this.typeId = typeId;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public List<Process> getProcessList() {
        return processList;
    }

    public void setProcessList(List<Process> processList) {
        this.processList = processList;
    }

    public List<Process> getProcessList1() {
        return processList1;
    }

    public void setProcessList1(List<Process> processList1) {
        this.processList1 = processList1;
    }

    public Database getDatabaseId() {
        return databaseId;
    }

    public void setDatabaseId(Database databaseId) {
        this.databaseId = databaseId;
    }

    public File getFileId() {
        return fileId;
    }

    public void setFileId(File fileId) {
        this.fileId = fileId;
    }

    public InoutDatatype getDatatypeId() {
        return datatypeId;
    }

    public void setDatatypeId(InoutDatatype datatypeId) {
        this.datatypeId = datatypeId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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
        if (!(object instanceof Inout)) {
            return false;
        }
        Inout other = (Inout) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "nl.b3p.datastorelinker.entity.Inout[id=" + id + "]";
    }

}
