<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>


<% request.getSession().invalidate(); %>


<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="DataStoreLinker uitgelogd">
    <stripes:layout-component name="content">

        <div class="login">
            <div class="ui-state-success message">U bent uitgelogd.</div>

            <%@include file="/loginForm.jsp" %>
        </div>

    </stripes:layout-component>
</stripes:layout-render>