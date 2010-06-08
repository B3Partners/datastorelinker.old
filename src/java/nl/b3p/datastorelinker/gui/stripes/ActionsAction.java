/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;

/**
 *
 * @author Erik van de Pol
 */
public class ActionsAction extends DefaultAction {
    private Log log = Log.getInstance(ActionsAction.class);

    private final static String VIEW_JSP = "/pages/main/actions/view.jsp";

    @DefaultHandler
    public Resolution view() {
        return new ForwardResolution(VIEW_JSP);
    }

}
