<%-- 
    Document   : view
    Created on : 3-jun-2010, 12:29:40
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="actionsUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ActionsAction"/>

<script type="text/javascript">

    $(document).ready(function() {
        $("#inputOverview, #outputOverview, #actionsOverview").hover(
            function() { $(this).addClass("overview-hover"); },
            function() { $(this).removeClass("overview-hover"); }
        );

        $("#inputOverview").click(function() {
            $("#createUpdateProcessForm").data("formwizard").show("SelecteerInvoer");
        });
        
        $("#outputOverview").click(function() {
            $("#createUpdateProcessForm").data("formwizard").show("SelecteerUitvoer");
        });

        $("#actionsOverview").click(function() {
            //log("currentActionsList:");
            //log(currentActionsList);
            ajaxOpen({
                url: "${actionsUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "create",
                containerId: "actionsContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, defaultDialogOptions, {
                    title: "<fmt:message key="createActions"/>",
                    width: 750,//Math.floor($('body').width() * .60),
                    height: 700,//Math.floor($('body').height() * .80), // actielijst hoogte is absoluut dus we kunnen dit nog niet dynamisch maken
                    buttons: {
                        "<fmt:message key="finish"/>" : function() {
                            var actionsListJSON = getCreatedActionList();
                            setActionsList(actionsListJSON);
                            fillActionsList(actionsListJSON, "#actionsOverviewContainer", "${contextPath}", actionsPlaceholder);
                            $("#actionsContainer").dialog("close");
                        }
                    },
                    resize: function(event, ui) {
                        $("#actionsMainContainer").layout().resizeAll();
                        $("#actionsListsContainer").layout().resizeAll();
                    }
                })
            });
        });

    });
</script>

<div>
    <div id="inputOverview" class="ui-widget-content ui-corner-all" style="width: 200px; left: 50px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 184px">
            <fmt:message key="input"/>
        </div>
        <div id="inputOverviewContainer" class="action-list" style="height: 300px">
        </div>
    </div>

    <div style="width: 50px; left: 250px; position: absolute; text-align: center">
    ->
    </div>

    <div id="actionsOverview" class="ui-widget-content ui-corner-all" style="width: 200px; left: 300px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 184px">
            <fmt:message key="actions"/>
        </div>
        <div id="actionsOverviewContainer" class="action-list" style="height: 300px">
        </div>
    </div>

    <div style="width: 50px; left: 500px; position: absolute; text-align: center">
    ->
    </div>

    <div id="outputOverview" class="ui-widget-content ui-corner-all" style="width: 200px; left: 550px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 184px">
            <fmt:message key="output"/>
        </div>
        <div id="outputOverviewContainer" class="action-list" style="height: 300px">
        </div>
    </div>

    <fmt:message var="emailTooltip" key="emailAddressProcessDoneDescription"/>
    <fmt:message var="subjectTooltip" key="subjectProcessDoneDescription"/>
    <div style="top: 340px; position: absolute">
        <table>
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
        </table>
    </div>
    
</div>