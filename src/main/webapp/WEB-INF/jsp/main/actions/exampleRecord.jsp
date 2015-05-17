<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<div class="ui-widget-content ui-corner-all" style="height: 50px; max-height: 50px; overflow: scroll">
    <table>
        <tr>
            <c:forEach var="columnName" items="${actionBean.columnNames}">
                <th title="${fn:trim(columnName)}" class="action-table-header">
                    <c:out value="${fn:trim(columnName)}"/>
                </th>
            </c:forEach>
        </tr>
        <tr>
            <c:forEach var="recordValue" items="${actionBean.recordValues}">
                <td title="${fn:trim(recordValue)}" class="action-table-definition">
                    <c:out value="${fn:trim(recordValue)}"/>
                </td>
            </c:forEach>
        </tr>
    </table>
</div>