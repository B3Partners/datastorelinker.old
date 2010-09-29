<%-- 
    Document   : i18n.js
    Created on : 26-jul-2010, 14:05:40
    Author     : Erik van de Pol
--%>
<%@page import="java.util.Locale"%>
<%@page import="nl.b3p.datastorelinker.gui.stripes.ProcessAction"%>
<%@page import="net.sourceforge.stripes.util.Log"%>
<%@page import="net.sourceforge.stripes.localization.DefaultLocalePicker"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="java.util.ResourceBundle"%>

<%@page contentType="text/javascript" %>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

I18N = {};
<%
Log log = Log.getInstance(ProcessAction.class);

DefaultLocalePicker defaultLocalePicker = new DefaultLocalePicker();
log.debug("i18n.js.jsp");
//log.debug(defaultLocalePicker.pickLocale(request));

//pageContext. // is geen ActionBeanContext en bevat dus geen .getLocale() !!?!! 
//Enige enigszins nette optie is Locale

ResourceBundle res = ResourceBundle.getBundle(
        "StripesResources",
        //defaultLocalePicker.pickLocale(request));
        new Locale("nl")); // FIXME: this is so hardcoded ugly, I just can't look at it.
                           // TODO: get Locale from web.xml Stripes config

for (String rawKey : res.keySet()) {
    // will only print keys without a "." in it
    if (!rawKey.contains(".")) {
        String key = StringEscapeUtils.escapeJavaScript(rawKey);
        String value = StringEscapeUtils.escapeJavaScript(res.getString(key));
        out.println("I18N[\"" + key + "\"] = \"" + value + "\";");
    }
}
%>

// used as objects for Cron:
I18N.daysOfTheWeek = {
    1: "<fmt:message key="sunday"/>",
    2: "<fmt:message key="monday"/>",
    3: "<fmt:message key="tuesday"/>",
    4: "<fmt:message key="wednesday"/>",
    5: "<fmt:message key="thursday"/>",
    6: "<fmt:message key="friday"/>",
    7: "<fmt:message key="saturday"/>"
};
I18N.monthsOfTheYear = {
    1: "<fmt:message key="january"/>",
    2: "<fmt:message key="february"/>",
    3: "<fmt:message key="march"/>",
    4: "<fmt:message key="april"/>",
    5: "<fmt:message key="may"/>",
    6: "<fmt:message key="june"/>",
    7: "<fmt:message key="july"/>",
    8: "<fmt:message key="august"/>",
    9: "<fmt:message key="september"/>",
    10: "<fmt:message key="october"/>",
    11: "<fmt:message key="november"/>",
    12: "<fmt:message key="december"/>"
};

log(I18N);

