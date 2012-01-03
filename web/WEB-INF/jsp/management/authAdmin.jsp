<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initOrgs();

        createDefaultVerticalLayout($("#authAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));

        $("#createUpdateOrganizationForm").validate(defaultRadioValidateOptions);
    });
</script>

<div id="authAdmin" style="height: 100%">
    <stripes:form id="createUpdateOrganizationForm" beanclass="nl.b3p.datastorelinker.gui.stripes.AuthorizationAction">
        <%@include file="/WEB-INF/jsp/main/auth/orgs/main.jsp" %>
    </stripes:form>
</div>