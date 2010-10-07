<%-- 
    Document   : fileAdmin
    Created on : 3-aug-2010, 19:57:51
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        $("#fileHeader").append("<h1><fmt:message key="inputFile.selectFile"/></h1>");
        
        createDefaultVerticalLayout($("#fileAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));

        $("#createInputForm").validate(defaultRadioValidateOptions);
    });
</script>

<div id="fileAdmin" style="height: 100%">
    <stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
        <%@include file="/WEB-INF/jsp/main/file/main.jsp" %>
    </stripes:form>
</div>