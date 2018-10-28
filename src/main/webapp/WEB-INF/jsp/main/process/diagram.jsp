
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%-- 
    Document   : diagram
    Created on : Apr 25, 2014, 4:00:14 PM
    Author     : meine
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>    
        <title><fmt:message key="keys.processoverview"/></title>
        <meta http-equiv="content-type" content="text/html;charset=utf-8" />		
        <link rel="stylesheet" href="${contextPath}/styles/diagram.css">

        <script type="text/javascript" src="${contextPath}/scripts/jquery/jquery-latest.js"></script>
        <script type="text/javascript" src="${contextPath}/scripts/jquery-ui/jquery-ui-1.8.11.custom.js"></script>
        <script type="text/javascript" src="${contextPath}/scripts/jsPlump/jquery.jsPlumb-1.5.5.js"></script>
        <script type="text/javascript" src="${contextPath}/scripts/jquery.qtip/jquery.qtip-latest.js"></script>
        <script src="${contextPath}/scripts/diagram.js"></script>
    </head>
    <script class="ui-layout-ignore">
        var processes = ${actionBean.jsonProcesses};
    </script>
    <body>
        <h1><fmt:message key="keys.processoverview"/></h1>
        <div id="main" class="demo chart-demo">	
        </div>
    </body>
</html>