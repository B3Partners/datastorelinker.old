<%-- 
    Document   : i18n.js
    Created on : 26-jul-2010, 14:05:40
    Author     : Erik van de Pol
--%>

<%@page contentType="text/javascript" pageEncoding="UTF-8"%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

I18N = ${actionBean.keys};

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