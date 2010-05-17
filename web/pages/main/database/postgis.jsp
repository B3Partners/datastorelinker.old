<%-- 
    Document   : postgis
    Created on : 12-mei-2010, 14:52:05
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<c:set var="dbTypeId" value="3"/>

<script type="text/javascript">
    $(function() {
        if (${not empty actionBean.selectedDatabase and actionBean.selectedDatabase.typeId.id == dbTypeId}) {
            $("#postgishost")[0].value = "${actionBean.selectedDatabase.host}";
            $("#postgisdatabaseName")[0].value = "${actionBean.selectedDatabase.databaseName}";
            $("#postgisusername")[0].value = "${actionBean.selectedDatabase.username}";
            $("#postgispassword")[0].value = "${actionBean.selectedDatabase.password}";
            $("#postgisport")[0].value = "${actionBean.selectedDatabase.port}";
            $("#postgisschema")[0].value = "${actionBean.selectedDatabase.schema}";
        } else {
            $("#postgishost")[0].value = "";
            $("#postgisdatabaseName")[0].value = "";
            $("#postgisusername")[0].value = "";
            $("#postgispassword")[0].value = "";
            $("#postgisport")[0].value = "5432";
            $("#postgisschema")[0].value = "public";
        }
    });
</script>

<stripes:form id="postgisForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="${dbTypeId}" />
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="host" for="postgishost"/></td>
                <td><stripes:text id="postgishost" name="host"/></td>
            </tr>
            <tr>
                <td><stripes:label name="databaseName" for="postgisdatabaseName"/></td>
                <td><stripes:text id="postgisdatabaseName" name="databaseName"/></td>
            </tr>
            <tr>
                <td><stripes:label name="username" for="postgisusername"/></td>
                <td><stripes:text id="postgisusername" name="username"/></td>
            </tr>
            <tr>
                <td><stripes:label name="password" for="postgispassword"/></td>
                <td><stripes:password id="postgispassword" name="password"/></td>
            </tr>
            <tr>
                <td><stripes:label name="port" for="postgisport"/></td>
                <td><stripes:text id="postgisport" name="port"/></td>
            </tr>
            <tr>
                <td><stripes:label name="schema" for="postgisschema"/></td>
                <td><stripes:text id="postgisschema" name="schema"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>
