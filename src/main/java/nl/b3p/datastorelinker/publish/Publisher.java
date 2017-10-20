/*
 * Copyright (C) 2014-2017 B3Partners B.V.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.b3p.datastorelinker.publish;

import javax.servlet.ServletContext;
import nl.b3p.datastorelinker.entity.Database;

/**
 *
 * @author Meine Toonen
 * @author mprins
 */
public interface Publisher {

    public static final String PUBLISHER_TYPE_GEOSERVER = "GEOSERVER";
    public static final String PUBLISHER_TYPE_MAPSERVER = "MAPSERVER";

    PublishStatus publishDb(String url, String username, String password, Database.Type dbType, String host, int port, String dbUser, String dbPass, String schema, String database, String table, String workspace, String style, ServletContext context);

    PublishStatus publishDB(String url, String username, String password, Database.Type dbType, String host, int port, String dbUser, String dbPass, String schema, String database, String[] table, String workspace, String style, ServletContext context);

    /**
     * implementeer deze methode om de SRS op een publisher in te stellen.
     *
     * @param strSRS de te gebruiken SRS, de waarde is voor iedere soort server
     * anders, indien {@code null} dan wordt de default gebruikt.
     */
    default void setStrSRS(String strSRS) {
    }

}
