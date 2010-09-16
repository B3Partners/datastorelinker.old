<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="DataStoreLinker fout">
    <stripes:layout-component name="content">

        <div class="login">
            <div class="ui-state-error message">Loginfout!</div>

            <%@include file="/loginForm.jsp" %>
        </div>
        
    </stripes:layout-component>
</stripes:layout-render>