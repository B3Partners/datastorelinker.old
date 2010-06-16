<%-- 
    Document   : create
    Created on : 16-jun-2010, 13:33:59
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $.metadata.setType("attr", "data");

        var actionsWorkbenchList = ${actionBean.actionsWorkbenchList};
        var actionsList = null;
        if (typeof currentActionsList == "undefined" || !currentActionsList)
            actionsList = ${actionBean.actionsList};
        else
            actionsList = currentActionsList;
        
        log(actionsWorkbenchList);
        log(actionsList);

        fillActionsList(actionsWorkbenchList, "#actionsWorkbenchContainer", "${contextPath}");
        fillActionsList(actionsList, "#actionsListContainer", "${contextPath}", true);

        $("#actionsMainContainer .action").live("mouseenter",
            function() { $(this).addClass("action-hover"); }
        );
        $("#actionsMainContainer .action").live("mouseleave",
            function() { $(this).removeClass("action-hover"); }
        );

        $("#actionsWorkbenchContainer .action").draggable({
            //snap: true,
            revert: "invalid",
            helper: "clone",
            cursor: "move",
            scroll: false,
            appendTo: "#actionsContainer",
            connectToSortable: "#actionsListContainer"
        });

        alcDropAlreadyCalled = false;

        $("#actionsListContainer").droppable({
            activeClass: "ui-state-highlight",
            hoverClass: "ui-state-hover",
            accept: ":not(.ui-sortable-helper)",
            drop: function(event, ui) {
                //log("drop");
                // is called twice for some reason. prevent it with an ugly hack:
                if (!alcDropAlreadyCalled) {
                    $(this).find(".placeholder").remove();
                    appendParametersButton(ui.draggable);
                }
                alcDropAlreadyCalled = !alcDropAlreadyCalled;
            }
        });

        $("#actionsListContainer").sortable({
            items: ".action:not(.placeholder)",
            axis: "y",
            appendTo: "#actionsContainer",
            sort: function() {
                // gets added unintentionally by droppable interacting with sortable
                // using connectWithSortable fixes this, but doesn't allow you to customize active/hoverClass options
                //$(this).removeClass("ui-state-highlight");
            }
        });

    });

    function getActionList() {
        //log("getActionList");
        var actionList = [];
        $("#actionsListContainer").children(":not(.placeholder)").each(function(index, actionDiv) {
            actionList.push($(actionDiv).metadata());
        })
        //log(actionList);
        return actionList;
    }
</script>

<div id="actionsMainContainer">
    <div id="actionsList" class="ui-widget-content ui-corner-all" style="width: 300px; left: 50px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 284px">Actielijst</div>
        <div id="actionsListContainer" class="action-list">
            <div class="placeholder" style="top: 200px; left: 50px; position: absolute">
                <em>Sleep uw acties hierheen...</em>
            </div>
        </div>
    </div>

    <div id="actionsText" style="width: 100px; left: 350px; position: absolute">

    </div>

    <div id="actionsWorkbench" class="ui-widget-content ui-corner-all" style="width: 300px; left: 450px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 284px">Werkbank</div>
        <div id="actionsWorkbenchContainer" class="action-list"></div>
    </div>
</div>
