<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Datastorelinker loginfout</title>
    </head>

    <body>
        <span style="color: red; font-weight: bold">Loginfout!</span>

        <p>
            
        <form action="j_security_check" method="POST">
            <table>
                <tr><td>Gebruikersnaam:</td><td><input type="text" name="j_username" size="36"></td></tr>
                <tr><td>Wachtwoord:</td><td><input type="password" name="j_password" size="36"></td></tr>
                <tr><td style="text-align: right;" colspan="2"><input type="Submit" value="Login"></td></tr>
            </table>
        </form>
    </body>
</html>
