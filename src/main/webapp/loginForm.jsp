<%-- 
    Document   : loginForm
    Created on : 16-sep-2010, 17:49:11
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(document).ready(function () {
        // in header:
        $(".login-info-block").remove();

        $("#usernameInput").focus();
        $("#loginSubmit").button();
        layoutMain();
    });
</script>

<div>
    <h1><fmt:message key="index.login"/></h1>
    <form action="j_security_check" method="POST">
        <table>
            <tr>
                <td><fmt:message key="index.username"/>:</td>
                <td><input id="usernameInput" type="text" name="j_username" size="36" class="login-field"></td>
            </tr>
            <tr>
                <td><fmt:message key="index.pw"/>:</td>
                <td><input type="password" name="j_password" size="36" class="login-field"></td>
            </tr>
            <tr>
                <td style="text-align: right;" colspan="2">
                    <input id="loginSubmit" type="Submit" value="Login">
                </td>
            </tr>
        </table>
    </form>
</div>
