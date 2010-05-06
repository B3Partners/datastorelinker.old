<%-- 
    Document   : databaseInList
    Created on : 6-mei-2010, 14:30:21
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:form partial="true" action="/">
    <c:forEach var="database" items="${actionBean.databases}" varStatus="status">
        <stripes:radio id="database${status.index}" name="databaseId" value="${database.id}"/>
        <stripes:label for="database${status.index}">
            <c:out value="${database.name}"/>
        </stripes:label>
    </c:forEach>
</stripes:form>