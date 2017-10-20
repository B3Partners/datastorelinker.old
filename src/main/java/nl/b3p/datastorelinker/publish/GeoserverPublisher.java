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

import it.geosolutions.geoserver.rest.GeoServerRESTManager;
import it.geosolutions.geoserver.rest.GeoServerRESTReader;
import it.geosolutions.geoserver.rest.encoder.GSLayerEncoder;
import it.geosolutions.geoserver.rest.encoder.datastore.GSAbstractDatastoreEncoder;
import it.geosolutions.geoserver.rest.encoder.datastore.GSOracleNGDatastoreEncoder;
import it.geosolutions.geoserver.rest.encoder.datastore.GSPostGISDatastoreEncoder;
import it.geosolutions.geoserver.rest.encoder.feature.GSFeatureTypeEncoder;
import it.geosolutions.geoserver.rest.manager.GeoServerRESTStoreManager;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import javax.servlet.ServletContext;
import net.sourceforge.stripes.util.Log;
import nl.b3p.datastorelinker.entity.Database;

/**
 *
 * @author Meine Toonen
 * @author mprins
 */
public class GeoserverPublisher implements Publisher {

    private final static Log LOG = Log.getInstance(GeoserverPublisher.class);

    private String strSRS = "EPSG:28992";

    @Override
    public PublishStatus publishDb(String url, String username, String password,
            Database.Type dbType, String host, int port, String dbUser, String dbPass, String schema,
            String database, String table, String workspace, String style, ServletContext context) {

        String[] tables = {table};
        return publishDB(url, username, password, dbType, host, port, dbUser, dbPass, schema, database, tables, workspace, style, context);
    }

    private boolean publishLayer(String table, String style, String database,
            String workspace, GeoServerRESTManager manager,
            GeoServerRESTReader reader, PublishStatus status) {

        GSFeatureTypeEncoder type = new GSFeatureTypeEncoder();
        type.setName(table);
        type.setSRS(this.strSRS);
        GSLayerEncoder layer = new GSLayerEncoder();
        layer.setDefaultStyle(style);
        boolean published = manager.getPublisher().publishDBLayer(workspace, database, type, layer);
        if (!published) {
            if (reader.existsLayer(workspace, table, true)) {
                status.getLayersFailedMessages().append("Laag ");
                status.getLayersFailedMessages().append(table);
                status.getLayersFailedMessages().append(" bestaat al in service. <br/>");
            }
        }
        return published;
    }

    private boolean createDatastore(String host, int port, String dbUser, String dbPass, String schema, String database,
            String workspace, Database.Type dbType, GeoServerRESTManager manager) {

        GeoServerRESTStoreManager storeMan = manager.getStoreManager();
        GSAbstractDatastoreEncoder ds = null;
        if (null != dbType) {
            switch (dbType) {
                case POSTGIS:
                    ds = new GSPostGISDatastoreEncoder(database);
                    ((GSPostGISDatastoreEncoder) ds).setDatabase(database);
                    ((GSPostGISDatastoreEncoder) ds).setHost(host);
                    ((GSPostGISDatastoreEncoder) ds).setPassword(dbPass);
                    ((GSPostGISDatastoreEncoder) ds).setUser(dbUser);
                    ((GSPostGISDatastoreEncoder) ds).setNamespace(workspace);
                    ((GSPostGISDatastoreEncoder) ds).setSchema(schema);
                    ((GSPostGISDatastoreEncoder) ds).setPort(port);
                    break;
                case ORACLE:
                    ds = new GSOracleNGDatastoreEncoder(database, database);
                    ((GSOracleNGDatastoreEncoder) ds).setHost(host);
                    ((GSOracleNGDatastoreEncoder) ds).setHost(host);
                    ((GSOracleNGDatastoreEncoder) ds).setPassword(dbPass);
                    ((GSOracleNGDatastoreEncoder) ds).setUser(dbUser);
                    ((GSOracleNGDatastoreEncoder) ds).setNamespace(workspace);
                    ((GSOracleNGDatastoreEncoder) ds).setSchema(schema);
                    ((GSOracleNGDatastoreEncoder) ds).setPort(port);
                    break;
                default:
                    throw new IllegalArgumentException("Database type must be of Postgis or Oracle");
            }
        }
        boolean created = storeMan.create(workspace, ds);
        return created;
    }

    @Override
    public PublishStatus publishDB(String url, String username, String password, Database.Type dbType, String host, int port,
            String dbUser, String dbPass, String schema, String database, String[] tables,
            String workspace, String style, ServletContext context) {

        PublishStatus status = new PublishStatus();
        try {
            GeoServerRESTManager manager = new GeoServerRESTManager(new URL(url), username, password);
            GeoServerRESTReader reader = manager.getReader();
            if (reader.existGeoserver()) {
                boolean b = manager.getPublisher().createWorkspace(workspace, new URI(workspace));
                status.setServiceCreated(b);
                if (!b) {
                    if (reader.existsWorkspace(workspace)) {
                        status.setServiceMessage("Workspace bestaat al.");
                    }
                }
                boolean createdStore = createDatastore(host, port, dbUser, dbPass, schema, database, workspace, dbType, manager);
                status.setStoreCreated(createdStore);
                if (!createdStore) {
                    if (reader.existsDatastore(workspace, database)) {
                        status.setStoreMessage("Datastore bestaat al.");
                    }
                }

                for (String table : tables) {
                    boolean published = publishLayer(table, style, database, workspace, manager, reader, status);
                    if (published) {
                        status.getLayersSucceeded().add(table);
                    } else {
                        status.getLayersFailed().add(table);
                    }
                }
            } else {
                status.setFatal(true);
                status.setFatalMessage("Geoserver bestaat niet");
            }
        } catch (MalformedURLException | URISyntaxException ex) {
            LOG.error("Failed to initialize restapi: ", ex);
            status.setFatal(true);
        }
        return status;
    }

    @Override
    public void setStrSRS(String strSRS) {
        if (strSRS == null) {
            return;
        }
        this.strSRS = strSRS;
    }
}
