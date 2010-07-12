<%-- 
    Document   : jquery.form.wizard.config.js
    Created on : 12-mei-2010, 18:27:14
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

$(function() {
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
});

// TODO: localization
formWizardConfig = {
    historyEnabled : false,
    formPluginEnabled : true,
    validationEnabled : true,
    //focusFirstInput : true,
    textNext : "Volgende",
    textBack : "Vorige",
    textSubmit : "Voltooien",
    inAnimation : "slideDown",
    outAnimation : "slideUp",
    afterNext: function(wizardData) {
        // Dit is om ervoor te zorgen dat de formWizard plugin goed samenwerkt met jQuery UI.
        // Dit doet het niet automatisch.
        //$("#" + wizardData.currentStep + " .ui-widget").enable();
        $("#" + wizardData.currentStep + " .ui-widget").button("enable");
        $("#" + wizardData.currentStep + " .radioList").buttonset("enable");
    }
}

defaultDialogClose = function(event, ui) {
    var dialog = $(event.target);
    dialog.dialog("destroy");
    // volgende regel heel belangrijk!! (alle andere regels natuurlijk ook)
    dialog.remove();
}

defaultValidateOptions = {
    errorClass: "ui-state-error"
}