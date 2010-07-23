/*
 * Needs jquery.
 *
 */

// Global ajax settings:
$.ajaxSetup({
    cache: false
});

var blockUIOptions = {
    message: "<h2 style='text-align: center'>Bezig met laden...</h2>",
    theme: true,
    baseZ: 10000
    //showOverlay: false
}
var unblockUIOptions = {
    fadeOut: 0 // minder mooi, maar voorkomt z-index issues met jquery ui modal dialog
}

$(document).ajaxStart(function() {
    $.blockUI(blockUIOptions);
});

$(document).ajaxStop(function() {
    $.unblockUI(unblockUIOptions);
});

$(document).ajaxError(function(event, xhr, ajaxOptions, thrownError) {
    $.unblockUI(unblockUIOptions);
    
    /*log(event);
    log(xhr);
    log(ajaxOptions);
    log(thrownError);*/

    var errorMessage;
    if (xhr.status == 1000) {
        errorMessage = thrownError + event;
    } else if (xhr.status == 0) {
        errorMessage = "U bent offline.\nControleer uw netwerkinstellingen.";
    } else if (xhr.status == 404) {
        errorMessage = "Opgevraagde pagina niet gevonden: " + ajaxOptions.url;
    } else if (xhr.status == 500) {
        errorMessage = "Interne server fout";//: " + xhr.responseText; // show error to user?
    } else if (thrownError == "parsererror") {
        errorMessage = "Parsen van het request is mislukt.";
    } else if (thrownError == "timeout") {
        errorMessage = "Het ophalen van de pagina duurde te lang.";
    } else {
        errorMessage = "Onbekende fout";
    }

    if (event.target != document) {
        $(event.target).html(errorMessage);
    } else {
        $("<div id='errorDialog'>" + errorMessage + "</div>").appendTo(document.body);
        $("#errorDialog").dialog({
            title: "Fout!",
            modal: true,
            buttons: {
                "Ok": function() {
                    $(this).dialog("close");
                }
            },
            close: defaultDialogClose
        });
    }

    // close any open confirmation dialogs:
    //$(".confirmationDialog").dialog("close");
});

// Use this function for all your ajax calls
function ajaxOpen(sendOptions) {
    var options = $.extend({
        url: "",
        formSelector: "",
        event: "",
        containerSelector: "",
        containerId: "",
        containerWaitText: "",//Bezig met laden...", // nu met block UI gedaan
        containerFill: true,
        successAfterContainerFill: $.noop,
        extraParams: [],
        ajaxOptions: {},
        dialogOptions: {},
        openInDialog: false
    }, sendOptions);

    var ajaxOptions = {
        type: "GET",
        url: "",
        data: [],
        success: function(data, textStatus, xhr) {
            // possible TODO: maybe create dialog here to prevent rare blockUI/dialogUI-overlay bug? Must be after ajaxStop.
            if (options.containerFill && container != null)
                container.html(data);
            options.successAfterContainerFill(data, textStatus, xhr, container);
        }
    };

    //log(options);
    //log(ajaxOptions);

    if (options.formSelector) {
        var form = $(options.formSelector);

        if (!form.valid())
            return false;
        
        ajaxOptions.type = "POST";
        ajaxOptions.url = form[0].action;
        $.merge(ajaxOptions.data, form.serializeArray());
    }
    $.merge(ajaxOptions.data, [{name: options.event, value: ""}]);
    $.merge(ajaxOptions.data, options.extraParams);

    var container = null;
    if (options.containerSelector) {
        container = $(options.containerSelector);
    } else if (options.containerId) {
        // we maken een nieuwe container aan:
        container = $("<div></div").attr("id", options.containerId);
        container.appendTo(document.body);
        container.html(options.containerWaitText);
    }
    
    if (options.openInDialog && container != null) {
        // open dialog:
        container.dialog(options.dialogOptions);
    }

    if (container != null)
        ajaxOptions.context = container[0];

    if (sendOptions.url)
        ajaxOptions.url = sendOptions.url;

    // Override options with supplied extra ajaxOptions
    $.extend(ajaxOptions, options.ajaxOptions);

    // The actual ajax request:
    $.ajax(ajaxOptions);
    
    return true;
}

function log(text) {
    if (window.console && window.console.log)
        console.log(text);
}