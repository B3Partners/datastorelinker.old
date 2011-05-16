/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

import javax.servlet.http.HttpServletResponse;

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

    @Override
    public void stream(HttpServletResponse response) throws Exception {
        response.setStatus(DEFAULT_CUSTOM_ERROR_CODE);
        super.stream(response);
    }

}
