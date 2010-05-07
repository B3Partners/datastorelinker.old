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
import nl.b3p.datastorelinker.entity.Inout;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
public class OutputAction extends DefaultAction {
    private final static Log log = Log.getInstance(OutputAction.class);

    private final static String LIST_JSP = "/pages/main/output/list.jsp";

    private List<Inout> outputs;

    /*@DefaultHandler
    public Resolution overview() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        return new ForwardResolution(JSP);
    }*/

    public Resolution create() {
        return new ForwardResolution(LIST_JSP);
    }

    @Transactional
    public Resolution createComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        // TODO: stop in DB...

        outputs = session.createQuery("from Inout where typeId = 2").list();

        // TODO: zet nieuwe record voor jsp om te selecteren

        return new ForwardResolution(LIST_JSP);
    }

    public List<Inout> getOutputs() {
        return outputs;
    }

    public void setOutputs(List<Inout> outputs) {
        this.outputs = outputs;
    }

}
