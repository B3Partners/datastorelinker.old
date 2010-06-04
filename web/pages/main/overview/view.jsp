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
            $("<div id='actionsContainer'>Bezig met laden...</div>").appendTo(document.body);

            $("#actionsContainer").dialog({
                title: "Acties...", // TODO: localization
                width: 800,
                height: 700,
                modal: true,
                close: defaultDialogClose,
                buttons: { // TODO: localize button name:
                    "Voltooien" : function() {
                        
                    }
                }
            });

            $.get("${actionsUrl}", "create", function(data) {
                $("#actionsContainer").html(data);
            });
        });
    });
</script>

<div class="radioList">
    <div id="inputOverview" class="ui-widget-content" style="width: 200px; left: 50px; position: absolute">
        <h3 class="ui-widget-header" style="width: 198px; margin-top: 0px">Invoer</h3>
        <div id="inputOverviewContainer">
            Bezig met laden...
        </div>
    </div>

    <div style="width: 50px; left: 250px; position: absolute; text-align: center">
    ->
    </div>

    <div id="actionsOverview" class="ui-widget-content" style="width: 200px; left: 300px; position: absolute">
        <h3 class="ui-widget-header" style="width: 198px; margin-top: 0px">Acties</h3>
        <div id="actionsOverviewContainer">
            Bezig met laden...
            Geen acties gedefinieerd...
        </div>
    </div>

    <div style="width: 50px; left: 500px; position: absolute; text-align: center">
    ->
    </div>

    <div id="outputOverview" class="ui-widget-content" style="width: 200px; left: 550px; position: absolute">
        <h3 class="ui-widget-header" style="width: 198px; margin-top: 0px">Uitvoer</h3>
        <div id="outputOverviewContainer">
            Bezig met laden...
        </div>
    </div>
</div>