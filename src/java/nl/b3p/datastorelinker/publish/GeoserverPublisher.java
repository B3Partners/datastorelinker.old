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

import it.geosolutions.geoserver.rest.GeoServerRESTManager;
import it.geosolutions.geoserver.rest.encoder.GSLayerEncoder;
import it.geosolutions.geoserver.rest.encoder.datastore.GSPostGISDatastoreEncoder;

import it.geosolutions.geoserver.rest.encoder.feature.GSFeatureTypeEncoder;
import it.geosolutions.geoserver.rest.manager.GeoServerRESTStoreManager;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import javax.servlet.ServletContext;
import net.sourceforge.stripes.util.Log;

/**
 *
 * @author Meine Toonen
 */
public class GeoserverPublisher implements Publisher {

    private final static Log log = Log.getInstance(GeoserverPublisher.class);
    private final static String DEFAULT_STYLE_NAME= "WEB-INF/defaultStyle.xml";

    public boolean publishDb(String url, String username, String password, String host, String dbUser, String dbPass, String schema, String database, String table, String workspace,String style, ServletContext context) {
        try {
            GeoServerRESTManager manager = new GeoServerRESTManager(new URL(url), username, password);
            boolean b = manager.getPublisher().createWorkspace(workspace, new URI(workspace));
            boolean createdStore = createDatastore(host, dbUser, dbPass, schema, database, workspace, manager);
            boolean published = publishLayer(table, style, database, workspace, manager);
            return published;

        } catch (MalformedURLException ex) {
            log.error("Failed to initialize restapi: ", ex);
            return false;
        } catch (URISyntaxException ex) {
            log.error("Failed to initialize restapi: ", ex);
        }
        return false;
    }

    private boolean publishLayer( String table, String style,String database, String workspace,GeoServerRESTManager manager ){
        
        GSFeatureTypeEncoder type = new GSFeatureTypeEncoder();
        type.setName(table);
        type.setSRS("EPSG:28992");
        GSLayerEncoder layer = new GSLayerEncoder();
        layer.setDefaultStyle(style);
        boolean published = manager.getPublisher().publishDBLayer(workspace, database, type, layer);
        return published;
    }

    private boolean createDatastore(String host, String dbUser, String dbPass, String schema, String database, String workspace,GeoServerRESTManager manager) {
        GeoServerRESTStoreManager storeMan = manager.getStoreManager();

        GSPostGISDatastoreEncoder ds = new GSPostGISDatastoreEncoder(database);
        ds.setDatabase(database);
        ds.setHost(host);
        ds.setPassword(dbPass);
        ds.setUser(dbUser);
        ds.setNamespace(workspace);
        ds.setSchema(schema);
        ds.setPort(5432);
        
        boolean created = storeMan.create(workspace, ds);
        return created;
    }

    public static void main(String[] args) {
        GeoserverPublisher pub = new GeoserverPublisher();
        boolean succeeded = pub.publishDb("http://localhost:8084/geoserver/", "admin", "***REMOVED***", "localhost", "flamingo", "24in0Ubg", "public", "test", "gemeentes","vru", "polygon",null);
    }

}
