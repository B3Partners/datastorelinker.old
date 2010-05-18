<%-- 
    Document   : inoutList
    Created on : 4-mei-2010, 17:12:22
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#inputList").buttonset();
    });
</script>

<div id="inputList" class="radioList">
    <stripes:form partial="true" action="/">
        <c:forEach var="input" items="${actionBean.inputs}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedInputId and input.id == actionBean.selectedInputId}">
                    <input type="radio" id="input${status.index}" name="selectedInputId" value="${input.id}" checked="checked"/>
                </c:when>
                <c:otherwise>
                    <input type="radio" id="input${status.index}" name="selectedInputId" value="${input.id}"/>
                </c:otherwise>
            </c:choose>
            <stripes:label for="input${status.index}">
                <c:out value="${input.name}"/>
            </stripes:label>
        </c:forEach>
    </stripes:form>
</div>