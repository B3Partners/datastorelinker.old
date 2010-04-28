/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.entity;

import java.io.Serializable;
import java.util.List;
import javax.persistence.Basic;
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
@Table(name = "database")
@NamedQueries({
    @NamedQuery(name = "Database.findAll", query = "SELECT d FROM Database d"),
    @NamedQuery(name = "Database.findById", query = "SELECT d FROM Database d WHERE d.id = :id"),
    @NamedQuery(name = "Database.findByName", query = "SELECT d FROM Database d WHERE d.name = :name")})
public class Database implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @Column(name = "id")
    private Long id;
    @Column(name = "name")
    private String name;
    @OneToMany(mappedBy = "databaseId")
    private List<Inout> inoutList;
    @JoinColumn(name = "type_id", referencedColumnName = "id")
    @ManyToOne(optional = false)
    private DatabaseType typeId;

    public Database() {
    }

    public Database(Long id) {
        this.id = id;
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
