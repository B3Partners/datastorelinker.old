<%-- 
    Document   : list
    Created on : 10-mei-2010, 18:30:03
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#tablesList").buttonset();
    });
</script>

<div id="tablesList" class="radioList">
    <stripes:form partial="true" action="/">
        <c:forEach var="table" items="${actionBean.tables}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedTable and table == actionBean.selectedTable}">
                    <input type="radio" id="table${status.index}" name="selectedTable" value="${table}" checked="checked" />
                </c:when>
                <c:otherwise>
                    <input type="radio" id="table${status.index}" name="selectedTable" value="${table}" />
                </c:otherwise>
            </c:choose>
            <stripes:label for="table${status.index}">
                <c:out value="${table}"/>
            </stripes:label>
        </c:forEach>
    </stripes:form>
</div>