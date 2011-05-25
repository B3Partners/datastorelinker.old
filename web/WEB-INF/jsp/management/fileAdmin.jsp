<%-- 
    Document   : fileAdmin
    Created on : 3-aug-2010, 19:57:51
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        $("#fileHeader").append("<h1><fmt:message key="inputFile.selectFile"/></h1>");
        
        createDefaultVerticalLayout($("#fileAdmin"), $.extend({}, defaultLayoutOptions, {
            south__size: 50,
            south__minSize: 50
        }));

        $("#createUpdateProcessForm").validate(defaultRadioValidateOptions);

    });
</script>

<div id="fileAdmin" style="height: 100%">
    <stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction" method="POST" enctype="multipart/form-data">
        <jsp:include page="/WEB-INF/jsp/main/file/main.jsp">
            <jsp:param name="adminPage" value="true"/>
        </jsp:include>
        <%--@include file="/WEB-INF/jsp/main/file/main.jsp" --%>
    </stripes:form>
</div>