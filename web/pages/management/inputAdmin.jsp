<%-- 
    Document   : management.jsp
    Created on : 23-apr-2010, 15:38:46
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>
<%@include file="/pages/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        initInput();

        createDefaultVerticalLayout($("#inputAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));
        
        $("#createUpdateProcessForm").validate(defaultRadioValidateOptions);
    });
</script>

<div id="inputAdmin" style="height: 100%">
    <stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
        <%@include file="/pages/main/input/main.jsp" %>
    </stripes:form>
</div>
