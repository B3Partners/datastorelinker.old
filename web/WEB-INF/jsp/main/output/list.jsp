<%-- 
    Document   : outputList
    Created on : 6-mei-2010, 14:58:48
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript">
    $(document).ready(function() {
        initGuiOutput();
    });
</script>

<div id="outputList">
    <stripes:form partial="true" action="/">
        <c:forEach var="output" items="${actionBean.outputs}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedOutputId and output.id == actionBean.selectedOutputId}">
                    <input type="radio" id="output${status.index}" name="selectedOutputId" value="${output.id}" class="required" checked="checked"/>
                    <script type="text/javascript">
                        $(document).ready(function() {
                            $("#outputList").parent().scrollTo(
                                $("#output${status.index}"),
                                defaultScrollToDuration,
                                defaultScrollToOptions
                            );
                        });
                    </script>
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