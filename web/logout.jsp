<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<% request.getSession().invalidate(); %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta http-equiv="refresh" content="0;url=${contextPath}/WEB-INF/jsp/login/login.jsp?logout=y">
        <title>Uitloggen</title>
    </head>
    <body>
        <h1>Uitloggen</h1>

        <p>
        U bent uitgelogd.
    </body>
</html>
