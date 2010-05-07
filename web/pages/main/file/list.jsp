<%-- 
    Document   : list
    Created on : 7-mei-2010, 20:36:03
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:form partial="true" action="/">
    <c:forEach var="file" items="${actionBean.files}" varStatus="status">
        <c:choose>
            <c:when test="${not empty actionBean.selectedFile and file.id == actionBean.selectedFile.id}">
                <input type="radio" id="file{status.index}" name="fileId" value="${file.id}" checked="checked" />
            </c:when>
            <c:otherwise>
                <input type="radio" id="file{status.index}" name="fileId" value="${file.id}" />
            </c:otherwise>
        </c:choose>
        <stripes:label for="file${status.index}">
            <c:out value="${file.name}"/>
        </stripes:label>
    </c:forEach>
</stripes:form>