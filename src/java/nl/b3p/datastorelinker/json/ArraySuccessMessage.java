/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

import net.sf.json.JSONArray;

/**
 *
 * @author Erik van de Pol
 */
public class ArraySuccessMessage extends SuccessMessage {
    private JSONArray array;

    public ArraySuccessMessage(boolean success) {
        super(success);
    }

    public ArraySuccessMessage(boolean success, JSONArray array) {
        super(success);
        this.array = array;
    }

    public JSONArray getArray() {
        return array;
    }

    public void setArray(JSONArray array) {
        this.array = array;
    }

}
