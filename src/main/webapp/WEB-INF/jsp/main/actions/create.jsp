<%-- 
    Document   : create
    Created on : 16-jun-2010, 13:33:59
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<stripes:url var="inputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        var actionsWorkbenchList = ${actionBean.actionsWorkbenchList};
        var actionsList = getActionsList();

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
            start: function(event, ui) {
                ui.helper.width($("#actionsWorkbenchContainer .action").first().width());
            },
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
                // is called twice when draggable is connected to sortable.
                // prevent it with an ugly hack:
                if (!alcDropAlreadyCalled) {
                    $("#actionsListContainer .placeholder").remove();
                    addButtons(ui.draggable);
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

        layouts.actionsMainContainer = $("#actionsMainContainer").layout($.extend({}, defaultLayoutOptions, {//defaultLayoutOptions);
        //$("#actionsListsContainer").layout($.extend({}, defaultLayoutOptions, {
            resizable: true,
            west__size: 300,
            //center__size: 300,
            east__size: 300,
            west__findNestedContent: true,
            east__findNestedContent: true
        }));

        // layout plugin messes up z-indices; sets them to 1
        var topZIndexCss = { "z-index": "auto" };
        // z-index auto disabled input fields in IE7
        if($.browser.msie && $.browser.version <= 7) {
            topZIndexCss = { "z-index": "2100" };
        }
            
        $("#actionsMainContainer, #showExampleContainer").css(topZIndexCss);
        $("#actionsMainContainer > div").css(topZIndexCss);
        /*$("#actionsListsContainer, #showExampleContainer").css(topZIndexCss);
        $("#actionsListsContainer > div").css(topZIndexCss);*/
        $("#actionsMainContainer .ui-layout-resizer").css(topZIndexCss);
        
        dragActionsPlaceholder.hvalign();
    });

</script>

<div id="actionsMainContainer" style="width: 100%; height: 100%">
    <!--div id="actionsListsContainer" class="ui-layout-center"-->
        <div class="ui-layout-west">
            <div id="actionsList" class="ui-widget-content ui-corner-all" style="margin-left: 10px; margin-right: 10px;">
                <div class="ui-widget-header ui-corner-all action-list-header"><fmt:message key="keys.actionlist"/></div>
                <div id="actionsListContainer" class="action-list ui-layout-content"></div>
            </div>
        </div>

        <div id="actionsText" class="ui-layout-center">

        </div>

        <div class="ui-layout-east">
            <div id="actionsWorkbench" class="ui-widget-content ui-corner-all" style="margin-left: 10px; margin-right: 10px;">
                <div class="ui-widget-header ui-corner-all action-list-header"><fmt:message key="keys.workbench"/></div>
                <div id="actionsWorkbenchContainer" class="action-list ui-layout-content"></div>
            </div>
        </div>
    <!--/div-->

    <%--div id="showExampleContainer" class="ui-layout-south">
        <div>
            <input type="checkbox" id="exampleRecordCheckBox" name="showExampleRecord"/>
            <fmt:message key="showExampleRecord"/>
        </div>
        <div id="exampleRecordContainer" style="height: 55px"></div>
    </div--%>
</div>
