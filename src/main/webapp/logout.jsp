<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>


<% request.getSession().invalidate(); %>


<fmt:message key="index.logouttitle" var="logouttitle"/>
<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="${logouttitle}">
    <stripes:layout-component name="content">

        <div class="login">
            <div class="ui-state-success message"><fmt:message key="index.logout"/></div>

            <%@include file="/loginForm.jsp" %>
        </div>

    </stripes:layout-component>
</stripes:layout-render>