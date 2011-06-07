/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var actionsPlaceholder = $("<div></div>")
    .addClass("placeholder")
    .append($("<em></em>").html(I18N.defineActions));

var dragActionsPlaceholder = $("<div></div>")
    .addClass("placeholder")
    .append($("<em></em>").html(I18N.dragActions));

// Always use this function to get to the parameters of an Action. 
function getParameters(action) {
    return action.parameters;
}
// Always use this function to set the parameters of an Action.
function setParameters(action, parameters) {
    action.parameters = parameters;
}

function initActionsList(actionsList, contextPath) {
    //log(actionsList);
    setActionsList(actionsList);
    fillActionsList(actionsList, "#actionsOverviewContainer", contextPath, actionsPlaceholder);
}

/**
 * Slaat de actions op in de proces dialog.
 */
function setActionsList(actionsList) {
    //log("setting actionsList in dom metadata:");
    var actionsListObject = {"actionsList": actionsList};
    //log(actionsListObject);
    $("#actionsListMetadata").data("actionsList", actionsListObject);
}

/**
 * Returned de actions opgeslagen in de proces dialog.
 */
function getActionsList() {
    //log("getting actionsList from dom metadata:");
    var metadata = $("#actionsListMetadata").data("actionsList");
    //log(metadata);
    if (!metadata || !metadata.actionsList)
        return [];
    else
        return metadata.actionsList;
}

/**
 * returned de acties die net gecreëerd zijn in de actions dialog.
 */
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

function fillActionsList(actionsListJSON, actionsListSelector, contextPath, placeholder, mustAddButtons) {
    //log("actionsListJSON.length: " + actionsListJSON.length);
    //log("actionsListSelector: " + actionsListSelector);
    //log("later");
    log(actionsListJSON);
    if (actionsListJSON.length == 0) {
        $(actionsListSelector).html(placeholder);
    } else {
        $(actionsListSelector).html("");
        //$(actionsListSelector).empty();
    }

    $.each(actionsListJSON, function(index, action) {
        if (!action)
            return;
        var div = $("<div></div>").addClass("action ui-corner-all");
        var type = $("<div></div>").addClass("type ui-corner-top");
        var safeImageFilename = $.trim(action.imageFilename);//.replace(" ", "_");
        var imageUrl = contextPath + "/images/actions/" + safeImageFilename;
        var image = $("<img />").attr("src", imageUrl);
        type.append(image);
        type.append(action.className);
        var name = $("<div></div>").addClass("name ui-corner-bottom");
        name.html(action.name);
        var exampleParamValue = getExampleParamValue(action);
        name.append($("<span></span>", {
            "class": "value",
            text: exampleParamValue
        }));
        div.append(type);
        div.append(name);
        div.attr("title", action.description);

        //div.data("action", action);
        div.attr("jqmetadata", JSON.stringify(action));
        
        //log(div.attr("jqmetadata"));

        if (mustAddButtons) {
            addButtons(div);
        }

        $(actionsListSelector).append(div);
    });
}

function getExampleParamValue(action) {
    return action.parameters.length === 0 ? "" : action.parameters[0].value;
}

function addButtons(div) {
    addParametersButton(div);
    addRemoveButton(div);
}

function addRemoveButton(div) {
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
    div.find(".type").prepend(removeButton); // prepend moet voor IE7 en IE9
}

function addParametersButton(div) {
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
            value: I18N.parameters
        });
        parametersButton.button();
        parametersButton.click(function() {
            openParametersDialog(action);
            $(this).closest(".action-list").find(".action").removeClass("action-active");
            $(this).closest(".action").addClass("action-active");
        });
        div.find(".type").prepend(parametersButton); // prepend moet voor IE7 en IE9
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

        var label = $("<label></label>", {
            text: parameter.name
        });
        var key = $("<td></td>", {
            html: label
        });
        var input;
        if (parameter.name === I18N["keys.ATTRIBUTE_NAME"] || 
            parameter.name === I18N["keys.ATTRIBUTE_CLASS"] ||
            parameter.name === I18N["keys.NEW_ATTRIBUTE_CLASS"]) {
            input = $("<select />", {
                name: parameter.paramId // required for validation
            });
            if (parameter.name === I18N["keys.ATTRIBUTE_NAME"]) {
                inputColumnNamesJqXhr.done(function(data) {
                    addDataToSelect(data, input, parameter);/*, function(key, value) {
                        return key + " (" + value + ")";
                    });*/
                });
                if (!inputColumnNamesJqXhr.isResolved()) {
                    _appendDefaultParameterValue(input, parameter);
                }
            } else if (parameter.name === I18N["keys.ATTRIBUTE_CLASS"] ||
                       parameter.name === I18N["keys.NEW_ATTRIBUTE_CLASS"]) {
                addDataToSelect(attributeTypeJavaClasses, input, parameter);
            }
        } else {
            input = $("<input />", {
                name: parameter.paramId // required for validation
            });
            if (parameter.type && parameter.type === "boolean") {
                input.attr("type", "checkbox");
                if (parameter.value === true || parameter.value === "true" || parameter.value === "1")
                    input.attr("checked", true);
            } else {
                if (parameter.value === "" || parameter.value === undefined || parameter.value === null) {
                    // default value:
                    input.val(I18N["keys." + parameter.paramId.toUpperCase() + ".default"]);
                } else {
                    input.val(parameter.value);
                }
                input.addClass(parameter.type);
                input.addClass("required"); // checkbox is not required (can be false), only textbox.
            }
        }
        var value = $("<td></td>", {
            html: input
        });
        
        var row = $("<tr></tr>")
            .attr({
                jqmetadata: JSON.stringify(parameter)
            })
            .append(key, value);
        parametersDialog.find("tbody").append(row);
        if (parameter.name === I18N["keys.ATTRIBUTE_NAME"] || 
            parameter.name === I18N["keys.ATTRIBUTE_CLASS"] ||
            parameter.name === I18N["keys.NEW_ATTRIBUTE_CLASS"]) {
            input.combobox();
            input.siblings(":text").addClass("required");
        }
    });

    parameterForm.validate(defaultValidateOptions);

    parametersDialogButtons = {};
    parametersDialogButtons[I18N.cancel] = function(event, ui) {
        parametersDialog.dialog("close");
    }
    parametersDialogButtons[I18N.ok] = function(event, ui) {
        if (!$("#parameterForm").valid())
            return;

        setParameters(action, []);
        //log(getParameters(action));

        parametersDialog.find("tr").each(function(index, parameterRow) {
            var paramMetadata = $(parameterRow).metadata();
            //log("paramMetadata");
            //log(paramMetadata);

            var input = $(parameterRow).find("input");
            /*var select = $(parameterRow).find("select");
            if (select.length > 0) {
                paramMetadata.value = select.val();
                log("paramMetadata.value:" + paramMetadata.value);
                if (!paramMetadata.value) {
                    paramMetadata.value = input.val();
                    log("replace paramMetadata.value:" + paramMetadata.value);
                }                    
            } else {*/
                if (input.is(":checkbox")) {
                    paramMetadata.value = input.is(":checked");
                } else {
                    paramMetadata.value = input.val();
                }
            //}

            getParameters(action).push(paramMetadata);
        });
        //log(getParameters(action));
        
        $("#actionsListContainer").find(".action-active .value").text(getExampleParamValue(action));

        parametersDialog.dialog("close");
    }

    parametersDialog.dialog($.extend({}, defaultDialogOptions, {
        title: I18N.editParameters,
        width: 550,
        buttons: parametersDialogButtons
    }));
}

function addDataToSelect(data, select, parameter, prettyTextCallback) {
    var paramValueFound = false;
    $.each(data, function(key, value) {
        var option = $("<option></option>").attr("value", key);
        option.text(prettyTextCallback ? prettyTextCallback(key, value) : key);
        if (key === parameter.value) {
            option.attr("selected", "selected");
            paramValueFound = true;
        }
        select.append(option);
    });
    if (!paramValueFound) {
        _appendDefaultParameterValue(select, parameter);
    }
}

function _appendDefaultParameterValue(select, parameter) {
    var option = $("<option></option>").attr({
        "value": parameter.value,
        "selected": "selected"
    });
    option.text(parameter.value);
    select.append(option);
}

attributeTypeJavaClasses = {
    "java.lang.String": {},
    "java.lang.Boolean": {},
    "java.lang.Integer": {},
    "java.lang.Float": {}
}