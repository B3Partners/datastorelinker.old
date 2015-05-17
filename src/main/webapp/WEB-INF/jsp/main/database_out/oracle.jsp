<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<c:set var="dbType" value="ORACLE"/>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        <c:choose>
            <c:when test="${not empty actionBean.selectedDatabase and actionBean.selectedDatabase.type == dbType}">
                $("#oraclehost").val("<c:out value="${actionBean.selectedDatabase.host}"/>");
                $("#oracleusername").val("<c:out value="${actionBean.selectedDatabase.username}"/>");
                $("#oraclepassword").val("<c:out value="${actionBean.selectedDatabase.password}"/>");
                $("#oracleport").val("<c:out value="${actionBean.selectedDatabase.port}"/>");
                $("#oracledatabaseName").val("<c:out value="${actionBean.selectedDatabase.databaseName}"/>");
                $("#oracleschema").val("<c:out value="${actionBean.selectedDatabase.schema}"/>");
                $("#oraclealias").val("<c:out value="${actionBean.selectedDatabase.alias}"/>");
            </c:when>
            <c:otherwise>
                $("#oraclehost").val("");
                $("#oracleusername").val("");
                $("#oraclepassword").val("");
                $("#oracleport").val("1521");
                $("#oracledatabaseName").val("ORCL");
                $("#oracleschema").val("");
                $("#oraclealias").val("");
            </c:otherwise>
        </c:choose>

        $("#oracleForm").validate(defaultValidateOptions);
    });
</script>

<stripes:form id="oracleForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseOutputAction">
    <stripes:hidden name="dbType" value="${dbType}" />
    <stripes:wizard-fields/>
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="host" for="oraclehost"/></td>
                <td><stripes:text id="oraclehost" name="host" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="schema" for="oracleschema"/></td>
                <td><stripes:text id="oracleschema" name="schema" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="username" for="oracleusername"/></td>
                <td><stripes:text id="oracleusername" name="username" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="password" for="oraclepassword"/></td>
                <td><stripes:password id="oraclepassword" name="password" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="port" for="oracleport"/></td>
                <td><stripes:text id="oracleport" name="port" class="number required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="databaseNameOracle" for="oracledatabaseName"/></td>
                <td><stripes:text id="oracledatabaseName" name="databaseName" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="alias" for="oraclealias"/></td>
                <td><stripes:text id="oraclealias" name="alias"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>
