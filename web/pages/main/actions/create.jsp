<%-- 
    Document   : create
    Created on : 16-jun-2010, 13:33:59
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        var actionsWorkbenchList = ${actionBean.actionsWorkbenchList};
        log(actionsWorkbenchList);
        var actionsList = getActionsList();
        //log(actionsList);

        fillActionsList(actionsWorkbenchList, "#actionsWorkbenchContainer", "${contextPath}");
        fillActionsList(actionsList, "#actionsListContainer", "${contextPath}", dragActionsPlaceholder, true);

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
            accept: ".action:not(.ui-sortable-helper)",
            /*accept: ".blaat",*/
            /*greedy: true,*/
            drop: function(event, ui) {
                //log("drop");
                // is called twice when draggable is connected to sortable.
                // prevent it with an ugly hack:
                if (!alcDropAlreadyCalled) {
                    $("#actionsListContainer .placeholder").remove();
                    appendButtons(ui.draggable);
                }
                
                alcDropAlreadyCalled = !alcDropAlreadyCalled;
            }
        });

        $("#actionsListContainer").sortable({
            items: "> .action:not(.placeholder)",
            axis: "y",
            appendTo: "#actionsContainer",
            sort: function() {
                // gets added unintentionally by droppable interacting with sortable
                // using connectWithSortable fixes this, but doesn't allow you to customize active/hoverClass options
                $(this).removeClass("ui-state-highlight");
            }
        });

    });

    function getCreatedActionList() {
        //log("getActionList");
        var actionList = [];
        $("#actionsListContainer").children(":not(.placeholder)").each(function(index, actionDiv) {
            actionList.push($(actionDiv).metadata());
            //actionList.push($(actionDiv).data("action"));
        })
        //log(actionList);
        return actionList;
    }
</script>

<div id="actionsMainContainer">
    <div id="actionsList" class="ui-widget-content ui-corner-all" style="width: 300px; left: 50px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 284px">Actielijst</div>
        <div id="actionsListContainer" class="action-list"></div>
    </div>

    <div id="actionsText" style="width: 100px; left: 350px; position: absolute">

    </div>

    <div id="actionsWorkbench" class="ui-widget-content ui-corner-all" style="width: 300px; left: 450px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 284px">Werkbank</div>
        <div id="actionsWorkbenchContainer" class="action-list"></div>
    </div>
</div>
