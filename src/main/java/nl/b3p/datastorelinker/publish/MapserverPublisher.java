package nl.b3p.datastorelinker.publish;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import javax.servlet.ServletContext;
import net.sourceforge.stripes.util.Log;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.geotools.data.linker.DataStoreLinker;
import nl.b3p.mapfile.pojo.ClassStyle;
import nl.b3p.mapfile.pojo.Layer;
import nl.b3p.mapfile.pojo.LayerClass;
import nl.b3p.mapfile.pojo.Mapfile;
import nl.b3p.mapfile.pojo.WebMetadata;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.VelocityEngine;
import org.geotools.data.DataStore;
import org.geotools.data.Query;
import org.geotools.feature.FeatureCollection;
import org.geotools.feature.FeatureIterator;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;

/**
 *
 * @author Boy de Wit
 * @author mprins
 */
public class MapserverPublisher implements Publisher {

    private final static Log log = Log.getInstance(MapserverPublisher.class);

    private String propertiesFile = "/WEB-INF/velocity.properties";
    private int strSRS = 28992;

    public PublishStatus publishDb(String url, String username, String password,
            Database.Type dbType, String host, int port, String dbUser,
            String dbPass, String schema, String database, String table,
            String serviceName, String style, ServletContext context) {
        PublishStatus status = new PublishStatus();

        String[] tables = new String[1];
        tables[0] = table;

        return createMapfile(dbType, host, port, dbUser, dbPass, schema,
                database, tables, serviceName, context);
    }

    public PublishStatus publishDB(String url, String username, String password,
            Database.Type dbType, String host, int port, String dbUser,
            String dbPass, String schema, String database, String[] table,
            String serviceName, String style, ServletContext context) {
        PublishStatus status = new PublishStatus();
        return createMapfile(dbType, host, port, dbUser, dbPass, schema,
                database, table, serviceName, context);
    }

    private PublishStatus createMapfile(Database.Type dbType, String host, int port,
            String dbUser, String dbPass, String schema, String database,
            String[] tables, String serviceName, ServletContext c) {
        PublishStatus status = new PublishStatus();
        String mapFilePath = c.getInitParameter("publisher.mapfileLocation");

        if (host == null || mapFilePath == null || serviceName == null) {
            throw new IllegalArgumentException("Missende Mapserver parameters.");
        }

        /* Basis mapfile velocity template */
        Mapfile map = new Mapfile();

        /* nu */
        Date now = new Date();
        SimpleDateFormat df = new SimpleDateFormat("d MMMMM yyyy HH:mm",
                new Locale("NL"));

        map.setCreateDate(df.format(now));
        map.setName(serviceName.replaceAll(" ", "_") + "_Service");
        map.setDatabaseType(dbType.toString().toLowerCase());

        WebMetadata webMeta = new WebMetadata();

        String resource = createResourceString(host, mapFilePath, serviceName);

        webMeta.setWmsTitle(serviceName + " Service");
        webMeta.setWmsOnlineResource(resource);
        webMeta.setWfsTitle(serviceName + " WFS Service");
        webMeta.setWfsOnlineResource(resource);
        webMeta.setOwsTitle(serviceName + " OWS Service");
        webMeta.setOwsOnlineResource(resource);

        map.getWeb().setMetadata(webMeta);

        /* Voor ieder gekozen tabel geom info ophalen voor in mapfile */
        DataStore ds = openDataStore(schema, port, dbPass, dbType.toString(),
                host, dbUser, database);

        try {
            for (int i = 0; i < tables.length; i++) {
                String tableName = tables[i];
                SimpleFeature feature = null;

                if (ds != null) {
                    feature = getExampleFeature(ds, tableName);

                    if (feature != null) {
                        String type = getTableGeomType(feature);
                        String geomColumn = getGeomColumnName(feature);
                        String pkColumn = getPkColumn(feature);

                        Layer l = createMapfileLayer(tableName, type);

                        fillConnectionAndData(l, type, database, host, port, dbUser,
                                dbPass, geomColumn, tableName, pkColumn, dbType);

                        map.addLayer(l);
                    }
                }
            }

        } catch (Exception ex) {
            log.error("Fout tijdens ophalen tabel types: ", ex);
        } finally {
            if (ds != null) {
                ds.dispose();
            }
        }

        try {
            VelocityEngine ve = new VelocityEngine();
            ve.setApplicationAttribute("javax.servlet.ServletContext", c);
            ve.init(loadConfiguration(propertiesFile, c));
            Template t = ve.getTemplate("basis.vm");
            VelocityContext vcontext = new VelocityContext();
            vcontext.put("map", map);

            StringWriter writer = new StringWriter();
            t.merge(vcontext, writer);

            log.info(writer.toString());

            //return true;
        } catch (Exception e) {
            log.error("Fout bij maken mapfile: ", e);
        }

        /* Mapfile POST'en of ergens op server plaatsen ? */
        return status;
    }

    private void fillConnectionAndData(Layer layer, String type,
            String db, String host, int port, String user, String passw,
            String geomColumn, String tableName, String pkColumn,
            Database.Type dbType) {

        if (dbType.equals(Database.Type.ORACLE)) {
            layer.setConnectionType("oraclespatial");
        } else if (dbType.equals(Database.Type.POSTGIS)) {
            layer.setConnectionType("postgis");
        } else {
            layer.setConnectionType("");
        }

        layer.setConnectionDatabase(db);
        layer.setConnectionHost(host);
        layer.setConnectionPort(port);
        layer.setConnectionUser(user);
        layer.setConnectionPassword(passw);
        layer.setDataGeomColumn(geomColumn);
        layer.setDataTableName(tableName);
        layer.setDataPrimaryKeyColumn(pkColumn);

        if (dbType.equals(Database.Type.ORACLE)) {
            layer.setDataSrid(strSRS);
        } else {
            layer.setDataSrid(strSRS);
        }
    }

    private Layer createMapfileLayer(String tableName, String type) {
        Layer layer = new Layer();

        layer.setName(tableName);
        layer.setType(type);

        layer.getMetadata().setWmsTitle(tableName);
        layer.getMetadata().setWfsTitle(tableName);
        layer.getMetadata().setOwsTitle(tableName);

        LayerClass layerClass = new LayerClass();
        layerClass.setName(tableName);

        ClassStyle style = new ClassStyle();
        if (type.equals("POINT")) {
            style.setSymbol("circle");
            style.setOutlineColorR(0);
            style.setOutlineColorG(0);
            style.setOutlineColorB(0);
            style.setColorR(255);
            style.setColorG(255);
            style.setColorB(255);
        } else if (type.equals("LINE")) {
            style.setOutlineColorR(0);
            style.setOutlineColorG(0);
            style.setOutlineColorB(0);
            style.setColorR(0);
            style.setColorG(255);
            style.setColorB(0);
            style.setWidth(2.0);
        } else {
            style.setOutlineColorR(0);
            style.setOutlineColorG(0);
            style.setOutlineColorB(0);
            style.setColorR(0);
            style.setColorG(0);
            style.setColorB(255);
        }

        layerClass.setStyle(style);

        layer.addLayerClass(layerClass);

        return layer;
    }

    private DataStore openDataStore(String schema, int port, String passw,
            String dbType, String host, String user, String database) {

        DataStore ds = null;

        Map params = new HashMap();

        params.put("schema", schema);
        params.put("port", port);
        params.put("passwd", passw);

        params.put("dbtype", dbType.toLowerCase());
        params.put("host", host);
        params.put("validate connections", false);
        params.put("user", user);
        params.put("database", database);

        try {
            ds = DataStoreLinker.openDataStore(params);
        } catch (Exception ex) {
            log.error("Fout openen Datastore: ", ex);
        }

        return ds;
    }

    private String getPkColumn(SimpleFeature feature) {
        return feature.getFeatureType()
                .getAttributeDescriptors().get(0).getLocalName();
    }

    private String getGeomColumnName(SimpleFeature feature) {
        return feature.getDefaultGeometryProperty().getDescriptor().getLocalName();
    }

    private String getTableGeomType(SimpleFeature feature) {
        String type = feature.getDefaultGeometry().toString();

        if (type.toUpperCase().contains("POINT")) {
            return "POINT";
        }

        if (type.toUpperCase().contains("LINE")) {
            return "LINE";
        }

        if (type.toUpperCase().contains("POLYGON")) {
            return "POLYGON";
        }

        return "POLYGON";
    }

    private SimpleFeature getExampleFeature(DataStore ds, String tableName) throws Exception {
        //log.debug((Object[])ds.getTypeNames());
        if (tableName == null) {
            if (ds.getTypeNames().length == 0) {
                throw new IllegalArgumentException("no typeNames");
            }
            tableName = ds.getTypeNames()[0];
        }

        Query q = new Query();
        q.setMaxFeatures(1);
        FeatureCollection<SimpleFeatureType, SimpleFeature> fc
                = ds.getFeatureSource(tableName).getFeatures(q);

        FeatureIterator iterator = fc.features();
        try {
            if (iterator.hasNext()) {
                return (SimpleFeature) iterator.next();
            }
        } finally {
            if (iterator != null) {
                iterator.close();
            }
        }

        throw new Exception("Geen features gevonden.");
    }

    private String createResourceString(String mapserverUrl, String mapFilePath,
            String serviceName) {

        StringBuilder str = new StringBuilder();

        str.append(mapserverUrl);

        if (!mapserverUrl.contains("?")) {
            str.append("?");
        }

        str.append("map=");

        str.append(mapFilePath);

        if (mapFilePath.lastIndexOf("/") != mapFilePath.length() - 1) {
            str.append("/");
        }

        String name = createMapFileName(serviceName);

        str.append(name);

        return str.toString();
    }

    private String createMapFileName(String serviceName) {
        String fileName = serviceName.trim().replaceAll(" ", "");

        fileName += ".map";

        return fileName.toLowerCase();
    }

    private Properties loadConfiguration(String propsFile, ServletContext context)
            throws IOException, FileNotFoundException {

        Properties p = new Properties();
        if (propsFile != null) {
            InputStream iStream = context.getResourceAsStream(propsFile);
            if (iStream != null) {
                p.load(iStream);
            }
        }
        return p;
    }

    @Override
    public void setStrSRS(String strSRS) {
        if (strSRS == null) {
            return;
        }
        try {
            this.strSRS = Integer.parseInt(strSRS);
        } catch (NumberFormatException nfe) {
            log.error(nfe, new Object[]{nfe.getLocalizedMessage(), "Controleer de SRS waarde in de context.xml"});
        }

    }
}
