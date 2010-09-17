<%-- 
    Document   : create
    Created on : 16-jun-2010, 13:33:59
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<stripes:url var="inputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>

<script type="text/javascript">
    $(document).ready(function() {
        var actionsWorkbenchList = ${actionBean.actionsWorkbenchList};
        log(actionsWorkbenchList);
        var actionsList = getActionsList();
        log(actionsList);

        fillActionsList(actionsWorkbenchList, "#actionsWorkbenchContainer", "${contextPath}");
        fillActionsList(actionsList, "#actionsListContainer", "${contextPath}", dragActionsPlaceholder, true);

        $("#actionsMainContainer").layout(defaultLayoutOptions);
        $("#actionsListsContainer").layout($.extend({}, defaultLayoutOptions, {
            resizable: true,
            east__size: 300,
            west__size: 300
        }));

        // layout plugin messes up z-indices; sets them to 1
        var topZIndexCss = { "z-index": "auto" };
        $("#actionsListsContainer, #showExampleContainer").css(topZIndexCss);
        $("#actionsListsContainer > div").css(topZIndexCss);
        $("#actionsMainContainer .ui-layout-resizer").css(topZIndexCss);

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

        $("#exampleRecordCheckBox").click(function() {
            if ($(this).is(":checked")) {
                if ($("#exampleRecordContainer").html() == "") {
                    // formwiz zet gehide wizardpages uit. dus zelf opzoeken:
                    var inputId = $("#inputListContainer input:checked").val();
                    ajaxOpen({
                        url: "${inputUrl}",
                        event: "getExampleRecord",
                        extraParams: [{
                            name: "selectedInputId",
                            value: inputId
                        }],
                        containerSelector: "#exampleRecordContainer",
                        successAfterContainerFill: function() {
                            $("#actionsMainContainer").layout(defaultLayoutOptions).resizeAll();//initContent("south");
                        }
                    });
                } else {
                    $("#exampleRecordContainer").show(500);
                }
            } else {
                $("#exampleRecordContainer").hide(500);
            }
            // niet false returnen aangezien de checkbox wel op true gezet moet worden.
        });

    });

</script>

<div id="actionsMainContainer" style="width: 100%; height: 100%;">
    <div id="actionsListsContainer" class="ui-layout-center">
        <div class="ui-layout-west">
            <div id="actionsList" class="ui-widget-content ui-corner-all" style="margin-left: 10px">
                <div class="ui-widget-header ui-corner-all action-list-header">Actielijst</div>
                <div id="actionsListContainer" class="action-list ui-layout-content"></div>
            </div>
        </div>

        <div id="actionsText" class="ui-layout-center">

        </div>

        <div class="ui-layout-east">
            <div id="actionsWorkbench" class="ui-widget-content ui-corner-all" style="margin-right: 10px">
                <div class="ui-widget-header ui-corner-all action-list-header">Werkbank</div>
                <div id="actionsWorkbenchContainer" class="action-list ui-layout-content"></div>
            </div>
        </div>
    </div>

    <div id="showExampleContainer" class="ui-layout-south">
        <div>
            <input type="checkbox" id="exampleRecordCheckBox" name="showExampleRecord"/>
            <fmt:message key="showExampleRecord"/>
        </div>
        <div id="exampleRecordContainer" style="height: 55px"></div>
    </div>
</div>
