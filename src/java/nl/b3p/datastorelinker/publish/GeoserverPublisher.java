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
import it.geosolutions.geoserver.rest.GeoServerRESTPublisher;
import it.geosolutions.geoserver.rest.decoder.RESTDataStore;
import it.geosolutions.geoserver.rest.decoder.RESTDataStoreList;
import it.geosolutions.geoserver.rest.encoder.GSLayerEncoder;
import it.geosolutions.geoserver.rest.encoder.datastore.GSAbstractDatastoreEncoder;
import it.geosolutions.geoserver.rest.encoder.datastore.GSPostGISDatastoreEncoder;
import it.geosolutions.geoserver.rest.encoder.feature.GSFeatureTypeEncoder;
import it.geosolutions.geoserver.rest.manager.GeoServerRESTStoreManager;
import java.net.MalformedURLException;
import java.net.URL;
import net.sourceforge.stripes.util.Log;

/**
 *
 * @author Meine Toonen
 */
public class GeoserverPublisher implements Publisher{
    private final static Log log = Log.getInstance(GeoserverPublisher.class);

    public boolean publishDb(String url, String username, String password,String host, String dbUser, String dbPass,String schema,String database, String table, String style) {
        try {
            GeoServerRESTManager manager = new GeoServerRESTManager(new URL(url), username, password);
            String sld = manager.getReader().getSLD("red");

            boolean b =  manager.getPublisher().createWorkspace("***REMOVED***");
            GeoServerRESTStoreManager storeMan =  manager.getStoreManager();
            
            GSPostGISDatastoreEncoder ds = new GSPostGISDatastoreEncoder("aap");
            ds.setDatabase(database);
            ds.setHost(host);
            ds.setPassword(dbPass);
            ds.setUser(dbUser);
            ds.setSchema(schema);
            ds.setPort(5432);
            boolean st = storeMan.create("***REMOVED***", ds);
            if(st){
                GSFeatureTypeEncoder type = new GSFeatureTypeEncoder();
                type.setName(table);
                type.setTitle("GemeenteTitel");
                type.setSRS("EPSG:28992");
                GSLayerEncoder layer = new GSLayerEncoder();
                layer.setDefaultStyle(style);
                
                boolean la = manager.getPublisher().publishDBLayer("***REMOVED***", "aap", type,layer);
                int  a = 0;
            }
            int a = 0;
            
        } catch (MalformedURLException ex) {
            log.error("Failed to initialize restapi: ",ex);
        }
        return true;
    }
    
    public static void main(String[] args){
        GeoserverPublisher pub = new GeoserverPublisher();
        boolean succeeded= pub.publishDb("http://localhost:8084/geoserver/", "admin", "***REMOVED***", "localhost", "flamingo","24in0Ubg", "public","test", "gemeentes", "polygon");
    }
    
}
