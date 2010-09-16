<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>


<% request.getSession().invalidate(); %>


<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="DataStoreLinker uitgelogd">
    <stripes:layout-component name="content">

        U bent uitgelogd.

        <%@include file="/loginForm.jsp" %>

    </stripes:layout-component>
</stripes:layout-render>