<%-- 
    Document   : view
    Created on : 3-jun-2010, 15:36:19
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<style type="text/css">
.action-list-header {
    margin: 3px;
    /*margin-top: 0px;*/
    margin-bottom: 0px;
    padding: 4px;
}

.action-list {
    height: 500px;
    max-height: 500px;
    /*overflow-x:hidden;
    overflow-y:auto;*/
    overflow: auto;
    margin: 0;
    position: relative; /* to prevent IE <= 7 bug */
}

.action {
    /*list-style-type: none;
    display: list-item;*/
    text-align: left;
    /*background: #eeeeee;
    color: black;*/
    border: 1px solid #196299;
    margin: 3px;
}

.action .type {
    background: #196299;
    color: #fed204;
    padding: 6px 3px 6px 3px;
}

.action .name {
    background: #fed204;
    color: #196299;
    padding: 3px;
}

.action .ui-button {
    margin: 0;
    padding: 0;
    float: right;
}

.action-hover {
    cursor: move;
    background: white;
    border: 1px solid #fed204;
}

/*.action-active {
    background: #fed204;
}*/

.action-dropped {
    /*display: list-item;
    list-style-type: decimal;*/
}

</style>

<script type="text/javascript">
    $(function() {
        $.metadata.setType("attr", "data");
        var actionsWorkbenchList = ${actionBean.actionsWorkbenchList};
        log(actionsWorkbenchList);

        $.each(actionsWorkbenchList, function(index, action) {
            var div = $("<div class='action ui-corner-all'></div>");
            var type = $("<div class='type'></div>");
            var safeActionClassName = action.className.replace(" ", "_");
            var imageUrl = "${contextPath}/images/actions/" + safeActionClassName + "_icon.png";
            var image = $("<img />").attr("src", imageUrl);
            type.append(image);
            type.append(action.className);
            var name = $("<div class='name'></div>");
            name.html(action.name);
            div.append(type);
            div.append(name);
            div.attr("title", action.description);
            div.attr("data", JSON.stringify(action));
            
            $("#actionsWorkbenchContainer").append(div);
        });

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
                log("drop");
                // is called twice for some reason. prevent it with an ugly hack:
                if (!alcDropAlreadyCalled) {
                    $(this).find(".placeholder").remove();

                    ui.draggable.addClass("action-dropped");

                    var action = ui.draggable.metadata();
                    log(action);
                    var hasParameters = false;
                    if (action.parameters) {
                        log(action.parameters);
                        $.each(action.parameters, function() { hasParameters = true; });
                    }

                    log(hasParameters);
                    if (hasParameters) {
                        var parametersButton = $("<input type='button' value='Parameters...' />");
                        parametersButton.button();
                        parametersButton.click(function() {
                            openParametersDialog(action);
                        });
                        ui.draggable.find(".type").append(parametersButton);
                    }
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

    function openParametersDialog(action) {
        //log(action.parameters);

        var parametersDialog = $("<div></div>");
        parametersDialog.append($("<div></div>").append(action.description));
        parametersDialog.append($("<br />"));
        parametersDialog.append($("<table><tbody></tbody></table>"));
        
        $.each(action.parameters, function(index, parameter) {
            var row = $("<tr></tr>");
            var key = $("<td></td>");
            var label = $("<label></label>");
            label.append(parameter.name);
            key.append(label);
            var value = $("<td></td>");
            if (parameter.type && parameter.type === "boolean") {
                var checkbox = $("<input type='checkbox' />");
                value.append(checkbox);
            } else {
                var textbox = $("<input />");
                textbox.addClass(parameter.type);
                value.append(textbox);
            }
            row.append(key);
            row.append(value);
            row.attr("data", "{key: '" + index + "'}");
            parametersDialog.find("tbody").append(row);
        });

        parametersDialog.dialog({
            title: "Bewerk parameters...",
            width: 400,
            modal: true,
            buttons: {
                "Annuleren": function(event, ui) {
                    parametersDialog.dialog("close");
                },
                "OK": function(event, ui) {
                    parametersDialog.find("tr").each(function(index, parameterRow) {
                        var paramKey = $(parameterRow).metadata();
                        var input = $(parameterRow).find("input");

                        if (!$(input).validate())
                            return;

                        if (input.attr("type") == "checkbox") {
                            if (input.val() == "checked")
                                action.parameters[paramKey.key].value = "TRUE"; // interne DSL representatie
                            else
                                action.parameters[paramKey.key].value = "FALSE"; // interne DSL representatie
                        } else {
                            action.parameters[paramKey.key].value = input.val();
                        }
                    });
                    
                    parametersDialog.dialog("close");
                }
            },
            close: function(event, ui) {
                defaultDialogClose(event, ui);
            }
        });
    }
</script>

<div id="actionsMainContainer">
    <div id="actionsList" class="ui-widget-content ui-corner-all" style="width: 300px; left: 50px; position: absolute">
        <div class="ui-widget-header ui-corner-all action-list-header" style="width: 284px">Actielijst</div>
        <div id="actionsListContainer" class="action-list">
            <div class="placeholder" style="top: 200px; left: 50px; position: absolute">
                Sleep uw acties hierheen...
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
