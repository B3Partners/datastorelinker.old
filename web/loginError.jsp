<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="DataStoreLinker fout">
    <stripes:layout-component name="content">

        <span style="color: red; font-weight: bold">Loginfout!</span>

        <%@include file="/loginForm.jsp" %>

    </stripes:layout-component>
</stripes:layout-render>