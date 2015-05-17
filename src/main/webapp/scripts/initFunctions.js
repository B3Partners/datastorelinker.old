/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function initInput() {
    $("#createInputDB, #createInputFile, #updateInput, #deleteInput").button();
    initGuiInput();
}

function initGuiInput() {
    selectFirstRadioInputIfPresentAndNoneSelected($("#inputList input:radio"));
    $("#inputList").buttonset();
}

function initOrgs() {
    $("#createOrganization, #updateOrganization, #deleteOrganization").button();
    initGuiInput();
}

function initOutputRights() {
    $("#createOutputRights, #updateOutputRights, #deleteOutputRights").button();
    initGuiInput();
}

function initUsers() {
    $("#createUser, #updateUser, #deleteUser").button();
    initGuiInput();
}

function initOutput() {
    $("#createOutput, #updateOutput, #deleteOutput").button();
    initGuiOutput();
}

function initGuiOutput() {
    selectFirstRadioInputIfPresentAndNoneSelected($("#outputList input:radio"));
    $("#outputList").buttonset();
}

function initDatabase() {
    $("#createDB, #updateDB, #deleteDB").button();
}

function initDatabaseOutput() {
    $("#createDB, #updateDB, #deleteDB").button();
}

function initServicesOutput() {
    $("#publish").button();
}

function initFile() {
    $("#uploadFile, #deleteFile, #uploader").button();
}

function createDefaultVerticalLayout(jqElem, extraLayoutOptions) {
    var children = jqElem.children(":visible");
    if (children.first().is("form"))
        children = children.first().children(":visible");

    if (!extraLayoutOptions)
        extraLayoutOptions = {};
    
    if (children.length != 3) {
        alert("Number of children for vertical layout must be 3. It is " + children.length + ". Element: " + jqElem);
        
        return false;
    } else {
        children.removeClass("ui-layout-content ui-layout-north ui-layout-center ui-layout-south ui-layout-west ui-layout-east");
        $(children[0]).addClass("ui-layout-north");
        $(children[1]).addClass("ui-layout-center");
        $(children[2]).addClass("ui-layout-south");
        var layout = jqElem.layout($.extend({}, defaultLayoutOptions, extraLayoutOptions));
        //jqElem.layout($.extend({}, defaultLayoutOptions, extraLayoutOptions)).initContent("center");
        $(children[0]).css("z-index", "auto");
        $(children[1]).css("z-index", "auto");
        $(children[2]).css("z-index", "auto");
        return layout;
    }
}

function selectFirstRadioInputIfPresentAndNoneSelected($radios) {
    if ($radios.length > 0 && $radios.filter(":checked").length === 0) {
        $radios.first().prop("checked", true);
    }
}

