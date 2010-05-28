/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

import nl.b3p.datastorelinker.js.ErrorMessage;

/**
 *
 * @author Erik van de Pol
 */
public class JSONErrorResolution extends JSONResolution {
    public JSONErrorResolution(String message, String title) {
        super(new ErrorMessage(message, title));
    }
}
