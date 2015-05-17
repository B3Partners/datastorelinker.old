<%-- 
    Document   : postgis
    Created on : 12-mei-2010, 14:52:05
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<c:set var="dbType" value="POSTGIS"/>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        <c:choose>
            <c:when test="${not empty actionBean.selectedDatabase and actionBean.selectedDatabase.type == dbType}">
                $("#postgishost").val("<c:out value="${actionBean.selectedDatabase.host}"/>");
                $("#postgisdatabaseName").val("<c:out value="${actionBean.selectedDatabase.databaseName}"/>");
                $("#postgisusername").val("<c:out value="${actionBean.selectedDatabase.username}"/>");
                $("#postgispassword").val("<c:out value="${actionBean.selectedDatabase.password}"/>");
                $("#postgisport").val("<c:out value="${actionBean.selectedDatabase.port}"/>");
                $("#postgisschema").val("<c:out value="${actionBean.selectedDatabase.schema}"/>");
            </c:when>
            <c:otherwise>
                $("#postgishost").val("");
                $("#postgisdatabaseName").val("");
                $("#postgisusername").val("");
                $("#postgispassword").val("");
                $("#postgisport").val("5432");
                $("#postgisschema").val("public");
            </c:otherwise>
        </c:choose>

        $("#postgisForm").validate(defaultValidateOptions);
    });
</script>

<stripes:form id="postgisForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="${dbType}" />
    <c:if test="${not empty actionBean.selectedDatabase}">
        <stripes:hidden name="selectedDatabaseId" value="${actionBean.selectedDatabase.id}"/>
    </c:if>
    <stripes:wizard-fields/>
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="host" for="postgishost"/></td>
                <td><stripes:text id="postgishost" name="host" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="databaseName" for="postgisdatabaseName"/></td>
                <td><stripes:text id="postgisdatabaseName" name="databaseName" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="username" for="postgisusername"/></td>
                <td><stripes:text id="postgisusername" name="username" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="password" for="postgispassword"/></td>
                <td><stripes:password id="postgispassword" name="password" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="port" for="postgisport"/></td>
                <td><stripes:text id="postgisport" name="port" class="required number"/></td>
            </tr>
            <tr>
                <td><stripes:label name="schema" for="postgisschema"/></td>
                <td><stripes:text id="postgisschema" name="schema" class="required"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>
