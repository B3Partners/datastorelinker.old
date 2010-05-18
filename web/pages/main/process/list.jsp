<%-- 
    Document   : list
    Created on : 12-mei-2010, 13:24:18
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#processesList").buttonset();
    });
</script>

<div id="processesList" class="radioList">
    <stripes:form partial="true" action="/">
        <c:forEach var="process" items="${actionBean.processes}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedProcessId and process.id == actionBean.selectedProcessId}">
                    <input type="radio" id="process${status.index}" name="selectedProcessId" value="${process.id}" checked="checked"/>
                </c:when>
                <c:otherwise>
                    <input type="radio" id="process${status.index}" name="selectedProcessId" value="${process.id}"/>
                </c:otherwise>
            </c:choose>
            <stripes:label for="process${status.index}"><c:out value="${process.name}"/></stripes:label>
        </c:forEach>
    </stripes:form>
</div>