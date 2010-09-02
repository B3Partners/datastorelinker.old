/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

import javax.servlet.http.HttpServletResponse;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.StreamingResolution;
import net.sourceforge.stripes.util.Log;

/**
 *
 * @author Erik van de Pol
 *
 * Accepts everything JSON-lib accepts:
 * POJO's, maps, lists etc...
 */
public class JSONResolution extends StreamingResolution {
    private final static Log log = Log.getInstance(JSONResolution.class);

    private Object object;

    public JSONResolution(Object object) {
        this(object, "application/json");
    }

    public JSONResolution(Object object, String mimeType) {
        super(mimeType);
        this.object = object;
    }

    @Override
    public void stream(HttpServletResponse response) throws Exception {
        log.debug(JSONObject.fromObject(object).toString());
        response.getOutputStream().print(JSONObject.fromObject(object).toString());
    }
}
