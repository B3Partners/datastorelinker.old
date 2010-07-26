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
                dialogOptions: {
                    title: "<fmt:message key="createActions"/>",
                    width: 800,
                    height: 700,
                    modal: true,
                    close: defaultDialogClose,
                    buttons: {
                        "<fmt:message key="finish"/>" : function() {
                            var actionsListJSON = getCreatedActionList();
                            setActionsList(actionsListJSON);
                            fillActionsList(actionsListJSON, "#actionsOverviewContainer", "${contextPath}", actionsPlaceholder);
                            $("#actionsContainer").dialog("close");
                        }
                    }
                }
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
</div>