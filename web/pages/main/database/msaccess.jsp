<%-- 
    Document   : msaccess
    Created on : 12-mei-2010, 14:52:28
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<c:set var="dbTypeId" value="2"/>

<script type="text/javascript">
    $(function() {
        if (${not empty actionBean.selectedDatabase and actionBean.selectedDatabase.typeId.id == dbTypeId}) {
            $("#msaccessurl").val("${actionBean.selectedDatabase.url}");
            $("#msaccesssrs").val("${actionBean.selectedDatabase.srs}");
            $("#msaccesscolX").val("${actionBean.selectedDatabase.colX}");
            $("#msaccesscolY").val("${actionBean.selectedDatabase.colY}");
        } else {
            $("#msaccessurl").val("*.mdb");
            $("#msaccesssrs").val("EPSG:28992");
            $("#msaccesscolX").val("POINT_X");
            $("#msaccesscolY").val("POINT_Y");
        }
    });
</script>

<stripes:form id="msaccessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="${dbTypeId}" />
    <stripes:wizard-fields/>
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="url" for="msaccessurl"/></td>
                <td><stripes:text id="msaccessurl" name="url"/></td>
            </tr>
            <tr>
                <td><stripes:label name="srs" for="msaccesssrs"/></td>
                <td><stripes:text id="msaccesssrs" name="srs"/></td>
            </tr>
            <tr>
                <td><stripes:label name="colX" for="msaccesscolX"/></td>
                <td><stripes:text id="msaccesscolX" name="colX"/></td>
            </tr>
            <tr>
                <td><stripes:label name="colY" for="msaccesscolY"/></td>
                <td><stripes:text id="msaccesscolY" name="colY"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>
