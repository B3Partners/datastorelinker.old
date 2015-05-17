<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initOutputRights();

        createDefaultVerticalLayout($("#outputRightsAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));
    });
</script>

<div id="outputRightsAdmin" style="height: 100%">
    <stripes:form id="outputRightsForm" beanclass="nl.b3p.datastorelinker.gui.stripes.OutputRightsAction">
        <%@include file="/WEB-INF/jsp/main/output_rights/main.jsp" %>
    </stripes:form>
</div>