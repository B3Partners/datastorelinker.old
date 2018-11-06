<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<fmt:message key="index.loginerrortitle" var="loginerrortitle"/>
<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="${loginerrortitle}">
    <stripes:layout-component name="content">

        <div class="login">
            <div class="ui-state-error message"><fmt:message key="index.loginerror"/></div>

            <%@include file="/loginForm.jsp" %>
        </div>
        
    </stripes:layout-component>
</stripes:layout-render>