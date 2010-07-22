<%-- 
    Document   : list
    Created on : 12-mei-2010, 13:24:18
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        $("#processesList").buttonset();
    });
</script>

<div id="processesList">
    <stripes:form partial="true" action="/">
        <c:forEach var="process" items="${actionBean.processes}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedProcessId and process.id == actionBean.selectedProcessId}">
                    <input type="radio" id="process${process.id}" name="selectedProcessId" value="${process.id}" class="required" checked="checked"/>
                    <script type="text/javascript">
                        $(document).ready(function() {
                            $("#processesList").parent().scrollTo(
                                $("#process${process.id}"),
                                defaultScrollToDuration,
                                defaultScrollToOptions
                            );
                        });
                    </script>
                </c:when>
                <c:otherwise>
                    <input type="radio" id="process${process.id}" name="selectedProcessId" value="${process.id}" class="required"/>
                </c:otherwise>
            </c:choose>
            <stripes:label for="process${process.id}"><c:out value="${process.name}"/></stripes:label>
            <%-- Add schedule icon if this process is scheduled --%>
            <c:if test="${not empty process.schedule}">
                <script type="text/javascript">
                    $(document).ready(function() {
                        $("#process${process.id}").button("option", "icons", {primary: "ui-icon-clock"});
                    });
                </script>
            </c:if>
        </c:forEach>
    </stripes:form>
</div>