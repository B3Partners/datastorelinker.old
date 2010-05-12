/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.entity.InoutDatatype;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
public class OutputAction extends DatabaseAction {
    static {
        log = Log.getInstance(OutputAction.class);

        CREATE_JSP = "/pages/main/output/create.jsp";
        LIST_JSP = "/pages/main/output/list.jsp";
    }

    private List<Inout> outputs;
    private Long selectedOutputId;

    @Override
    @Transactional
    public Resolution createComplete() {
        Database database = saveDatabase();

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        Inout output = new Inout();
        output.setTypeId(2); // output
        output.setDatatypeId(new InoutDatatype(1)); // database
        output.setDatabaseId(database);
        output.setName(database.getName());
        // no tablename needed.

        selectedOutputId = (Long)session.save(output);
        outputs = session.createQuery("from Inout where typeId = 2").list();

        return new ForwardResolution(LIST_JSP);
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

}
