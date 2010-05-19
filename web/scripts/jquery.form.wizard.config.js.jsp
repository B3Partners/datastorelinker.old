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
    validationEnabled : false,
    //focusFirstInput : true,
    textNext : "Volgende",
    textBack : "Vorige",
    textSubmit : "Voltooien",
    inAnimation : "slideDown",
    outAnimation : "slideUp",
    afterNext: function(wizardData) {
        //$("#" + wizardData.currentStep + " .ui-widget").enable();
        $("#" + wizardData.currentStep + " .ui-widget").button("enable");
        $("#" + wizardData.currentStep + " .radioList").buttonset("enable");
    }
}

defaultDialogClose = function() {
    $(this).dialog("destroy");
    // volgende regel heel belangrijk!!
    $(this).remove();
}