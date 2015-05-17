/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

/**
 *
 * @author Erik van de Pol
 */
public class ProgressMessage extends Message {
    private int progress;
    private String fatalError;

    public ProgressMessage(int progress) {
        super("", "");
        this.progress = progress;
    }

    public ProgressMessage(int progress, String message) {
        super(message, "");
        this.progress = progress;
    }

    public ProgressMessage(int progress, String message, String title) {
        super(message, title);
        this.progress = progress;
    }

    public ProgressMessage(String fatalError) {
        super("", "");
        this.fatalError = fatalError;
    }

    public int getProgress() {
        return progress;
    }

    public void setProgress(int progress) {
        this.progress = progress;
    }

    public String getFatalError() {
        return fatalError;
    }

    public void setFatalError(String fatalError) {
        this.fatalError = fatalError;
    }

}
