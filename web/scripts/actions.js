/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function fillActionsList(actionsListJSON, actionsListSelector, contextPath, addParametersButton) {
    if (actionsListJSON.length > 0)
        $(actionsListSelector).find(".placeholder").remove();

    $.each(actionsListJSON, function(index, action) {
        var div = $("<div class='action ui-corner-all'></div>");
        var type = $("<div class='type'></div>");
        var safeActionClassName = action.className.replace(" ", "_");
        var imageUrl = contextPath + "/images/actions/" + safeActionClassName + "_icon.png";
        var image = $("<img />").attr("src", imageUrl);
        type.append(image);
        type.append(action.className);
        var name = $("<div class='name'></div>");
        name.html(action.name);
        div.append(type);
        div.append(name);
        div.attr("title", action.description);
        div.attr("data", JSON.stringify(action));

        if (addParametersButton)
            appendParametersButton(div);

        $(actionsListSelector).append(div);
    });
}

function appendParametersButton(div) {
    div.addClass("action-dropped");

    var action = div.metadata();
    //log(action);
    var hasParameters = false;
    if (action.parameters) {
        log(action.parameters);
        $.each(action.parameters, function() { hasParameters = true; });
    }

    //log(hasParameters);
    if (hasParameters) {
        var parametersButton = $("<input type='button' value='Parameters...' />");
        parametersButton.button();
        parametersButton.click(function() {
            openParametersDialog(action);
        });
        div.find(".type").append(parametersButton);
    }
}

function openParametersDialog(action) {
    //log(action.parameters);

    var parametersDialog = $("<div></div>");
    parametersDialog.append($("<div></div>").append(action.description));
    parametersDialog.append($("<br />"));
    var parameterForm = $("<form id='parameterForm' action='#'></form>");
    parameterForm.validate(defaultValidateOptions);
    parameterForm.append($("<table><tbody></tbody></table>"));
    parametersDialog.append(parameterForm);

    $.each(action.parameters, function(index, parameter) {
        var row = $("<tr></tr>");
        var key = $("<td></td>");
        var label = $("<label></label>");
        label.append(parameter.name);
        key.append(label);
        var value = $("<td></td>");
        if (parameter.type && parameter.type === "boolean") {
            var checkbox = $("<input type='checkbox' />");
            if (parameter.value === "TRUE") // interne DSL representatie
                checkbox.attr("checked", true);
            value.append(checkbox);
        } else {
            var textbox = $("<input />");
            textbox.val(parameter.value);
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
                log("parametersDialog OK");
                var validating = true;
                
                parametersDialog.find("tr").each(function(index, parameterRow) {
                    var paramKey = $(parameterRow).metadata();
                    var input = $(parameterRow).find("input");

                    if (!$("#parameterForm").valid()) {
                        validating = false;
                        return false;
                    }

                    if (input.attr("type").toLowerCase() === "checkbox") {
                        if (input.is(":checked"))
                            action.parameters[paramKey.key].value = "TRUE"; // interne DSL representatie
                        else
                            action.parameters[paramKey.key].value = "FALSE"; // interne DSL representatie
                    } else {
                        action.parameters[paramKey.key].value = input.val();
                    }
                    return true;
                });
                
                if (validating) {
                    parametersDialog.dialog("close");
                }
            }
        },
        close: function(event, ui) {
            defaultDialogClose(event, ui);
        }
    });
}