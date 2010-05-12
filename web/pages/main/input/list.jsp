<%-- 
    Document   : inoutList
    Created on : 4-mei-2010, 17:12:22
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:form partial="true" action="/">
    <c:forEach var="input" items="${actionBean.inputs}" varStatus="status">
        <c:choose>
            <c:when test="${not empty actionBean.selectedInputId and file.id == actionBean.selectedInputId}">
                <input type="radio" id="input${status.index}" name="selectedInputId" value="${input.id}" checked="checked"/>
            </c:when>
            <c:otherwise>
                <input type="radio" id="input${status.index}" name="selectedInputId" value="${input.id}"/>
            </c:otherwise>
        </c:choose>
        <stripes:label for="input${status.index}">
            <!-- TODO: alleen opgeslagen naam (+ tabelname) gebruiken -->
            <c:choose>
                <c:when test="${input.datatypeId.id == 1}">
                    <c:out value="${input.name}"/>
                </c:when>
                <c:when test="${input.datatypeId.id == 2}">
                    <c:out value="${input.name}"/>
                </c:when>
            </c:choose>
            <c:if test="${not empty input.tableName}">
                (<c:out value="${input.tableName}"/>)
            </c:if>
        </stripes:label>
    </c:forEach>
</stripes:form>