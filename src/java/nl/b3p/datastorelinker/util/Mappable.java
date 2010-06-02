/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.util;

import java.util.Map;

/**
 *
 * @author Erik van de Pol
 */
public interface Mappable {
    public Map<String, Object> toMap();
    public Map<String, Object> toMap(String keyPrefix);

}
