/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var actionsPlaceholder = $("<div></div>")
    .addClass("placeholder")
    .css({
        top: "100px",
        left: "10px",
        position: "absolute",
        "text-align": "center"
    })
    .html("<em>Klik hier om acties te defini&euml;ren...</em>");

var dragActionsPlaceholder = $("<div></div>")
    .addClass("placeholder")
    .css({
        top: "200px",
        left: "50px",
        position: "absolute",
        "text-align": "center"
    })
    .html("<em>Sleep uw acties hierheen...</em>");

// Always use this function to get to the parameters of an Action. 
// SubObject created to accomodate for proper JSON to XML conversion later
function getParameters(action) {
    return action.parameters.parameter;
}
// Always use this function to set the parameters of an Action.
function setParameters(action, parameters) {
    action.parameters.parameter = parameters;
}

function fillActionsList(actionsListJSON, actionsListSelector, contextPath, placeholder, addButtons) {
    //log("actionsListJSON.length: " + actionsListJSON.length);
    //log("actionsListSelector: " + actionsListSelector);
    if (actionsListJSON.length == 0)
        $(actionsListSelector).html(placeholder.clone());
    else {
        $(actionsListSelector).html("");
        //$(actionsListSelector).empty();
    }

    $.each(actionsListJSON, function(index, action) {
        if (!action)
            return;
        var div = $("<div></div>").addClass("action ui-corner-all");
        var type = $("<div></div>").addClass("type");
        var safeActionClassName = action.className.replace(" ", "_");
        var imageUrl = contextPath + "/images/actions/" + safeActionClassName + "_icon.png";
        var image = $("<img />").attr("src", imageUrl);
        type.append(image);
        type.append(action.className);
        var name = $("<div></div>").addClass("name");
        name.html(action.name);
        div.append(type);
        div.append(name);
        div.attr("title", action.description);

        //div.data("action", action);
        div.attr("jqmetadata", JSON.stringify(action));
        
        //log(div.attr("jqmetadata"));

        if (addButtons) {
            appendButtons(div);
        }

        $(actionsListSelector).append(div);
    });
}

function appendButtons(div) {
    appendRemoveButton(div);
    appendParametersButton(div);
}

function appendRemoveButton(div) {
    div.addClass("action-dropped");

    var removeButton = $('<a></a>').css({
        width: "20px"
    });
    removeButton.button({
        text: false,
        icons: {
            primary: "ui-icon-closethick"
        }
    });
    removeButton.click(function() {
        div.remove();
    });
    div.find(".type").append(removeButton);
}

function appendParametersButton(div) {
    var action = div.metadata();
    //var action = div.data("action");
    //log(action);
    var hasParameters = false;
    if (getParameters(action)) {
        log("hasparams");
        log(getParameters(action));
        $.each(getParameters(action), function() {hasParameters = true;});
    }

    //log(hasParameters);
    if (hasParameters) {
        var parametersButton = $("<input />").attr({
            type: "button",
            value: "Parameters..."
        });
        parametersButton.button();
        parametersButton.click(function() {
            openParametersDialog(action);
        });
        div.find(".type").append(parametersButton);
    }
}

function openParametersDialog(action) {
    //log(getParameters(action));

    var parametersDialog = $("<div></div>");
    parametersDialog.append($("<div></div>").append(action.description));
    parametersDialog.append($("<br />"));
    var parameterForm = $("<form></form>").attr({
        id: "parameterForm",
        action: "#"
    });
    parameterForm.append($("<table><tbody></tbody></table>"));
    parametersDialog.append(parameterForm);

    $.each(getParameters(action), function(index, parameter) {
        log("parameter");
        log(parameter);

        var row = $("<tr></tr>").attr({
            jqmetadata: JSON.stringify(parameter)
        });

        var key = $("<td></td>");
        var label = $("<label></label>");
        label.append(parameter.name);
        key.append(label);
        var value = $("<td></td>");
        var input = $("<input />").attr({
            name: parameter.paramId // required for validation
        });
        if (parameter.type && parameter.type === "boolean") {
            input.attr("type", "checkbox");
            if (parameter.value === true || parameter.value == "true")
                input.attr("checked", true);
        } else {
            input.val(parameter.value);
            input.addClass(parameter.type);
        }
        value.append(input);
        row.append(key);
        row.append(value);
        parametersDialog.find("tbody").append(row);
    });

    parameterForm.validate(defaultValidateOptions);

    parametersDialog.dialog({
        title: "Bewerk parameters...",
        width: 550,
        modal: true,
        buttons: {
            "Annuleren": function(event, ui) {
                parametersDialog.dialog("close");
            },
            "OK": function(event, ui) {
                if (!$("#parameterForm").valid())
                    return;

                setParameters(action, []);
                //log(getParameters(action));

                parametersDialog.find("tr").each(function(index, parameterRow) {
                    var paramMetadata = $(parameterRow).metadata();
                    //log("paramMetadata");
                    //log(paramMetadata);

                    var input = $(parameterRow).find("input");

                    if (input.is(":checkbox")) {
                        paramMetadata.value = input.is(":checked");
                    } else {
                        paramMetadata.value = input.val();
                    }
                    
                    getParameters(action).push(paramMetadata);
                });
                //log(getParameters(action));
                
                parametersDialog.dialog("close");
            }
        },
        close: function(event, ui) {
            defaultDialogClose(event, ui);
        }
    });
}