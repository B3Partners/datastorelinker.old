/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.entity;

import java.io.Serializable;
import java.math.BigInteger;
import java.util.Collection;
import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
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
    @NamedQuery(name = "Inout.findAll", query = "SELECT i FROM Inout i"),
    @NamedQuery(name = "Inout.findById", query = "SELECT i FROM Inout i WHERE i.id = :id"),
    @NamedQuery(name = "Inout.findByTypeId", query = "SELECT i FROM Inout i WHERE i.typeId = :typeId"),
    @NamedQuery(name = "Inout.findByTableName", query = "SELECT i FROM Inout i WHERE i.tableName = :tableName"),
    @NamedQuery(name = "Inout.findByDataconnectionId", query = "SELECT i FROM Inout i WHERE i.dataconnectionId = :dataconnectionId")})
public class Inout implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @Column(name = "id")
    private Long id;
    @Basic(optional = false)
    @Column(name = "type_id")
    private int typeId;
    @Column(name = "table_name")
    private String tableName;
    @Column(name = "dataconnection_id")
    private BigInteger dataconnectionId;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "inputId")
    private Collection<Process> processCollection;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "outputId")
    private Collection<Process> processCollection1;
    @JoinColumn(name = "datatype_id", referencedColumnName = "id")
    @ManyToOne(optional = false)
    private InoutDatatype datatypeId;

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

    public BigInteger getDataconnectionId() {
        return dataconnectionId;
    }

    public void setDataconnectionId(BigInteger dataconnectionId) {
        this.dataconnectionId = dataconnectionId;
    }

    public Collection<Process> getProcessCollection() {
        return processCollection;
    }

    public void setProcessCollection(Collection<Process> processCollection) {
        this.processCollection = processCollection;
    }

    public Collection<Process> getProcessCollection1() {
        return processCollection1;
    }

    public void setProcessCollection1(Collection<Process> processCollection1) {
        this.processCollection1 = processCollection1;
    }

    public InoutDatatype getDatatypeId() {
        return datatypeId;
    }

    public void setDatatypeId(InoutDatatype datatypeId) {
        this.datatypeId = datatypeId;
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
