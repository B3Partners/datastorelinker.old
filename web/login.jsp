<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="DataStoreLinker login">
    <stripes:layout-component name="content">

        <script type="text/javascript">
            $(document).ready(function () {
                $("#usernameInput").focus();
            });
        </script>

        <img src="<stripes:url value="${contextPath}/images/datastorelinkerlogo.png"/>" alt="DataStoreLinker Logo" style="margin-left: 50px;" />

        <c:if test="${param['logout'] == 'y'}">
            U bent uitgelogd.
        </c:if>

        <form action="j_security_check" method="POST">
            <table>
                <tr><td>Gebruikersnaam:</td><td><input id="usernameInput" type="text" name="j_username" size="36"></td></tr>
                <tr><td>Wachtwoord:</td><td><input type="password" name="j_password" size="36"></td></tr>
                <tr><td style="text-align: right;" colspan="2"><input type="Submit" value="Login"></td></tr>
            </table>
        </form>
    </stripes:layout-component>
</stripes:layout-render>