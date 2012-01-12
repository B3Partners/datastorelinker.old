<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        selectFirstRadioInputIfPresentAndNoneSelected($("#tablesList input:radio"));
        $("#tablesList").buttonset();
    });
</script>

<div id="tablesList">
    <stripes:form partial="true" action="/">
        <c:forEach var="table" items="${actionBean.tables}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedTable and table == actionBean.selectedTable}">
                    <input type="radio" id="table${status.index}" name="selectedTable" value="${table}" class="required" checked="checked" />
                    <script type="text/javascript" class="ui-layout-ignore">
                        $(document).ready(function() {
                            $("#tablesList").parent().scrollTo(
                                $("#table${status.index}"),
                                defaultScrollToDuration,
                                defaultScrollToOptions
                            );
                        });
                    </script>
                </c:when>
                <c:otherwise>
                    <input type="radio" id="table${status.index}" name="selectedTable" value="${table}" class="required"/>
                </c:otherwise>
            </c:choose>
            <stripes:label for="table${status.index}">
                <c:out value="${table}"/>
            </stripes:label>
        </c:forEach>
    </stripes:form>
</div>