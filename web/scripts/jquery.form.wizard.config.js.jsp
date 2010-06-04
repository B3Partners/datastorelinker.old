<%-- 
    Document   : jquery.form.wizard.config.js
    Created on : 12-mei-2010, 18:27:14
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

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
    // volgende regel heel belangrijk!!
    dialog.remove();
}

defaultValidateOptions = {
    errorClass: "ui-state-error"
}