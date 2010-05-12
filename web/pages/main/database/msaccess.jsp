<%-- 
    Document   : msaccess
    Created on : 12-mei-2010, 14:52:28
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:form id="msaccessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="2" />
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
                <td><stripes:text id="msaccesscolX" name="colX" value="POINT_X"/></td>
            </tr>
            <tr>
                <td><stripes:label name="colY" for="msaccesscolY"/></td>
                <td><stripes:text id="msaccesscolY" name="colY" value="POINT_Y"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>
