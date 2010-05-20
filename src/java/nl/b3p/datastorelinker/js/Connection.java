/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.js;

/**
 *
 * @author Erik van de Pol
 */
public class Connection extends Message {
    private boolean valid = false;

    public boolean isValid() {
        return valid;
    }

    public void setValid(boolean valid) {
        this.valid = valid;
    }

}
