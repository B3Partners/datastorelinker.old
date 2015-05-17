/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

/**
 *
 * @author Erik van de Pol
 */
public class ErrorMessage extends SuccessMessage {

    /*public ErrorMessage(String message) {
        this(message, "");
    }*/

    public ErrorMessage(String message, String title) {
        super(false, message, title);
        // enums?
        this.type = "error";
    }

}
