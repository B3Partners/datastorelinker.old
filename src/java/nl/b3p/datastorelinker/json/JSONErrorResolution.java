/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

import java.util.Locale;
import javax.servlet.http.HttpServletResponse;
import net.sourceforge.stripes.action.LocalizableMessage;

/**
 *
 * @author Erik van de Pol
 */
public class JSONErrorResolution extends JSONResolution {
    protected final static int DEFAULT_CUSTOM_ERROR_CODE = 1000;
    
    public JSONErrorResolution(String message) {
        this(message, "Error");
    }

    public JSONErrorResolution(String message, String title) {
        super(new ErrorMessage(message, title));
    }

    public JSONErrorResolution(LocalizableMessage message) {
        this(message.getMessage(Locale.getDefault()), "Error");
    }

    public JSONErrorResolution(LocalizableMessage message, LocalizableMessage title) {
        this(message.getMessage(Locale.getDefault()), title.getMessage(Locale.getDefault()));
    }

    public JSONErrorResolution(LocalizableMessage message, String title) {
        this(message.getMessage(Locale.getDefault()), title);
    }

    public JSONErrorResolution(String message, LocalizableMessage title) {
        this(message, title.getMessage(Locale.getDefault()));
    }

    @Override
    public void stream(HttpServletResponse response) throws Exception {
        response.setStatus(DEFAULT_CUSTOM_ERROR_CODE);
        super.stream(response);
    }

}
