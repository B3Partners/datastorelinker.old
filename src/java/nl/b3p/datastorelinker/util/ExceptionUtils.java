/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.util;

/**
 *
 * @author Erik van de Pol
 */
public class ExceptionUtils {
    public static Throwable getUltimateCause(Throwable t) {
        Throwable cause = t;
        while (cause.getCause() != null) {
            cause = cause.getCause();
        }
        return cause;
    }

    public static String getReadableExceptionMessage(Throwable t) {
        return t.getMessage() != null ? t.getMessage() : t.getClass().getName();
    }
    
}
