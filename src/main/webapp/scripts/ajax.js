/*
 * Needs jquery.
 *
 */

$.blockUI.defaults.css = {}; 

var blockUIOptions = {
    message: "<img src='" + webappRoot + "/images/spinner_big.gif' />",
    theme: false,
    baseZ: 10000,
    css: {
        padding:        0,
        margin:         0,
        width:          '30%',
        top:            '40%',
        left:           '35%',
        textAlign:      'center',
        color:          '#000',
        //border:         '3px solid #aaa',
        //backgroundColor:'#fff',
        cursor:         'wait'
    },
    overlayCSS:  {
        backgroundColor: '#fff',
        opacity:         0.8
    }
    //showOverlay: false
}
var unblockUIOptions = {
    // minder mooi, maar voorkomt z-index issues met jquery ui modal dialog;
    // die zijn er nog steeds soms overigens.
    // veroorzaken pop-unders, waardoor bepaalde ui niet gedisabled is.
    // (meestal vrij kort niet gedisabled; namelijk gedurende een request)
    fadeOut: 0
}

// Global ajax settings:
$.ajaxSetup({
    cache: false
});

$(document).ajaxStart(function() {
    $.blockUI(blockUIOptions);
});

$(document).ajaxStop(function() {
    $.unblockUI(unblockUIOptions);
});

$(document).ajaxError(function(event, xhr, ajaxOptions, thrownError) {
    $.unblockUI(unblockUIOptions);
    
    if ("abort" !== thrownError)
        handleError(xhr, "", thrownError);
});

// for debugging purposes:
$(document).ajaxSend(function(event, jqxhr, settings) {
});

function handleError(xhr, textStatus, thrownError) {
    var errorMessage;
    if (xhr.status == 500) {
        try {
            openJSONErrorDialog($.parseJSON(xhr.responseText));
            return;
        } catch (ex) {
            errorMessage = xhr.responseText;//thrownError + event;
        }
    } else if (thrownError == "parsererror") {
        errorMessage = I18N.errorParsing;
    } else if (thrownError == "timeout") {
        errorMessage = I18N.errorFetching;
    } else if (thrownError == "abort") {
        errorMessage = I18N.errorClosed;
    } else if (xhr.status == 0) {
        errorMessage = I18N.errorOffline;
    } else if (xhr.status == 404) {
        errorMessage = I18N.errorNotFound;
    } else {
        errorMessage = I18N.errorUnknown;
    }
    openSimpleErrorDialog(errorMessage);
}

function openSimpleErrorDialog(errorMessage) {
    $("<div></div>").attr("id", "errorDialog").html(errorMessage).appendTo(document.body);
    $("#errorDialog").dialog($.extend({}, defaultDialogOptions, {
        title: I18N.error,
        buttons: {
            "Ok": function() {
                $(this).dialog("close");
            }
        }
    }));
}

function openJSONErrorDialog(data) {
    $("<div id='errorDialog'>" + data.message + "</div>").appendTo(document.body);
    $("#errorDialog").dialog({
        title: data.title,
        modal: true,
        buttons: {
            "Ok": function() {
                $("#errorDialog").dialog("close");
            }
        },
        close: defaultDialogClose
    });
}

defaultCheckInputPresentSelector = ".mandatory-form-input";

// Use this function for all your ajax calls
function ajaxOpen(sendOptions) {
    var options = $.extend({
        url: "", // Sends ajax request to this url. The send type will be GET. It will be the form's type if the formSelector option is defined (see below).
        formSelector: "", // Ajax-submit the form. The type will be the form's type. Default url is the form's own url. Url can be changed by url-option above.
        event: "", // Event to call server-side. Translated to data parameters.
        containerFill: true, // Fill the container with the response data
        containerSelector: "", // Selects an already created container.
        containerId: "", // Creates a container with the given id. It will be attached to the body element.
        containerWaitText: "", //Bezig met laden...", // nu met block UI gedaan
        successAfterContainerFill: $.noop, // This function will be called if the ajax request was successful, after the container is filled with the response (if containerFill is set to true). If containerFill is set to false, this will still be called.
        extraParams: [], // Extra submit data as a array of name/value pairs. E.g.: [{name: "keyName1", value: "myValue1"},{name: "keyName2", value: "myValue2"}]
        ajaxOptions: {}, // Extra regular jQuery ajax options
        openInDialog: false, // Open result in a dialog? Dialog source will be the container (id or selector as explained above.)
        dialogOptions: {}, // JQuery UI dialog Options.
        checkInputPresentSelector: defaultCheckInputPresentSelector // Descendants of this selector inside the form (if formSelector is defined) will be checked for presence of input elements. If no input elements are present, the form (if any) will not validate. If no element with this class is found within the form, the form will not fail to validate because of a lack of input elements.
    }, sendOptions);

    var ajaxOptions = {
        type: "GET",
        url: "",
        data: [],
        success: function(data, textStatus, xhr) {
            // possible TODO: maybe create dialog here to prevent rare blockUI/dialogUI-overlay bug? Must be after ajaxStop.
            if (options.containerFill && container != null) {
                container.html(data);
                /*if (options.openInDialog) {
                    container.dialog(options.dialogOptions);
                }*/
            }
            options.successAfterContainerFill(data, textStatus, xhr, container);
        }
    };

    if (options.formSelector) {
        var form = $(options.formSelector);

        if (!isFormValidAndContainsInput(options.formSelector, options.checkInputPresentSelector))
            return false;
        
        ajaxOptions.type = form[0].method;
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

    if (container != null) {
        //container.css("overflow", "auto");
        ajaxOptions.context = container[0];
    }

    if (sendOptions.url)
        ajaxOptions.url = sendOptions.url;

    // Override options with supplied extra ajaxOptions
    $.extend(ajaxOptions, options.ajaxOptions);

    // The actual ajax request:
    $.ajax(ajaxOptions);
    
    return true;
}

function isFormValidAndContainsInput(formSelector, checkInputPresentSelector) {
    return $(formSelector).valid() && containsInput(formSelector, checkInputPresentSelector);
}

function containsInput(formSelector, checkInputPresentSelector) {
    if (!checkInputPresentSelector)
        checkInputPresentSelector = defaultCheckInputPresentSelector;

    var inputParent = $(formSelector).find(checkInputPresentSelector);
    if (inputParent.length == 0)
        return true; // we have not marked any element to contain input elements
    return inputParent.find("input").length > 0;
}