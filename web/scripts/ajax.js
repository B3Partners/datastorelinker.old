/* 
 * Needs jquery.
 * 
 */

// Global ajax settings:
$(document).ajaxStart($.blockUI);
$(document).ajaxStop($.unblockUI);
$(document).ajaxError(function(event, xhr, ajaxOptions, thrownError) {
    var errorMessage;
    if (xhr.status == 0) {
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
        close: function() {
            $(this).dialog("destroy");
            $(this).remove();
        }
    });
    
    // close any open confirmation dialogs:
    //$(".confirmationDialog").dialog("close");
});


function ajaxFormEventInto(formSelector, event, containerSelector, callback, action) {
    var form = $(formSelector).first();
    var params = {};
    if (!!event)
        params = event + "&" + form.serialize();
    if (!action)
        action = form[0].action
    $.post(action,
            params,
            function (xml) {
                $(containerSelector).first().html(xml);
                if (callback)
                    callback();
            });
    return false;
}

function ajaxActionEventInto(action, event, containerSelector, callback) {
    var url = action + "?" + event;
    $.get(url, function (xml) {
                   $(containerSelector).first().html(xml);
                   if (callback)
                       callback();
            });
    return false;
}

function log(text) {
    if (window.console && window.console.log)
        console.log(text);
}

// clone geeft "Too much recursion"-error
/*Object.prototype.clone = function() {
    var newObj = (this instanceof Array) ? [] : {};
    for (i in this) {
        if (i == "clone")
            continue;

        if (this[i] && typeof this[i] == "object") {
            newObj[i] = this[i].clone();
        } else {
            newObj[i] = this[i];
        }
    }
    return newObj;
};*/

/*Object.prototype.shallowClone = function() {
    var newObj = (this instanceof Array) ? [] : {};
    for (i in this) {
        if (i == "clone")
            continue;

        newObj[i] = this[i];
    }
    return newObj;
};*/