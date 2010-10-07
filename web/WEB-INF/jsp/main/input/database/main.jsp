<%-- 
    Document   : main
    Created on : 7-okt-2010, 20:00:35
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<stripes:form partial="true" action="#">
    <div id="databaseInputHeader" class="ui-layout-north">
    </div>
    <div id="inputListContainer" class="ui-layout-center radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/input/database/list.jsp" %>
    </div>
    <div class="ui-layout-south crudButtonsArea">
        <stripes:button id="createInputDB" name="create"/>
        <stripes:button id="updateInput" name="update"/>
        <stripes:button id="deleteInput" name="delete"/>
    </div>
</stripes:form>