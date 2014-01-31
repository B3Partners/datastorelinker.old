<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        $("#databaseAccordion").accordion();
        
    });
</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.OutputServicesAction">
    <stripes:hidden name="selectedDatabaseId" id="selectedDatabaseId"/>
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="publish.table.type" for="typePublisher"/></td>
                <td><stripes:select name="typePublisher" id="publisherType">
                        <stripes:option value="GEOSERVER">Geoserver</stripes:option>
                        <stripes:option value="MAPSERVER" disabled="true">Mapserver</stripes:option>
                    </stripes:select></td>
            </tr>
            <tr>
                <td><stripes:label name="publish.table.url" for="url"/></td>
                <td><stripes:text name="url" id="url" value="http://localhost:8084/geoserver"/></td>
            </tr>
            <tr>
                <td><stripes:label name="publish.table.style" for="style"/></td>
                <td><stripes:text name="style" id="style" value="polygon"/></td>
            </tr>
            <tr>
                <td><stripes:label name="publish.table.serviceUser" for="serviceUser"/></td>
                <td><stripes:text name="serviceUser" id="serviceUser" value="admin"/></td>
            </tr>
            <tr>
                <td><stripes:label name="publish.table.servicePassword" for="servicePassword"/></td>
                <td><stripes:password name="servicePassword" id="servicePassword" value="***REMOVED***"/></td>
            </tr>
        </tbody>
    </table>
</stripes:form>

