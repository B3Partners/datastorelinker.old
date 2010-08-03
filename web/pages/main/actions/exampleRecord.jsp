<%-- 
    Document   : exampleRecord
    Created on : 2-aug-2010, 19:32:49
    Author     : Erik van de Pol
--%>

<%@include file="/pages/commons/taglibs.jsp" %>

<table>
    <tr>
        <c:forEach var="columnName" items="${actionBean.columnNames}">
            <th><c:out value="${columnName}"/></th>
        </c:forEach>
    </tr>
    <tr>
        <c:forEach var="recordValue" items="${actionBean.recordValues}">
            <td><c:out value="${recordValue}"/></td>
        </c:forEach>
    </tr>
</table>