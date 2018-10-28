<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        selectFirstRadioInputIfPresentAndNoneSelected($("#databasesList input:radio"));
        $("#databasesList").buttonset();
    });
</script>

<c:choose>
    <c:when test="${not empty actionBean.context.validationErrors}">
        <script>
            var msg = "";
            <stripes:errors>
                msg += "<stripes:individual-error/> <br/>";
            </stripes:errors>
            openSimpleErrorDialog(msg);
        </script>
    </c:when>
    <c:when test="${not empty actionBean.context.messages}">

        <script>
            var msg = {
                title: "${actionBean.context.messages[0].getMessage()}",
                message: "<fmt:message key="keys.layerpublished"/>"
            };
            openJSONErrorDialog(msg);
        </script>
    </c:when>
</c:choose>

<div id="databasesList">
    <stripes:form partial="true" action="/">
        <c:forEach var="database" items="${actionBean.databases}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedDatabaseId and database.id == actionBean.selectedDatabaseId}">
                    <input type="radio" id="database${status.index}" name="selectedDatabaseId" value="${database.id}" class="required" checked="checked" />
                    <script type="text/javascript" class="ui-layout-ignore">
                        $(document).ready(function() {
                            $("#databasesList").parent().scrollTo(
                                $("#database${status.index}"),
                                defaultScrollToDuration,
                                defaultScrollToOptions
                            );
                        });
                    </script>
                </c:when>
                <c:otherwise>
                    <input type="radio" id="database${status.index}" name="selectedDatabaseId" value="${database.id}" class="required"/>
                </c:otherwise>
            </c:choose>
            <stripes:label for="database${status.index}">
                <c:out value="${database.name}"/>
            </stripes:label>
        </c:forEach>
    </stripes:form>
</div>