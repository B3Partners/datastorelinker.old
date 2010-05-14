<%-- 
    Document   : msaccess
    Created on : 12-mei-2010, 14:52:28
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        if (${not empty actionBean.selectedDatabase}) {
            $("#msaccessurl")[0].value = "${actionBean.selectedDatabase.url}";
            $("#msaccesssrs")[0].value = "${actionBean.selectedDatabase.srs}";
            $("#msaccesscolX")[0].value = "${actionBean.selectedDatabase.colX}";
            $("#msaccesscolY")[0].value = "${actionBean.selectedDatabase.colY}";
        } else {
            $("#msaccessurl")[0].value = "*.mdb";
            $("#msaccesssrs")[0].value = "EPSG:28992";
            $("#msaccesscolX")[0].value = "POINT_X";
            $("#msaccesscolY")[0].value = "POINT_Y";
        }
    });
</script>

<stripes:form id="msaccessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
    <stripes:hidden name="dbType" value="2" />
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
