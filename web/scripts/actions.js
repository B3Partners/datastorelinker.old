/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var actionsPlaceholder = $('<div class="placeholder" style="top: 150px; left: 10px; position: absolute; text-align: center"></div>');
actionsPlaceholder.html('<em>Klik hier om acties te defini&euml;ren...</em>');


function fillActionsList(actionsListJSON, actionsListSelector, contextPath, addButtons) {
    if (actionsListJSON.length == 0)
        $(actionsListSelector).html(actionsPlaceholder);
    else {
        $(actionsListSelector).empty();
    }

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

    var removeButton = $('<a style="width: 20px"></a>');
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
    //log(action);
    var hasParameters = false;
    if (action.parameters) {
        log(action.parameters);
        $.each(action.parameters, function() {hasParameters = true;});
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
    parameterForm.append($("<table><tbody></tbody></table>"));
    parametersDialog.append(parameterForm);

    $.each(action.parameters, function(index, parameter) {
        var row = $("<tr></tr>");
        var key = $("<td></td>");
        var label = $("<label></label>");
        label.append(parameter.name);
        key.append(label);
        var value = $("<td></td>");
        var input = $("<input />");
        input.attr("name", index); // required for validation
        if (parameter.type && parameter.type === "boolean") {
            input.attr("type", "checkbox");
            if (parameter.value === true)
                input.attr("checked", true);
        } else {
            input.val(parameter.value);
            input.addClass(parameter.type);
        }
        value.append(input);
        row.append(key);
        row.append(value);
        row.attr("data", "{key: '" + index + "'}");
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

                parametersDialog.find("tr").each(function(index, parameterRow) {
                    var paramKey = $(parameterRow).metadata();
                    var input = $(parameterRow).find("input");

                    if (input.is("checkbox")) {
                        action.parameters[paramKey.key].value = input.is(":checked");
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