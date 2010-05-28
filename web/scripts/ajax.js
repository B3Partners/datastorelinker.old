/*
 * Needs jquery.
 *
 */

// Global ajax settings:
$.ajaxSetup({
    cache: false
});
//$(document).ajaxStart($.blockUI);
//$(document).ajaxStop($.unblockUI);
$(document).ajaxError(function(event, xhr, ajaxOptions, thrownError) {
    log(event);
    log(xhr);
    log(ajaxOptions);
    log(thrownError);
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

    $("<div id='errorDialog'>" + errorMessage + "</div>").appendTo(document.body);
    $("#errorDialog").dialog({
        title: "Fout!",
        modal: true,
        buttons: {
            "Ok": function() {
                $("#errorDialog").dialog("close");
            }
        },
        close: defaultDialogClose
    });

    // close any open confirmation dialogs:
    //$(".confirmationDialog").dialog("close");
});


function ajaxFormEventInto(formSelector, event, containerSelector, callback, action, extraParams, dataType) {
    var form = $(formSelector).first();
    var params = "";
    if (!!event)
        params = event + "&";
    params += form.serialize();
    if (!!extraParams) {
        for (var key in extraParams) {
            var value = extraParams[key];
            if (params.length > 0)
                params += "&";
            params += key;
            if (value)
                params += "=" + value;
        }
    }
    //log(extraParams);
    //log(params);
    if (!action)
        action = form[0].action
    //var oldHtml = $(containerSelector).first().html();
    //if (containerSelector)
    //    $(containerSelector).first().html("Bezig met laden...");
    $.post(action,
            params,
            function (data, textStatus, xhr) {
                log(textStatus);
                log(xhr);
                if (containerSelector)
                    $(containerSelector).first().html(data);
                if (callback)
                    callback(data, textStatus, xhr);
            },
            dataType
    );
    return false;
}

function ajaxActionEventInto(action, event, containerSelector, callback) {
    if (containerSelector)
        $(containerSelector).first().html("Bezig met laden...");
    var url = action + "?" + event;
    $.get(url,
        function (data, textStatus, xhr) {
            if (containerSelector)
                $(containerSelector).first().html(data);
            if (callback)
                callback(data, textStatus, xhr);
        }
    );
    return false;
}

function log(text) {
    if (window.console && window.console.log)
        console.log(text);
}