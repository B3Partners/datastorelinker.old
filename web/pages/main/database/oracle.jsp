<%-- 
    Document   : oracle
    Created on : 12-mei-2010, 14:52:20
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:form id="oracleForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="1" />
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
                <td><stripes:text id="oracleport" name="port" value="1521"/></td>
            </tr>
            <tr>
                <td><stripes:label name="schema" for="oracleschema"/></td>
                <td><stripes:text id="oracleschema" name="schema" value="ORCL"/></td>
            </tr>
            <tr>
                <td><stripes:label name="instance" for="oracleinstance"/></td>
                <td><stripes:text id="oracleinstance" name="instance" value="ORCL"/></td>
            </tr>
            <tr>
                <td><stripes:label name="alias" for="oraclealias"/></td>
                <td><stripes:text id="oraclealias" name="alias"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>
