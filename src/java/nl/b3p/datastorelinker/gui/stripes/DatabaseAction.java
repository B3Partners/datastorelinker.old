/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.datastorelinker.entity.Database;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
public class DatabaseAction extends DefaultAction {
    private final static String CREATE_JSP = "/pages/main/database/create.jsp";
    private final static String LIST_JSP = "/pages/main/database/list.jsp";

    private List<Database> databases;

    public Resolution create() {
        return new ForwardResolution(CREATE_JSP);
    }

    public Resolution createComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        databases = session.createQuery("from Database").list();

        return new ForwardResolution(LIST_JSP);
    }

    public List<Database> getDatabases() {
        return databases;
    }

    public void setDatabases(List<Database> databases) {
        this.databases = databases;
    }

}
