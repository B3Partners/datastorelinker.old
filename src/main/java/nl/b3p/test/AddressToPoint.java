package nl.b3p.test;

import org.locationtech.jts.geom.Geometry;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.locationtech.jts.io.ParseException;
import org.locationtech.jts.io.WKTReader;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.nio.charset.Charset;
import org.geotools.geometry.jts.JTS;
import org.geotools.referencing.CRS;
import org.json.JSONException;
import org.json.JSONObject;
import org.opengis.referencing.crs.CoordinateReferenceSystem;
import org.opengis.referencing.operation.MathTransform;

/**
 *
 * @author Boy de Wit
 */
public class AddressToPoint {

    private static String googleBaseUrl = "http://maps.google.nl/maps/geo?q=";
    //private static String googleBaseUrl = "http://bag42.nl/api/v0/geocode/json?maxitems=1&address=";
    private static String readAll(Reader rd) throws IOException {
        StringBuilder sb = new StringBuilder();
        int cp;
        while ((cp = rd.read()) != -1) {
            sb.append((char) cp);
        }
        return sb.toString();
    }

    public static JSONObject readJsonFromUrl(String url) throws IOException, JSONException {
        InputStream is = new URL(url).openStream();
        try {
            BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
            String jsonText = readAll(rd);
            JSONObject json = new JSONObject(jsonText);
            return json;
        } finally {
            is.close();
        }
    }

    private static Point convertWktToRdsPoint(String wkt) {
        Point p = null;

        try {
            Geometry sourceGeometry = createGeomFromWKTString(wkt);

            if (sourceGeometry != null) {
                CoordinateReferenceSystem sourceCRS = CRS.decode("EPSG:4326");
                CoordinateReferenceSystem targetCRS = CRS.decode("EPSG:28992");

                MathTransform transform = CRS.findMathTransform(sourceCRS, targetCRS, true);

                if (transform != null) {
                    Geometry targetGeometry = JTS.transform(sourceGeometry, transform);

                    if (targetGeometry != null) {
                        targetGeometry.setSRID(4326);
                        p = targetGeometry.getCentroid();
                    }
                }
            }

        } catch (Exception ex) {
            System.out.println("Fout tijdens conversie wkt naar latlon: " + ex);
        }

        return p;
    }

    public static Geometry createGeomFromWKTString(String wktstring) throws Exception {
        WKTReader wktreader = new WKTReader(new GeometryFactory(new PrecisionModel(), 28992));
        try {
            return wktreader.read(wktstring);
        } catch (ParseException ex) {
            throw new Exception(ex);
        }

    }
}
