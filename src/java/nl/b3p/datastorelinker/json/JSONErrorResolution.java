/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

import java.util.Locale;
import javax.servlet.http.HttpServletResponse;
import net.sourceforge.stripes.action.ActionBeanContext;
import net.sourceforge.stripes.action.LocalizableMessage;

/**
 *
 * @author Erik van de Pol
 */
public class JSONErrorResolution extends JSONResolution {
    
    public JSONErrorResolution(String message) {
        this(message, "Error");
    }

    public JSONErrorResolution(String message, String title) {
        super(new ErrorMessage(message, title));
    }

    public JSONErrorResolution(LocalizableMessage message, ActionBeanContext context) {
        this(message.getMessage(context.getLocale()), "Error");
    }

    public JSONErrorResolution(LocalizableMessage message, LocalizableMessage title, ActionBeanContext context) {
        this(message.getMessage(context.getLocale()), title.getMessage(context.getLocale()));
    }

    public JSONErrorResolution(LocalizableMessage message, String title, ActionBeanContext context) {
        this(message.getMessage(context.getLocale()), title);
    }

    public JSONErrorResolution(String message, LocalizableMessage title, ActionBeanContext context) {
        this(message, title.getMessage(context.getLocale()));
    }

    @Override
    public void stream(HttpServletResponse response) throws Exception {
        response.setStatus(500);
        super.stream(response);
    }

}
