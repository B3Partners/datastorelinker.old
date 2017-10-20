package nl.b3p.datastorelinker.security;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ConfigServlet extends HttpServlet {

    private static final Log log = LogFactory.getLog(ConfigServlet.class);
    public static String ANONIEM_ROL = "anoniem";
    public static String GEBRUIKERS_ROL = "gebruiker";
    public static String THEMABEHEERDERS_ROL = "themabeheerder";
    public static String DEMOGEBRUIKERS_ROL = "demogebruiker";
    public static String BEHEERDERS_ROL = "beheerder";
    public static String ANONYMOUS_USER = "anoniem";
    private static String kburl = null;
    public static String kbWfsConnectieNaam = "Kaartenbalie WFS";

    /**
     * http://www.kaartenbalie.nl/kaartenbalie/service/0c462abe62b69b2f05d1e72862f251f6
     * kburl: http://www.kaartenbalie.nl/kaartenbalie/service/ code:
     * 0c462abe62b69b2f05d1e72862f251f6
     *
     * Code kan alleen worden toegevoegd indien de kaartenbalie url eindigt op
     * een /. Er wordt een / toegevoegd indien dit niet het geval is.
     *
     */
    public static String createPersonalKbUrl(String code) {
        if (code != null && code.startsWith("http://")) {
            return code;
        }
        String url = getKbUrl();
        if (url != null) {
            url = url.trim();
            if (code != null && code.length() > 0) {
                if (url.lastIndexOf('/') == url.length() - 1) {
                    url += code;
                } else {
                    url += '/' + code;
                }
            }
        }
        return url;
    }

    public static String getKbUrl() {
        return kburl;
    }

    public static void setKbUrl(String aKburl) {
        kburl = aKburl;
    }

    /**
     * Initializes the servlet.
     */
    public void init(ServletConfig config) throws ServletException {
        super.init(config);

        try {
            String value = config.getInitParameter("kburl");
            if (value != null && value.length() > 0) {
                kburl = value;
            }
            value = config.getInitParameter("anonymous_user");
            if (value != null && value.length() > 0) {
                ANONYMOUS_USER = value;
            }
            value = config.getInitParameter("gebruikers_rol");
            if (value != null && value.length() > 0) {
                GEBRUIKERS_ROL = value;
            }
            value = config.getInitParameter("themabeheerders_rol");
            if (value != null && value.length() > 0) {
                THEMABEHEERDERS_ROL = value;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
