<%-- 
    Document   : outputAdmin
    Created on : 3-aug-2010, 19:57:39
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initOutput();

        createDefaultVerticalLayout($("#outputAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));

        $("#createUpdateProcessForm").validate(defaultRadioValidateOptions);
    });
</script>

<div id="outputAdmin" style="height: 100%">
    <stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
        <%@include file="/WEB-INF/jsp/main/output/main.jsp" %>
    </stripes:form>
</div>