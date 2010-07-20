<%-- 
    Document   : outputList
    Created on : 6-mei-2010, 14:58:48
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        $("#outputList").buttonset();
    });
</script>

<div id="outputList">
    <stripes:form partial="true" action="/">
        <c:forEach var="output" items="${actionBean.outputs}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedOutputId and output.id == actionBean.selectedOutputId}">
                    <input type="radio" id="output${status.index}" name="selectedOutputId" value="${output.id}" class="required" checked="checked"/>
                </c:when>
                <c:otherwise>
                    <input type="radio" id="output${status.index}" name="selectedOutputId" value="${output.id}" class="required"/>
                </c:otherwise>
            </c:choose>
            <stripes:label for="output${status.index}">
                <c:out value="${output.name}"/>
            </stripes:label>
        </c:forEach>
    </stripes:form>
</div>