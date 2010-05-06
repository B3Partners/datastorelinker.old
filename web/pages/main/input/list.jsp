<%-- 
    Document   : inoutList
    Created on : 4-mei-2010, 17:12:22
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:form partial="true" action="/">
    <c:forEach var="input" items="${actionBean.inputs}" varStatus="status">
        <stripes:radio id="input${status.index}" name="inputId" value="${input.id}"/>
        <stripes:label for="input${status.index}">
            <c:choose>
                <c:when test="${input.datatypeId.id == 1}">
                    <c:out value="${input.databaseId.name}"/>
                </c:when>
                <c:when test="${input.datatypeId.id == 2}">
                    <c:out value="${input.fileId.name}"/>
                </c:when>
            </c:choose>
            <c:if test="${input.tableName != ''}">
                (<c:out value="${input.tableName}"/>)
            </c:if>
        </stripes:label>
    </c:forEach>
</stripes:form>