<%-- 
    Document   : list
    Created on : 12-mei-2010, 13:24:18
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    
    
    // images for the different statuses
    var status_options = 
            {'RUNNING': "images/spinner.gif", 
            'LAST_RUN_OK': "images/circle_green.png" , 
            'LAST_RUN_OK_WITH_ERRORS': "images/circle_groengeel.png", 
            'LAST_RUN_FATAL_ERROR': "images/circle_red.png", 
            'CANCELED_BY_USER': "images/circle_blue.png"};

    // current url path
    var current_path = location.pathname;

    
    // query the server on the status of all processes visible to this user
    function updateAllStatuses2() {
            $.ajax({
                    url: "Process.action",
                    data: [{name: "listToJson", value: ""}],
                    dataType: "json",
                    
                    success: function(data, textStatus) {

                        try { 
                        for(i in data){
                            var selector = $('#process' + data[i][0]);
                            var label = $("label[for='"+$(selector).attr('id')+"']");
                            var img_selector = label.find('.status_image');
                            var image_path = current_path + status_options[data[i][1]];
                            img_selector.attr("src", image_path);

                        }} catch (err){
                        console.log(err);
                        }},
                    
                    error: function (data, error) {
                        console.log(error);
                        console.log(data);},
                    
                    global: false // prevent ajaxStart and ajaxStop to be called (with blockUI in them)
            });
        }
    
    $(document).ready(function() {
        selectFirstRadioInputIfPresentAndNoneSelected($("#processesList input:radio"));
        $("#processesList").buttonset();
        $("#processesList img[title]").qtip({
            content: false,
            position: {
                corner: {
                    tooltip: "topRight",
                    target: "bottomLeft"
                }
            },
            style: {
                "font-size": 12,
                //width: "200px",
                width: {
                    max: 700
                },
                border: {
                    width: 2,
                    radius: 8
                },
                name: "cream",
                tip: true
            }
        });
        
        // if this is the first time the page is loaded, set refresh interval
           if (updateInterval === null){updateInterval = setInterval("updateAllStatuses2()", 5000);}
    });
    
</script>

<div id="processesList">
    <stripes:form partial="true" action="/">
        <c:forEach var="process" items="${actionBean.processes}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedProcessId and process.id == actionBean.selectedProcessId}">
                    <input type="radio" id="process${process.id}" name="selectedProcessId" value="${process.id}" class="required" checked="checked"/>
                    <script type="text/javascript" class="ui-layout-ignore">
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

            <stripes:label for="process${process.id}" title="${process.remarks}">
                <span class="process-status-image">
                    <c:if test="${not empty process.schedule}">
                        <img src="<stripes:url value="/images/clock_48.gif"/>"
                             title="<fmt:message key="process.scheduled"/>"
                             alt="process.scheduled" />
                    </c:if>
                    <c:if test="${process.append}">
                        <img src="<stripes:url value="/images/plus.png"/>"
                             title="<fmt:message key="process.append"/>"
                             alt="process.append" />
                    </c:if>
                    <c:if test="${process.linkedProcess != null}">
                        <img src="<stripes:url value="/images/link_go.png"/>"
                             title="<fmt:message key="process.triggeredBy"><fmt:param value="${process.linkedProcess.name}"/></fmt:message>"
                             alt="process.triggeredBy"/>
                    </c:if>
                    <c:choose>
                        <c:when test="${process.processStatus.processStatusType == 'RUNNING'}">
                            <img class ="status_image" src="<stripes:url value="/images/spinner.gif"/>"
                                 title="<fmt:message key="process.running"/>"
                                 alt="process.running" />
                        </c:when>
                        <c:when test="${process.processStatus.processStatusType == 'LAST_RUN_OK'}">
                            <img class ="status_image" src="<stripes:url value="/images/circle_green.png"/>"
                                 title="<c:out value="${process.processStatus.message}"/>"
                                 alt="process.lastRunOk" />
                        </c:when>
                        <c:when test="${process.processStatus.processStatusType == 'LAST_RUN_OK_WITH_ERRORS'}">
                            <img class ="status_image" src="<stripes:url value="/images/circle_groengeel.png"/>"
                                 title="<c:out value="${process.processStatus.message}"/>"
                                 alt="process.lastRunOkWithErrors" />
                        </c:when>
                        <c:when test="${process.processStatus.processStatusType == 'LAST_RUN_FATAL_ERROR'}">
                            <img class ="status_image" src="<stripes:url value="/images/circle_red.png"/>"
                                 title="<c:out value="${process.processStatus.message}"/>"
                                 alt="process.lastRunFatalError" />
                        </c:when>
                        <c:when test="${process.processStatus.processStatusType == 'CANCELED_BY_USER'}">
                            <img class ="status_image" src="<stripes:url value="/images/circle_blue.png"/>"
                                 title="<fmt:message key="process.canceledByUser"/>"
                                 alt="process.canceledByUser" />
                        </c:when>
                    </c:choose>
                </span>
                <c:out value="${process.name}"/> | <c:out value="${process.userName}"/>
            </stripes:label>

            <%-- Add schedule icon if this process is scheduled >
            <c:if test="${not empty process.schedule}">
                <script type="text/javascript" class="ui-layout-ignore">
                    $(document).ready(function() {
                        $("#process${process.id}").button("option", "icons", {primary: "ui-icon-clock"});
                    });
                </script>
            </c:if--%>

        </c:forEach>
    </stripes:form>
</div>