<%-- 
    Document   : view
    Created on : 3-jun-2010, 15:36:19
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<style type="text/css">
.actions-hover {
    cursor: move;
}
</style>

<script type="text/javascript">
    $(function() {
        $("#actionsMainContainer li").live("mouseenter",
            function() { $(this).addClass("actions-hover"); }
        );
        $("#actionsMainContainer li").live("mouseleave",
            function() { $(this).removeClass("actions-hover"); }
        );

        $("#actionsWorkbenchContainer li").draggable({ 
            revert: "invalid",
            helper: "clone",
            cursor: "move",
            connectToSortable: "#actionsListContainer"
        });
        
        $("#actionsListContainer").droppable({
            activeClass: "ui-state-highlight",
            //hoverClass: "ui-state-hover",
            //accept: ":not(.ui-sortable-helper)",
            drop: function(event, ui) {
                $(this).find(".placeholder").remove();
            }
        });
        
        $("#actionsListContainer").sortable({
            items: "li:not(.placeholder)",
            sort: function() {
                // gets added unintentionally by droppable interacting with sortable
                // using connectWithSortable fixes this, but doesn't allow you to customize active/hoverClass options
                $(this).removeClass("ui-state-highlight");
            }
        });
    });
</script>

<div id="actionsMainContainer" class="dailogContent">
    <div id="actionsList" class="ui-widget-content" style="width: 200px; left: 50px; position: absolute">
        <h3 class="ui-widget-header" style="width: 198px; margin-top: 0px">Actielijst</h3>
        <ol id="actionsListContainer">
            <li class="placeholder">Sleep uw acties hierheen...</li>
        </ol>
    </div>

    <div id="actionsText" style="width: 200px; left: 250px; position: absolute">

    </div>

    <div id="actionsWorkbench" class="ui-widget-content" style="width: 200px; left: 450px; position: absolute">
        <h3 class="ui-widget-header" style="width: 198px; margin-top: 0px">Werkbank</h3>
        <ul id="actionsWorkbenchContainer">
            <li>test1</li>
            <li>test2</li>
            <li>test3</li>
        </ul>
    </div>
</div>
