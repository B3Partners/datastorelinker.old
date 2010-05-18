<%-- 
    Document   : list
    Created on : 7-mei-2010, 20:36:03
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#filesList").buttonset();
    });
</script>

<div id="filesList" class="radioList">
    <stripes:form partial="true" action="/">
        <div id="filesListWrapper">
        <c:forEach var="file" items="${actionBean.files}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedFileId and file.id == actionBean.selectedFileId}">
                    <input type="radio" id="file${status.index}" name="selectedFileId" value="${file.id}" checked="checked" />
                </c:when>
                <c:otherwise>
                    <input type="radio" id="file${status.index}" name="selectedFileId" value="${file.id}" />
                </c:otherwise>
            </c:choose>
            <stripes:label for="file${status.index}">
                <c:out value="${file.name}"/>
            </stripes:label>
        </c:forEach>
        </div>
    </stripes:form>
</div>