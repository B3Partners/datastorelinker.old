/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.entity.InoutDatatype;
import nl.b3p.datastorelinker.entity.InoutType;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
@Transactional
public class OutputAction extends DatabaseAction {
    private Log log = Log.getInstance(OutputAction.class);

    private List<Inout> outputs;
    private Long selectedOutputId;

    // dummy variable (not used)
    private Boolean drop;

    @Override
    protected String getAdminJsp() {
        return "/pages/management/outputAdmin.jsp";
    }

    @Override
    protected String getCreateJsp() {
        return "/pages/main/output/create.jsp";
    }

    @Override
    protected String getListJsp() {
        return "/pages/main/output/list.jsp";
    }

    @Override
    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        outputs = session.createQuery("from Inout where type.id = 2 order by name").list();

        return new ForwardResolution(getListJsp());
    }

    @Override
    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout selectedOutput = (Inout)session.get(Inout.class, selectedOutputId);

        selectedDatabaseId = selectedOutput.getDatabase().getId();

        return super.delete();
    }

    @Override
    public Resolution update() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        Inout output = (Inout)session.get(Inout.class, selectedOutputId);

        selectedDatabaseId = output.getDatabase().getId();

        return super.update();
    }

    @Override
    public Resolution createComplete() {
        Database database = saveDatabase();

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout output;
        if (selectedOutputId == null)
            output = new Inout();
        else
            output = (Inout)session.get(Inout.class, selectedOutputId);

        output.setType(new InoutType(2)); // output
        output.setDatatype(new InoutDatatype(1)); // database
        output.setDatabase(database);
        output.setName(database.getName());
        // no tablename needed.

        if (selectedOutputId == null)
            selectedOutputId = (Long)session.save(output);

        return list();
    }

    public List<Inout> getOutputs() {
        return outputs;
    }

    public void setOutputs(List<Inout> outputs) {
        this.outputs = outputs;
    }

    public Long getSelectedOutputId() {
        return selectedOutputId;
    }

    public void setSelectedOutputId(Long selectedOutputId) {
        this.selectedOutputId = selectedOutputId;
    }

    public Boolean getDrop() {
        return drop;
    }

    public void setDrop(Boolean drop) {
        this.drop = drop;
    }

}
