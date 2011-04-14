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

//$(document).ajaxSuccess(function(event, xhr, ajaxOptions) {
    /*log("ajax success");
    log(event);
    log(xhr);
    log(ajaxOptions);
    log(xhr);
    log(xhr.getAllResponseHeaders());
    log(xhr.getResponseHeader("Content-Type"));
    log(xhr.status);*/

    /*var contentType = xhr.getResponseHeader("Content-Type");
    log(contentType);
    if (!contentType || contentType !== "text/html") { // to be future-proof we should xhtml types etc. (we might want to change our content type in the future)
        return;
    }*/

    //$("<div>test</div>").dialog();
    //
    // Session timeout solution:
    //
    // Current solution is ugly. Also a bit for the user, but it works.
    // TODO: prevent fallthrough to normal success function?
    // get and store normal success handler?
    //log(xhr.responseXML);
    //log(xhr.responseText);
    /*var response = $(".login", xhr.responseXML);
    var response2 = $(".login", xhr.responseText);
    if (response.length > 0 || response2.length > 0) { // || xhr.status == 302
        log("relogin screen");
        log(response);
        log(window.location);
        window.location = webappRoot;*/
        // our session has timed out. we got a login screen

        // prevent regular success function from being called (does not seem to work)
        //xhr.abort();
        //ajaxOptions.success = $.noop;

        // show login screen in dialog:
        /*$("<div></div>").attr("id", "loginDialog").appendTo(document.body);
        $("#loginDialog").append(I18N.loginTimeout);
        $("#loginDialog").append(response);
        $("#loginDialog form").submit(function() {
            $("#loginDialog").dialog("close");
        });
        log($("#loginDialog"));
        $("#loginDialog").dialog($.extend({}, defaultDialogOptions, {
            title: I18N.login
        }));

        event.preventDefault();
        event.stopImmediatePropagation();
        event.stopPropagation();*/
        //return false;
    /*} else {
        //log("normal screen");
        //return true;
    }*/
//});

// deze code wordt serverside en clientside gebruikt voor user errors.
defaultCustomErrorCode = 1000;

$(document).ajaxError(function(event, xhr, ajaxOptions, thrownError) {
    $.unblockUI(unblockUIOptions);
    
    /*log(event);
    log(xhr);
    log(ajaxOptions);
    log(thrownError);*/
    //log(xhr.status);

    var errorMessage;
    if (xhr.status == defaultCustomErrorCode) {
        errorMessage = xhr.responseText;//thrownError + event;
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

    $("<div></div>").attr("id", "errorDialog").html(errorMessage).appendTo(document.body);
    $("#errorDialog").dialog($.extend({}, defaultDialogOptions, {
        title: I18N.error,
        buttons: {
            "Ok": function() {
                $(this).dialog("close");
            }
        }
    }));
});

function isErrorResponse(xhr) {
    return xhr.status == defaultCustomErrorCode;
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

    //log(options);
    //log(ajaxOptions);

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