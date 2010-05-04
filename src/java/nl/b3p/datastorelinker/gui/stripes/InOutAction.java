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
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
public class InOutAction extends DefaultAction {
    private final static Log log = Log.getInstance(InOutAction.class);

    private final static String JSP = "/pages/processOverview.jsp";
    private final static String NEW_JSP = "/pages/newInOut.jsp";
    private final static String NEW_COMPLETE_JSP = "/pages/inoutList.jsp";

    private List<Database> databases;


    /*@DefaultHandler
    public Resolution overview() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        return new ForwardResolution(JSP);
    }*/

    public Resolution new_() {
        //ValidationErrors errors = new ValidationErrors();

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        databases = session.createQuery("from Database").list();

        // moet even wat hulp krijgen om die order by's goed te krijgen
        // (te maken met de dot-notation voor joins die niet werkt zoals ik denk dat ie werkt.).
        //processes = session.createQuery("from Process order by name").list();

        /*if (!errors.isEmpty()) {
        getContext().setValidationErrors(errors);
        return getContext().getSourcePageResolution();
        }*/

        return new ForwardResolution(NEW_JSP);
    }

    @Transactional
    public Resolution newComplete() {
        //ValidationErrors errors = new ValidationErrors();

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        // TODO: stop in DB...

        // Haal nieuwe lijst op...
        databases = session.createQuery("from Database").list();

        // TODO: zet nieuwe record voor jsp om te selecteren
        

        // moet even wat hulp krijgen om die order by's goed te krijgen
        // (te maken met de dot-notation voor joins die niet werkt zoals ik denk dat ie werkt.).
        //processes = session.createQuery("from Process order by name").list();

        /*if (!errors.isEmpty()) {
        getContext().setValidationErrors(errors);
        return getContext().getSourcePageResolution();
        }*/

        return new ForwardResolution(NEW_COMPLETE_JSP);
    }

    public List<Database> getDatabases() {
        return databases;
    }

    public void setDatabases(List<Database> databases) {
        this.databases = databases;
    }

}
