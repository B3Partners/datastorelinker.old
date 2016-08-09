<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.OutputServicesAction">
    <stripes:hidden name="selectedDatabaseId" id="selectedDatabaseId"/>
    <stripes:hidden name="selectedTables" id="selectedTables"/>
    <table>
        <tbody>
            <tr>
                <td><stripes:label name="publish.table.type" for="typePublisher"/></td>
                <td><stripes:select name="typePublisher" id="publisherType">
                        <stripes:option value="GEOSERVER">Geoserver</stripes:option>    
                        <stripes:option value="MAPSERVER">Mapserver</stripes:option>                    
                    </stripes:select></td>
            </tr>
        </tbody>
    </table>
    <div id="tablesList">
        <td><div id="msgTables" class="verplichteInvoer"/></td>
        <c:forEach var="table" items="${actionBean.tables}" varStatus="status">
            <input type="checkbox" id="table${status.index}" name="selectedTable" value="${table}" class="required"/>
            <stripes:label for="table${status.index}">
                <c:out value="${table}"/>
            </stripes:label>
            <br/>
        </c:forEach>
</div>
</stripes:form>
