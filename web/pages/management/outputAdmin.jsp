<%-- 
    Document   : outputAdmin
    Created on : 3-aug-2010, 19:57:39
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>
<%@include file="/pages/commons/urls.jsp" %>

<script type="text/javascript">
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
        <%@include file="/pages/main/output/main.jsp" %>
    </stripes:form>
</div>