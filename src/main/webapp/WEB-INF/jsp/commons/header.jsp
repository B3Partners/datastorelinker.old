<%--
    Document   : header
    Created on : 16-sep-2010, 17:32:26
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<div class="ui-layout-content header">
    <div id="topmenu" class="login-info-block">
        <a class="menulink logged-in-as">
            <fmt:message key="loggedInAs"/>
            ${pageContext.request.remoteUser}
        </a>
        <stripes:link href="/logout.jsp" class="menulink logout-link"><fmt:message key="keys.logout"/></stripes:link>
    </div>
    <div class="header_logo"></div>
</div>
