<%-- 
    Document   : databaseAdmin
    Created on : 3-aug-2010, 19:58:02
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initDatabase();

        createDefaultVerticalLayout($("#databaseAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));

        $("#createInputForm").validate(defaultRadioValidateOptions);
    });
</script>

<div id="databaseAdmin" style="height: 100%">
    <stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
        <%@include file="/WEB-INF/jsp/main/database/main.jsp" %>
    </stripes:form>
</div>