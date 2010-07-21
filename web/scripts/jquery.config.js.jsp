<%-- 
    Document   : jquery.form.wizard.config.js
    Created on : 12-mei-2010, 18:27:14
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

$(document).ready(function() {
    // general metadata setting:
    $.metadata.setType("attr", "jqmetadata");

    // extra input mask definitions (e.g. to create a time mask).
    $.mask.definitions['1']='[0-1]';
    $.mask.definitions['2']='[0-2]';
    $.mask.definitions['3']='[0-3]';
    $.mask.definitions['4']='[0-4]';
    $.mask.definitions['5']='[0-5]';
    $.mask.definitions['6']='[0-6]';
    $.mask.definitions['7']='[0-7]';
    $.mask.definitions['8']='[0-8]';

    $.validator.addMethod("time", function (value) {
        try {
            var time = value.split(":");

            var hours = parseInt(time[0], 10);
            var minutes = parseInt(time[1], 10);

            return hours >= 0 && hours < 24 && minutes >= 0 && minutes < 60;
        }
        catch(error) {
            return false;
        }
    }, "Voer een correcte tijd in.");

});

defaultDialogClose = function(event, ui) {
    var dialog = $(event.target);
    // destroy dialog data and all jquery ui widgets inside it (form wizard for example):
    dialog.dialog("destroy");
    // destroy dialog element itself
    dialog.remove();
}

defaultValidateOptions = {
    errorClass: "ui-state-error"
}

defaultLayoutOptions = {
    resizable: false,
    closable: false
};

defaultDialogLayoutOptions = $.extend({}, defaultLayoutOptions, {
    resizeWithWindow: false
});

defaultDialogOptions = {
    modal: true,
    close: defaultDialogClose
};


// TODO: localization
formWizardConfig = {
    historyEnabled : false,
    formPluginEnabled : true,
    validationEnabled : true,
    validationOptions: defaultValidateOptions,
    //focusFirstInput : true,
    textNext : "Volgende",
    textBack : "Vorige",
    textSubmit : "Voltooien"
}

// formwiz 3.0
function formWizardStep(data) {
    // Dit is om ervoor te zorgen dat de formWizard plugin goed samenwerkt met buttonset van jQuery UI.
    // Dit doet het niet automatisch.
    $("#" + data.currentStep + " .ui-buttonset").buttonset("enable");
}

/**
 * Returns a z-index above all other z-indices, excluding certain application specific classes
 */
function getTopZIndexCss() {
    var currentZIndex = $.maxZIndex({
        exclude: [".ui-resizable-handle", ".blockUI"]
    });
    return { "z-index": (currentZIndex) };
}