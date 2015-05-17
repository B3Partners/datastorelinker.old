/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.util;

import java.util.Comparator;

/**
 *
 * @author Erik van de Pol
 */
public class NameableComparer implements Comparator<Nameable> {
    public int compare(Nameable n1, Nameable n2) {
        return n1.getName().compareToIgnoreCase(n2.getName());
    }
}
