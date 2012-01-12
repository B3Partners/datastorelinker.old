<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initInput();

        $("#databaseInputHeader").html("<h1><fmt:message key="process.selectDatabaseOutput"/></h1>");

        createDefaultVerticalLayout($("#inputAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));
        
        $("#createUpdateProcessForm").validate(defaultRadioValidateOptions);
    });
</script>

<div id="inputAdmin" style="height: 100%">
    <stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
        <%@include file="/WEB-INF/jsp/main/output_new/database/main.jsp" %>
    </stripes:form>
</div>
