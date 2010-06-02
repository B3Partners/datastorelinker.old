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
public class Util {
    public static void addToMapIfNotNull(Map<String, Object> map, String key, Object value) {
        addToMapIfNotNull(map, key, value, "");
    }

    public static void addToMapIfNotNull(Map<String, Object> map, String key, Object value, String keyPrefix) {
        if (keyPrefix == null)
            keyPrefix = "";
        if (key != null && value != null)
            map.put(keyPrefix + key, value);
    }
}
