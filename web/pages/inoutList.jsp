<%-- 
    Document   : inoutList
    Created on : 4-mei-2010, 17:12:22
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<c:forEach var="database" items="${actionBean.databases}" varStatus="status">
    <stripes:radio id="database${status.index}" name="databaseId" value="${database.id}"/>
    <stripes:label for="database${status.index}">
        <c:out value="${database.name}"/>
    </stripes:label>
</c:forEach>