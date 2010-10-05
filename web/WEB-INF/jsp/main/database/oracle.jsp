<%-- 
    Document   : oracle
    Created on : 12-mei-2010, 14:52:20
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<c:set var="dbType" value="ORACLE"/>

<script type="text/javascript">
    $(document).ready(function() {
        <c:choose>
            <c:when test="${not empty actionBean.selectedDatabase and actionBean.selectedDatabase.type == dbType}">
                $("#oraclehost").val("<c:out value="${actionBean.selectedDatabase.host}"/>");
                $("#oracleschema").val("<c:out value="${actionBean.selectedDatabase.schema}"/>");
                $("#oracleusername").val("<c:out value="${actionBean.selectedDatabase.username}"/>");
                $("#oraclepassword").val("<c:out value="${actionBean.selectedDatabase.password}"/>");
                $("#oracleport").val("<c:out value="${actionBean.selectedDatabase.port}"/>");
                $("#oracledatabaseName").val("<c:out value="${actionBean.selectedDatabase.databaseName}"/>");
                $("#oracleinstance").val("<c:out value="${actionBean.selectedDatabase.instance}"/>");
                $("#oraclealias").val("<c:out value="${actionBean.selectedDatabase.alias}"/>");
            </c:when>
            <c:otherwise>
                $("#oraclehost").val("");
                $("#oracleschema").val("");
                $("#oracleusername").val("");
                $("#oraclepassword").val("");
                $("#oracleport").val("1521");
                $("#oracledatabaseName").val("ORCL");
                $("#oracleinstance").val("ORCL");
                $("#oraclealias").val("");
            </c:otherwise>
        </c:choose>

        $("#oracleForm").validate(defaultValidateOptions);
    });
</script>

<stripes:form id="oracleForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="${dbType}" />
    <stripes:wizard-fields/>
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="host" for="oraclehost"/></td>
                <td><stripes:text id="oraclehost" name="host"/></td>
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
                <td><stripes:text id="oracleport" name="port" class="number"/></td>
            </tr>
            <tr>
                <td><stripes:label name="databaseName" for="oracledatabaseName"/></td>
                <td><stripes:text id="oracledatabaseName" name="databaseName" class="required"/></td>
            </tr>
            <tr>
                <td><stripes:label name="instance" for="oracleinstance"/></td>
                <td><stripes:text id="oracleinstance" name="instance"/></td>
            </tr>
            <tr>
                <td><stripes:label name="alias" for="oraclealias"/></td>
                <td><stripes:text id="oraclealias" name="alias"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>