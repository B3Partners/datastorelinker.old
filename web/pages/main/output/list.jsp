<%-- 
    Document   : outputList
    Created on : 6-mei-2010, 14:58:48
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:form partial="true" action="/">
    <c:forEach var="output" items="${actionBean.outputs}" varStatus="status">
        <stripes:radio id="output${status.index}" name="outputId" value="${output.id}"/>
        <stripes:label for="output${status.index}">
            <c:out value="${output.databaseId.name}"/>
        </stripes:label>
    </c:forEach>
</stripes:form>