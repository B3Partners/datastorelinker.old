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
    setActionsList(actionsList);
    fillActionsList(actionsList, "#actionsOverviewContainer", contextPath, actionsPlaceholder);
}

/**
 * Slaat de actions op in de proces dialog.
 */
function setActionsList(actionsList) {
    var actionsListObject = {"actionsList": actionsList};
    $("#actionsListMetadata").data("actionsList", actionsListObject);
}

/**
 * Returned de actions opgeslagen in de proces dialog.
 */
function getActionsList() {
    var metadata = $("#actionsListMetadata").data("actionsList");
    if (!metadata || !metadata.actionsList) {
        return [];
    } else {
        return metadata.actionsList;
    }
}

/**
 * returned de acties die net gecreëerd zijn in de actions dialog.
 */
function getCreatedActionList() {
    var actionList = [];
    $("#actionsListContainer").children(":not(.placeholder)").each(function(index, actionDiv) {
        actionList.push($(actionDiv).metadata());
    });
    
    return actionList;
}

function fillActionsList(actionsListJSON, actionsListSelector, contextPath, placeholder, mustAddButtons) {
    if (actionsListJSON.length === 0) {
        $(actionsListSelector).html(placeholder);
    } else {
        $(actionsListSelector).html("");
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
    var hasParameters = false;
    
    if (getParameters(action)) {
        $.each(getParameters(action), function() {hasParameters = true;});
    }
    
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

var validateInputMappedFields = true;

function openParametersDialog(action) {
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
        var label = $("<label></label>", {
            text: parameter.name
        });
        
        var key = $("<td></td>", {
            html: label
        });
        
        var input;      
        
        if (isInputMappingParam(parameter)) {
            validateInputMappedFields = false;
        }
                
        if (parameter.name === I18N["keys.ATTRIBUTE_NAME"] || 
            parameter.name === I18N["keys.ATTRIBUTE_CLASS"] ||
            parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS1"] ||
            parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS2"] ||
            parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS3"] ||
            parameter.name === I18N["keys.ATTRIBUTE_NAME_CITY"] ||
            parameter.name === I18N["keys.NEW_ATTRIBUTE_CLASS"] ||
            isOutputMappingParam(parameter)) {
            
            if (isOutputMappingParam(parameter)) {
                parameter.paramId = parameter.paramId.replace("outputmapping.","");
            }
            
            input = $("<select />", {
                name: parameter.paramId // required for validation
            });
            
            if (parameter.name === I18N["keys.ATTRIBUTE_NAME"] ||
                parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS1"] ||
                parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS2"] ||
                parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS3"] ||
                parameter.name === I18N["keys.ATTRIBUTE_NAME_CITY"]) {
                inputColumnNamesJqXhr.done(function(data) {
                    addDataToSelect(data, input, parameter);
                });
                if (!inputColumnNamesJqXhr.isResolved()) {
                    _appendDefaultParameterValue(input, parameter);
                }
            } else if (parameter.name === I18N["keys.ATTRIBUTE_CLASS"] ||
                       parameter.name === I18N["keys.NEW_ATTRIBUTE_CLASS"]) {
                addDataToSelect(attributeTypeJavaClasses, input, parameter);
            
            } else if (isOutputMappingParam(parameter)) {                
                inputColumnNamesJqXhr.done(function(data) {
                    addDataToSelect(data, input, parameter);
                });
                if (!inputColumnNamesJqXhr.isResolved()) {
                    _appendDefaultParameterValue(input, parameter);
                }
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
                
                if (parameter.optional && parameter.optional === "true") {
                    input.addClass("optional"); 
                } else {
                    input.addClass("required"); 
                }
            }
        }
        
        var pijltje = $("<td></td>", {
            html: ""
        });
        
        if (isInputMappingParam(parameter) || isOutputMappingParam(parameter)) {
            pijltje = $("<td></td>", {
                html: "<label>-></label>"
            });
        }
        
        var value = $("<td></td>", {
            html: input
        });
        
        var row;
        
        if (isOutputMappingParam(parameter)) {
            row = $("<tr></tr>").attr({jqmetadata: JSON.stringify(parameter)})
            .append(value, pijltje, key);
        } else {
            row = $("<tr></tr>").attr({jqmetadata: JSON.stringify(parameter)})
            .append(key, pijltje, value);
        }
        
        parametersDialog.find("tbody").append(row);
        if (parameter.name === I18N["keys.ATTRIBUTE_NAME"] || 
            parameter.name === I18N["keys.ATTRIBUTE_CLASS"] ||
            parameter.name === I18N["keys.NEW_ATTRIBUTE_CLASS"]) {
            input.combobox();
            input.siblings(":text").addClass("required");
        }

        if (parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS1"] ||
            parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS2"] ||
            parameter.name === I18N["keys.ATTRIBUTE_NAME_ADDRESS3"] ||
            parameter.name === I18N["keys.ATTRIBUTE_NAME_CITY"]) {
            
            input.combobox();
        }
        
        if (isOutputMappingParam(parameter)) {
            input.combobox();
        }
    });

    if (validateInputMappedFields)
        parameterForm.validate(defaultValidateOptions);

    parametersDialogButtons = {};
    parametersDialogButtons[I18N.cancel] = function(event, ui) {
        parametersDialog.dialog("close");
    };
    
    parametersDialogButtons[I18N.ok] = function(event, ui) {
        
        if (validateInputMappedFields) {
            if (!$("#parameterForm").valid()) {
                return;
            }
        }

        setParameters(action, []);

        parametersDialog.find("tr").each(function(index, parameterRow) {
            var paramMetadata = $(parameterRow).metadata();

            var input = $(parameterRow).find("input");
            
            if (input.is(":checkbox")) {
                paramMetadata.value = input.is(":checked");
            } else {
                paramMetadata.value = input.val();
            }            

            getParameters(action).push(paramMetadata);
        });
        
        $("#actionsListContainer").find(".action-active .value").text(getExampleParamValue(action));

        parametersDialog.dialog("close");
    };

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

function isInputMappingParam(parameter) { 
    if (parameter.inputmapping) {
        return true;
    }        
    
    return false;
}

function isOutputMappingParam(parameter) { 
    if (parameter.outputmapping) {
        return true;
    }        
    
    return false;
}

attributeTypeJavaClasses = {
    "java.lang.String": {},
    "java.lang.Boolean": {},
    "java.lang.Integer": {},
    "java.lang.Float": {},
    "java.lang.Double": {},
    "java.lang.Short": {},
    "java.util.Date": {},
    "org.locationtech.jts.geom.Polygon": {},
    "org.locationtech.jts.geom.MultiPolygon": {},
    "org.locationtech.jts.geom.Point": {},
    "org.locationtech.jts.geom.MultiPoint": {},
    "org.locationtech.jts.geom.LineString": {},
    "org.locationtech.jts.geom.MultiLineString": {}
};