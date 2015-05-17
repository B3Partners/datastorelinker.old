/*
 * Copyright (C) 2014 B3Partners B.V.
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
 */
public interface Publisher {
    public static final String PUBLISHER_TYPE_GEOSERVER = "GEOSERVER";
    public static final String PUBLISHER_TYPE_MAPSERVER = "MAPSERVER";
    
    boolean publishDb(String url,  String username, String password, Database.Type dbType, String host,int port, String dbUser, String dbPass,String schema,String database, String table, String workspace,String style, ServletContext context);
    boolean publishDB(String url,  String username, String password, Database.Type dbType, String host,int port, String dbUser, String dbPass,String schema,String database, String[] table, String workspace,String style, ServletContext context);
    
}
