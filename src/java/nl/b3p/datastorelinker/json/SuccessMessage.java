/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

/**
 *
 * @author Erik van de Pol
 */
public class SuccessMessage extends Message {
    protected boolean success;

    public SuccessMessage() {
        this(true, "", "");
    }

    public SuccessMessage(boolean success) {
        this(success, "", "");
    }

    public SuccessMessage(boolean success, String message, String title) {
        super(message, title);
        this.success = success;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

}
