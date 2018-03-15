<%-- 
    Document   : wfs
    Created on : Feb 19, 2018, 12:51:28 PM
    Author     : martijn
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<c:set var="dbType" value="WFS"/>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        <c:choose>
            <c:when test="${not empty actionBean.selectedDatabase and actionBean.selectedDatabase.type == dbType}">
                $("#wfsurl").val("<c:out value="${actionBean.selectedDatabase.url}"/>");
                $("#wfsusername").val("<c:out value="${actionBean.selectedDatabase.username}"/>");
                $("#wfspassword").val("<c:out value="${actionBean.selectedDatabase.password}"/>");
                $("#wfstimeout").val("<c:out value="${actionBean.selectedDatabase.timeout}"/>");
                $("#wfsbuffersize").val("<c:out value="${actionBean.selectedDatabase.buffersize}"/>");
            </c:when>
            <c:otherwise>
                $("#wfsurl").val("");
                $("#wfsusername").val("");
                $("#wfspassword").val("");
                $("#wfstimeout").val("3000");
                $("#wfsbuffersize").val("10");
            </c:otherwise>
        </c:choose>

        $("#wfsForm").validate(defaultValidateOptions);
    });
</script>

<stripes:form id="wfsForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="${dbType}" />
    <c:if test="${not empty actionBean.selectedDatabase}">
        <stripes:hidden name="selectedDatabaseId" value="${actionBean.selectedDatabase.id}"/>
    </c:if>
    <stripes:wizard-fields/>
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="url" for="wfsurl"/></td>
                <td><stripes:text id="wfsurl" name="url" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="username" for="wfsusername"/></td>
                <td><stripes:text id="wfsusername" name="username" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="password" for="wfspassword"/></td>
                <td><stripes:password id="wfspassword" name="password" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="timeout" for="wfstimeout"/></td>
                <td><stripes:text id="wfstimeout" name="timeout" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="buffersize" for="wfsbuffersize"/></td>
                <td><stripes:text id="wfsbuffersize" name="buffersize" class="required"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>

