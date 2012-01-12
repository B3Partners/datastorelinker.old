<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initDatabaseOutput();

        createDefaultVerticalLayout($("#databaseAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));

        $("#createInputForm").validate(defaultRadioValidateOptions);
    });
</script>

<div id="databaseAdmin" style="height: 100%">
    <stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.OutputActionNew">
        <%@include file="/WEB-INF/jsp/main/database_out/main.jsp" %>
    </stripes:form>
</div>