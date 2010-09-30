/**
 * $Id$
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.util.ResourceBundle;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;

/** ActionBean die resource keys uit de resource bundle doorgeeft aan de
 * client-side GUI via JSON.
 */
public class i18nAction extends DefaultAction {

    private JSONObject keys = new JSONObject();

    public JSONObject getKeys() {
        return keys;
    }

    public void setKeys(JSONObject keys) {
        this.keys = keys;
    }

    @DefaultHandler
    public Resolution view() {
        ResourceBundle res = ResourceBundle.getBundle("StripesResources", getContext().getLocale());

        for (String key : res.keySet()) {
            keys.put(key, res.getString(key));
        }

        return new ForwardResolution("/WEB-INF/jsp/commons/i18n.js.jsp");
    }
}
