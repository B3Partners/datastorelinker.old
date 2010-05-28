/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

import javax.servlet.http.HttpServletResponse;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.StreamingResolution;

/**
 *
 * @author Erik van de Pol
 *
 * Excepts everything JSON-lib accepts:
 * POJO's, maps, lists etc...
 */
public class JSONResolution extends StreamingResolution {
    private Object object;

    public JSONResolution(Object object) {
        // hoort dit te zijn:
        //super("application/json");
        super("text");
        this.object = object;
    }
    
    @Override
    public void stream(HttpServletResponse response) throws Exception {
        response.getOutputStream().print(JSONObject.fromObject(object).toString());
    }
}
