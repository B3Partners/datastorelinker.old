<%-- 
    Document   : view
    Created on : 3-jun-2010, 12:29:40
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="actionsUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ActionsAction"/>

<style type="text/css">
.overview-hover {
    /*cursor: hand;*/
    cursor: pointer;
}
</style>

<script type="text/javascript">
    $(function() {
        $("#inputOverview, #outputOverview, #actionsOverview").hover(
            function() { $(this).addClass("overview-hover"); },
            function() { $(this).removeClass("overview-hover"); }
        );

        $("#inputOverview").click(function() {
            $("#createUpdateProcessForm").formwizard("show", "#SelecteerInvoer");
        });
        
        $("#outputOverview").click(function() {
            $("#createUpdateProcessForm").formwizard("show", "#SelecteerUitvoer");
        });

        $("#actionsOverview").click(function() {
            ajaxOpen({
                url: "${actionsUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "create",
                containerId: "actionsContainer",
                openInDialog: true,
                dialogOptions: {
                    title: "Acties...", // TODO: localization
                    width: 800,
                    height: 700,
                    modal: true,
                    close: defaultDialogClose,
                    buttons: { // TODO: localize button name:
                        "Voltooien" : function() {
                            currentActionsList = getActionList();
                            $("#actionsOverviewContainer .action").remove();
                            fillActionsList(currentActionsList, "#actionsOverviewContainer", "${contextPath}");
                            $("#actionsContainer").dialog("close");
                        }
                    }
                }
            });
        });

    });
</script>

<div class="radioList">
    <div id="inputOverview" class="ui-widget-content ui-corner-all" style="width: 200px; left: 50px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 184px">Invoer</div>
        <div id="inputOverviewContainer" class="action-list" style="height: 300px">
            Bezig met laden...
        </div>
    </div>

    <div style="width: 50px; left: 250px; position: absolute; text-align: center">
    ->
    </div>

    <div id="actionsOverview" class="ui-widget-content ui-corner-all" style="width: 200px; left: 300px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 184px">Acties</div>
        <div id="actionsOverviewContainer" class="action-list" style="height: 300px">
            <div class="placeholder" style="top: 150px; left: 10px; position: absolute; text-align: center">
                <em>Klik hier om acties te defini&euml;ren...</em>
            </div>
        </div>
    </div>

    <div style="width: 50px; left: 500px; position: absolute; text-align: center">
    ->
    </div>

    <div id="outputOverview" class="ui-widget-content ui-corner-all" style="width: 200px; left: 550px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 184px">Uitvoer</div>
        <div id="outputOverviewContainer" class="action-list" style="height: 300px">
            Bezig met laden...
        </div>
    </div>
</div>