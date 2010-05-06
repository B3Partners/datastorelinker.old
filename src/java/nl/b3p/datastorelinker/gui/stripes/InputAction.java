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
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
public class InputAction extends DefaultAction {
    private final static Log log = Log.getInstance(InputAction.class);

    private final static String LIST_JSP = "/pages/main/input/list.jsp";
    private final static String CREATE_DATABASE_JSP = "/pages/main/input/database/create.jsp";
    private final static String CREATE_FILE_JSP = "/pages/main/input/file/create.jsp";

    private List<Inout> inputs;
    private List<Database> databases;

    /*@DefaultHandler
    public Resolution overview() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        return new ForwardResolution(JSP);
    }*/

    public Resolution createDatabaseInput() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        databases = session.createQuery("from Database").list();
        
        return new ForwardResolution(CREATE_DATABASE_JSP);
    }

    public Resolution createFileInput() {
        return new ForwardResolution(CREATE_FILE_JSP);
    }

    @Transactional
    public Resolution createDatabaseInputComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        // TODO: stop in DB...

        inputs = session.createQuery("from Inout where typeId = 1").list();

        // TODO: zet nieuwe record voor jsp om te selecteren

        return new ForwardResolution(LIST_JSP);
    }

    @Transactional
    public Resolution createFileInputComplete() {
        return new ForwardResolution(LIST_JSP);
    }

    public List<Inout> getInputs() {
        return inputs;
    }

    public void setInputs(List<Inout> inputs) {
        this.inputs = inputs;
    }

    public List<Database> getDatabases() {
        return databases;
    }

    public void setDatabases(List<Database> databases) {
        this.databases = databases;
    }

}
