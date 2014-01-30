<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
</script>


<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.OutputServicesAction">
    <stripes:select name="typePublisher" id="publisherType">
        <stripes:option value="GEOSERVER">Geoserver</stripes:option>
        <stripes:option value="MAPSERVER" disabled="true">Mapserver</stripes:option>
    </stripes:select>
</stripes:form>
