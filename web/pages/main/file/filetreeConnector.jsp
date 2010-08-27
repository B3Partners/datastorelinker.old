<%-- 
    Document   : filetree
    Created on : 4-aug-2010, 22:08:00
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<c:if test="${empty dirContent}">
    <c:set var="dirContent" value="${actionBean.dirContent}" scope="request"/>
</c:if>

<c:set var="dirs" value="${dirContent.dirs}" scope="page"/>
<c:set var="files" value="${dirContent.files}" scope="page"/>

<ul class="jqueryFileTree" style="display: block;">
    <c:forEach var="dir" items="${dirs}">
        <c:choose>
            <c:when test="${not empty dir.dirContent}">
                <li class="directory expanded">
                    <input type="checkbox" name="${dir.id}" value="${dir.id}"/>
                    <input type="radio" name="selectedFileId" value="${dir.id}" style="display: none"/>
                    <a href="#" rel="${dir.id}" style="display: inline">${dir.name}</a>

                    <c:set var="dirContent" value="${dir.dirContent}" scope="request"/>
                    <jsp:include page="filetreeConnector.jsp"/>
                    
                </li>
            </c:when>
            <c:otherwise>
                <li class="directory collapsed">
                    <input type="checkbox" name="${dir.id}" value="${dir.id}"/>
                    <input type="radio" name="selectedFileId" value="${dir.id}" style="display: none"/>
                    <a href="#" rel="${dir.id}" style="display: inline">${dir.name}</a>
                </li>
            </c:otherwise>
        </c:choose>
    </c:forEach>
    <c:forEach var="file" items="${files}">
        <li class="file ext_file">
            <input type="checkbox" name="${file.id}" value="${file.id}"/>
            <input type="radio" name="selectedFileId" value="${file.id}" style="display: none"/>
            <a href="#" rel="${file.id}" style="display: inline">${file.name}</a>
        </li>
    </c:forEach>
</ul>
