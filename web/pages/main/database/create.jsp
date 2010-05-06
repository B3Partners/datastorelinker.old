<%-- 
    Document   : newDatabase
    Created on : 3-mei-2010, 18:08:19
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#databaseInputAccordion").accordion();
    });
</script>

<div id="databaseInputAccordion" style="margin-bottom: 10px">
    <h3><a href="#">PostGIS</a></h3>
    <div>
        <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
            <stripes:hidden name="dbType" value="postgis" />
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
                        <td><stripes:password id="postgisusername" name="username"/></td>
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
    </div>
    <h3><a href="#">Oracle</a></h3>
    <div>
        <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
            <stripes:hidden name="dbType" value="oracle" />
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
                        <td><stripes:password id="oracleusername" name="username"/></td>
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
    </div>
    <h3><a href="#">MS Access</a></h3>
    <div>
        <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
            <stripes:hidden name="dbType" value="msaccess" />
            <table>
                <tbody>
                    <tr>
                        <td><stripes:label name="url" for="msaccessurl"/></td>
                        <td><stripes:text id="msaccessurl" name="url" value="*.mdb"/></td>
                    </tr>
                    <tr>
                        <td><stripes:label name="srs" for="msaccesssrs"/></td>
                        <td><stripes:text id="msaccesssrs" name="srs" value="EPSG:28992"/></td>
                    </tr>
                    <tr>
                        <td><stripes:label name="colX" for="msaccesscolX"/></td>
                        <td><stripes:password id="msaccesscolX" name="colX" value="POINT_X"/></td>
                    </tr>
                    <tr>
                        <td><stripes:label name="colY" for="msaccesscolY"/></td>
                        <td><stripes:password id="msaccesscolY" name="colY" value="POINT_Y"/></td>
                    </tr>
                </tbody>
            </table>
        </stripes:form>
    </div>
    <%--h3><a href="#">Geavanceerd</a></h3>
    <div>
        <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
            <stripes:hidden name="dbType" value="freestyle" />
        </stripes:form>
    </div--%>
</div>