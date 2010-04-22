/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.ActionBeanContext;

/**
 *
 * @author Erik van de Pol
 */
public class DefaultAction implements ActionBean {
    private ActionBeanContext context;
    
    public void setContext(ActionBeanContext context) {
        this.context = context;
    }

    public ActionBeanContext getContext() {
        return context;
    }

}
