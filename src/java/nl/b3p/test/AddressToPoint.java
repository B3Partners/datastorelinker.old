package nl.b3p.test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONException;
import org.json.JSONObject;

/**
 *
 * @author Boy de Wit
 */
public class AddressToPoint {

    private static String googleBaseUrl = "http://maps.google.nl/maps/geo?q=";

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

    public static void main(String[] args) {

        // Voorbeel verzoek
        // http://maps.google.nl/maps/geo?q=tak+van+poortvlietstraat+12,+Den+Haag&hl=nl
        
        String adres = "tak van poortvlietstraat 12";
        String plaats = ",+Den Haag";
        String hl = "&hl=nl";
        String output = "&output=json";

        JSONObject json;
        try {
            String encodedParams = URLEncoder.encode(adres + plaats, "UTF-8");
            String otherParams = hl + output;

            String url = googleBaseUrl + encodedParams + otherParams;

            json = readJsonFromUrl(url);

            Double x = (Double) json.getJSONArray("Placemark").getJSONObject(0).getJSONObject("Point").getJSONArray("coordinates").get(0);
            Double y = (Double) json.getJSONArray("Placemark").getJSONObject(0).getJSONObject("Point").getJSONArray("coordinates").get(1);

            System.out.println("lat=" +x + " lng=" +y);
            
        } catch (IOException ex) {
            Logger.getLogger(AddressToPoint.class.getName()).log(Level.SEVERE, null, ex);
        } catch (JSONException ex) {
            Logger.getLogger(AddressToPoint.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
