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
import javax.persistence.Lob;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;

/**
 *
 * @author Erik van de Pol
 */
@Entity
@Table(name = "actions")
@NamedQueries({
    @NamedQuery(name = "Actions.findAll", query = "SELECT a FROM Actions a"),
    @NamedQuery(name = "Actions.findByProcessId", query = "SELECT a FROM Actions a WHERE a.processId = :processId"),
    @NamedQuery(name = "Actions.findByActionId", query = "SELECT a FROM Actions a WHERE a.actionId = :actionId"),
    @NamedQuery(name = "Actions.findById", query = "SELECT a FROM Actions a WHERE a.id = :id"),
    @NamedQuery(name = "Actions.findByNextId", query = "SELECT a FROM Actions a WHERE a.nextId = :nextId")})
public class Actions implements Serializable {
    private static final long serialVersionUID = 1L;
    @Basic(optional = false)
    @Column(name = "process_id")
    private long processId;
    @Basic(optional = false)
    @Column(name = "action_id")
    private long actionId;
    @Lob
    @Column(name = "parameters")
    private Object parameters;
    @Id
    @Basic(optional = false)
    @Column(name = "id")
    private Long id;
    @Column(name = "next_id")
    private BigInteger nextId;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "actionsId")
    private Collection<Process> processCollection;

    public Actions() {
    }

    public Actions(Long id) {
        this.id = id;
    }

    public Actions(Long id, long processId, long actionId) {
        this.id = id;
        this.processId = processId;
        this.actionId = actionId;
    }

    public long getProcessId() {
        return processId;
    }

    public void setProcessId(long processId) {
        this.processId = processId;
    }

    public long getActionId() {
        return actionId;
    }

    public void setActionId(long actionId) {
        this.actionId = actionId;
    }

    public Object getParameters() {
        return parameters;
    }

    public void setParameters(Object parameters) {
        this.parameters = parameters;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public BigInteger getNextId() {
        return nextId;
    }

    public void setNextId(BigInteger nextId) {
        this.nextId = nextId;
    }

    public Collection<Process> getProcessCollection() {
        return processCollection;
    }

    public void setProcessCollection(Collection<Process> processCollection) {
        this.processCollection = processCollection;
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
        if (!(object instanceof Actions)) {
            return false;
        }
        Actions other = (Actions) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "nl.b3p.datastorelinker.entity.Actions[id=" + id + "]";
    }

}
