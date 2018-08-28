<%-- 
    Document   : view
    Created on : 3-jun-2010, 12:29:40
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<stripes:url var="actionsUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ActionsAction"/>

<script type="text/javascript" class="ui-layout-ignore">

    $(document).ready(function () {
        $("#actionsOverview").click(function () {
            ajaxOpen({
                url: "${actionsUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "create",
                containerId: "actionsContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, defaultDialogOptions, {
                    title: "<fmt:message key="createActions"/>",
                    width: calculateDialogWidth(60, 600, 800),
                    height: calculateDialogHeight(60, 600, 800),
                    buttons: {
                        "<fmt:message key="finish"/>": function () {
                            var actionsListJSON = getCreatedActionList();
                            setActionsList(actionsListJSON);
                            fillActionsList(actionsListJSON, "#actionsOverviewContainer", "${contextPath}", actionsPlaceholder);
                            $("#actionsContainer").dialog("close");
                        }
                    },
                    resize: function (event, ui) {
                        layouts.actionsMainContainer.resizeAll();
                    }
                })
            });
        });
    });

    function overviewLayoutCreate() {
        var dialogWidth = $("#processContainer").width();

        layouts.overviewMainContainer = $("#overviewMainContainer").layout($.extend({}, defaultLayoutOptions, {
            resizable: true,
            west__size: Math.floor(dialogWidth * 0.3),
            east__size: Math.floor(dialogWidth * 0.3),
            west__findNestedContent: true,
            east__findNestedContent: true
        }));

        layouts.overviewActionsContainer = $("#overviewActionsContainer").layout($.extend({}, defaultLayoutOptions, {
            west__size: Math.floor((dialogWidth * 0.4) / 8),
            east__size: Math.floor((dialogWidth * 0.4) / 8),
            center__findNestedContent: true
        }));

        // layout plugin messes up z-indices; sets them to 1
        var topZIndexCss = {"z-index": "auto"};
        // z-index auto disabled input fields in IE7
        if ($.browser.msie && $.browser.version <= 7)
            topZIndexCss = {"z-index": "2100"};
        $("#overviewMainContainer > div").css(topZIndexCss);
        $("#overviewActionsContainer > div").css(topZIndexCss);
        $("#overviewMainContainer .ui-layout-resizer").css(topZIndexCss);

        $(".actions-arrow").hvalign();
        $("#actionsOverviewContainer .placeholder").hvalign();
    }

    function overviewLayoutDestroy() {
        layouts.overviewActionsContainer.destroy();
        layouts.overviewMainContainer.destroy();
    }
</script>

<h1><fmt:message key="process.overview"/></h1>

<div id="overviewMainContainer" class="ui-layout-content" style="width: 100%; height: 100%">
    <%-- Relatief maken als in actions/create.jsp --%>
    <div id="inputOverview" class="ui-layout-west ui-widget-content ui-corner-all" style="margin: 10px">
        <div class="ui-widget-header ui-corner-all action-list-header">
            <fmt:message key="input"/>
        </div>
        <div id="inputOverviewContainer" class="ui-layout-content action-list">
            <div class="titleContainer"></div>
            <div class="colsContainer"></div>
        </div>
    </div>

    <div id="overviewActionsContainer" class="ui-layout-center" style="height: 100%">
        <div class="ui-layout-west">
            <div class="actions-arrow">
                ->
            </div>
        </div>
        <div id="actionsOverview" class="ui-layout-center ui-widget-content ui-corner-all" style="margin: 10px">
            <div class="ui-widget-header ui-corner-all action-list-header">
                <fmt:message key="actions"/>
            </div>
            <div id="actionsOverviewContainer" class="ui-layout-content action-list clickable-list">
            </div>
        </div>
        <div class="ui-layout-east">
            <div class="actions-arrow">
                ->
            </div>
        </div>
    </div>

    <div id="outputOverview" class="ui-layout-east ui-widget-content ui-corner-all" style="margin: 10px">
        <div class="ui-widget-header ui-corner-all action-list-header">
            <fmt:message key="output"/>
        </div>
        <div id="outputOverviewContainer" class="ui-layout-content action-list">
            <div class="titleContainer"></div>
            <div class="colsContainer"></div>
        </div>
    </div>

    <fmt:message var="emailTooltip" key="emailAddressProcessDoneDescription"/>
    <fmt:message var="subjectTooltip" key="subjectProcessDoneDescription"/>
    <div class="ui-layout-south">
        <table style="float:left">
            <tr>
                <td>
                    <stripes:label for="processName" name="processName"/>
                </td>
                <td>
                    <stripes:text id="processName" name="processName" size="50" class="required"/>
                </td>
            </tr>
            <tr>
                <td><stripes:label for="linkedProcess" name="linkedProcess"/></td>
                <td>
                    <stripes:select id="linkedProcess" name="linkedProcess" style="width: 373px">
                        <stripes:option value="-1"><fmt:message key="pickProcess"/></stripes:option>
                        <stripes:options-collection collection="${actionBean.processes}" value="id" label="name"/>
                    </stripes:select>
                </td>
            </tr>
            <tr title="${emailTooltip}">
                <td>
                    <stripes:label for="emailAddress" name="emailAddressProcessDone"/>
                </td>
                <td>
                    <stripes:text id="emailAddress" name="emailAddress" size="50" class="email required"/>
                </td>
            </tr>
            <tr title="${subjectTooltip}">
                <td title="">
                    <stripes:label for="subject" name="subjectProcessDone"/>
                </td>
                <td>
                    <stripes:text id="subject" name="subject" size="50" class="required"/>
                </td>
            </tr>
            <tr>
                <td>
                    <stripes:label for="processRemark" name="processRemark"/>
                </td>
                <td>
                    <stripes:textarea id="processRemark" name="processRemark" />
                </td>
            </tr>
        </table>
            <table style="float:left; margin-left: 70px">
                <caption>Advanced settings</caption>
                <tr>
                    <td><stripes:label name="Custom Filter" for="filter"/></td>
                    <td><stripes:text id="filter" name="filter" style="width: 250px"/></td>
                </tr>
                <tr>
                    <td><stripes:label name="Modify filter" for="modifyFilter"/></td>
                    <td><stripes:text id="modifyFilter" name="modifyFilter" style="width: 250px"/></td>
                </tr>
                <%--tr>
                    <td><input type="checkbox" name="modifyGeom" id="modify"/></td>
                    <td><stripes:label name="Pas geometrie aan" for="modifyGeom"/></td>
                </tr--%>
                <c:if test="${empty actionBean.admin or actionBean.admin == false}">
                <tr>
                    <td><input type="checkbox" name="drop" id="drop"/></td>
                    <td><stripes:label name="table.drop" for="drop"/></td>
                </tr>
                <tr>
                    <td><input type="checkbox" name="append" id="append" /></td>
                    <td><stripes:label name="table.append" for="append"/></td>
                </tr>
                <tr>
                    <td><input type="checkbox" name="modify" id="modify" /></td>
                    <td><stripes:label name="table.modify" for="modify"/></td>
                </tr>
                    
                </c:if>
            </table>
    </div>




</div>