/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.entity;

import java.io.Serializable;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;

/**
 *
 * @author Erik van de Pol
 */
@Entity
@Table(name = "process")
@NamedQueries({
    @NamedQuery(name = "Process.findAll", query = "SELECT p FROM Process p"),
    @NamedQuery(name = "Process.findById", query = "SELECT p FROM Process p WHERE p.id = :id"),
    @NamedQuery(name = "Process.findByName", query = "SELECT p FROM Process p WHERE p.name = :name")})
public class Process implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @Column(name = "id")
    private Long id;
    @Basic(optional = false)
    @Column(name = "name")
    private String name;
    @JoinColumn(name = "actions_id", referencedColumnName = "id")
    @ManyToOne(optional = false)
    private Actions actionsId;
    @JoinColumn(name = "input_id", referencedColumnName = "id")
    @ManyToOne(optional = false)
    private Inout inputId;
    @JoinColumn(name = "output_id", referencedColumnName = "id")
    @ManyToOne(optional = false)
    private Inout outputId;

    public Process() {
    }

    public Process(Long id) {
        this.id = id;
    }

    public Process(Long id, String name) {
        this.id = id;
        this.name = name;
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

    public Actions getActionsId() {
        return actionsId;
    }

    public void setActionsId(Actions actionsId) {
        this.actionsId = actionsId;
    }

    public Inout getInputId() {
        return inputId;
    }

    public void setInputId(Inout inputId) {
        this.inputId = inputId;
    }

    public Inout getOutputId() {
        return outputId;
    }

    public void setOutputId(Inout outputId) {
        this.outputId = outputId;
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
        if (!(object instanceof Process)) {
            return false;
        }
        Process other = (Process) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "nl.b3p.datastorelinker.entity.Process[id=" + id + "]";
    }

}
