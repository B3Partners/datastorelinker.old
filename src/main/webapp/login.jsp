<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<fmt:message key="index.logintitle" var="logintitle"/>
<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp"  pageTitle="${logintitle}">
    <stripes:layout-component name="content">

        <div class="login">
            <%@include file="/loginForm.jsp" %>
        </div>

    </stripes:layout-component>
</stripes:layout-render>