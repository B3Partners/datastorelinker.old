/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.util;

import javax.servlet.http.HttpServletResponse;
import net.sourceforge.stripes.action.StreamingResolution;

/**
 *
 * @author Erik van de Pol
 */
public class DefaultErrorResolution extends StreamingResolution {
    
    protected final static String DEFAULT_CONTENT_TYPE = "text/plain";
    protected final static int DEFAULT_CUSTOM_ERROR_CODE = 1000;

    public DefaultErrorResolution(String errorMessage) {
        super(DEFAULT_CONTENT_TYPE, errorMessage == null ? "No error message." : errorMessage);
    }

    @Override
    protected void stream(HttpServletResponse response) throws Exception {
        super.stream(response);
        response.setStatus(DEFAULT_CUSTOM_ERROR_CODE);
    }
}
