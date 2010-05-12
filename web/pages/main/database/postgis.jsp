<%-- 
    Document   : postgis
    Created on : 12-mei-2010, 14:52:05
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:form id="postgisForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="3" />
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
                <td><stripes:text id="postgisport" name="port" value="5432"/></td>
            </tr>
            <tr>
                <td><stripes:label name="schema" for="postgisschema"/></td>
                <td><stripes:text id="postgisschema" name="schema" value="public"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>
