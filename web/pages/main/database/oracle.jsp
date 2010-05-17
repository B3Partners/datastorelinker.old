<%-- 
    Document   : oracle
    Created on : 12-mei-2010, 14:52:20
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<c:set var="dbTypeId" value="1"/>

<script type="text/javascript">
    $(function() {
        if (${not empty actionBean.selectedDatabase and actionBean.selectedDatabase.typeId.id == dbTypeId}) {
            $("#oraclehost").val("${actionBean.selectedDatabase.host}");
            $("#oracledatabaseName").val("${actionBean.selectedDatabase.databaseName}");
            $("#oracleusername").val("${actionBean.selectedDatabase.username}");
            $("#oraclepassword").val("${actionBean.selectedDatabase.password}");
            $("#oracleport").val("${actionBean.selectedDatabase.port}");
            $("#oracleschema").val("${actionBean.selectedDatabase.schema}");
            $("#oracleinstance").val("${actionBean.selectedDatabase.instance}");
            $("#oraclealias").val("${actionBean.selectedDatabase.alias}");
        } else {
            $("#oraclehost").val("");
            $("#oracledatabaseName").val("");
            $("#oracleusername").val("");
            $("#oraclepassword").val("");
            $("#oracleport").val("1521");
            $("#oracleschema").val("ORCL");
            $("#oracleinstance").val("ORCL");
            $("#oraclealias").val("");
        }
    });
</script>

<stripes:form id="oracleForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="${dbTypeId}" />
    <stripes:wizard-fields/>
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="host" for="oraclehost"/></td>
                <td><stripes:text id="oraclehost" name="host"/></td>
            </tr>
            <tr>
                <td><stripes:label name="databaseName" for="oracledatabaseName"/></td>
                <td><stripes:text id="oracledatabaseName" name="databaseName"/></td>
            </tr>
            <tr>
                <td><stripes:label name="username" for="oracleusername"/></td>
                <td><stripes:text id="oracleusername" name="username"/></td>
            </tr>
            <tr>
                <td><stripes:label name="password" for="oraclepassword"/></td>
                <td><stripes:password id="oraclepassword" name="password"/></td>
            </tr>
            <tr>
                <td><stripes:label name="port" for="oracleport"/></td>
                <td><stripes:text id="oracleport" name="port"/></td>
            </tr>
            <tr>
                <td><stripes:label name="schema" for="oracleschema"/></td>
                <td><stripes:text id="oracleschema" name="schema"/></td>
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
