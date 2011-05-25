/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


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

    // buttonset bug fix IE 7:
    $(".ui-buttonset .ui-button").live("click", function(event) {
        $("#" + $(this).attr("for")).prop("checked", true);
    });
    
    $(window).resize(function() {
        $(".ui-dialog-content:visible").each(function() {
            var dialog = $(this).data("dialog");
            //log(dialog.options);
            dialog.option("position", dialog.options.position);
        });
    });

});

defaultButtonClick = function(button) {
    // als focus blijft is het een beetje lelijk
    $(button).removeClass("ui-state-hover ui-state-focus");
    return false;
}

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

defaultRadioValidateOptions = $.extend({}, defaultValidateOptions, {
    errorPlacement: function(error, element) {
        var container = element.parents("form:first").parent("div");
        error.appendTo(container.find(".ui-layout-north:first"));
        container.layout().resizeAll();
    },
    success: function(label) {
        var container = label.parents("form:first").parent("div");
        label.remove();
        container.layout().resizeAll();
    }
});

defaultFormWizardValidateOptions = $.extend({}, defaultValidateOptions, {
    errorPlacement: function(error, element) {
        if (error.length > 0 && error.text() != "") {
            element.parents(".ui-formwizard-content").children().first().append(error);
            var layoutCenter = element.parents(".ui-layout-center").first();
            var layoutElement = layoutCenter.parents(":not(form)").first();
            layoutElement.layout().resizeAll();
        }
    },
    success: function(label) {
        if (label.length > 0 && label.parent().length > 0) {
            var layoutCenter = label.parents(".ui-layout-center").first();
            var layoutElement = layoutCenter.parents(":not(form)").first();
            label.remove();
            layoutElement.layout().resizeAll();
        }
    }
});

defaultLayoutOptions = {
    resizable: false,
    closable: false/*,
    resizeWithWindowDelay: 300,
    resizeWithWindowMaxDelay: 1000,
    zIndex: "auto", // does not work, must be a number
    */
};

defaultDialogLayoutOptions = $.extend({}, defaultLayoutOptions, {
    resizeWithWindow: false
});

defaultDialogOptions = {
    modal: true,
    close: defaultDialogClose/*,
    show: "slide",
    hide: "slide"*/
};

defaultScrollToDuration = 1000
defaultScrollToOptions = {
    easing: "easeOutBounce"
};

$.fx.off = true;
formWizardConfig = {
/*    inDuration: 1,
    outDuration: 1,
*/    
    historyEnabled : false,
    formPluginEnabled : true,
    validationEnabled : true,
    validationOptions: defaultFormWizardValidateOptions,
    //focusFirstInput : true,
    textNext : I18N.next,
    textBack : I18N.previous,
    textSubmit : I18N.finish
}

function formWizardStep(data) {
    // Dit is om ervoor te zorgen dat de formWizard plugin goed samenwerkt met buttonset van jQuery UI.
    // Dit doet het niet automatisch.
    $("#" + data.currentStep + " .ui-buttonset").buttonset("enable");
}

function calculateDialogWidth(percentageOfBodyWidth, minWidth, maxWidth) {
    return _calculateDialogSize(percentageOfBodyWidth, minWidth, maxWidth, $("body").width());
}

function calculateDialogHeight(percentageOfBodyHeight, minHeight, maxHeight) {
    return _calculateDialogSize(percentageOfBodyHeight, minHeight, maxHeight, $("body").height());
}

function _calculateDialogSize(percentage, minSize, maxSize, bodySize) {
    var size = Math.floor(bodySize * percentage / 100.0);
    if (!!minSize) {
        if (size < minSize) {
            if (minSize < bodySize) {
                size = minSize;
            } else {
                size = bodySize;
            }
        }
    }
    if (!!maxSize) {
        if (size > maxSize)
            size = maxSize;
    }
    if (size > bodySize) {
        size = bodySize;
    }
    return size;
}

;(function($) {
    $.fn.valign = function() {
        return this.each(function() {
            var height = $(this).height();
            var parentHeight = $(this).parent().height();
            var marginTop = Math.ceil((parentHeight - height) / 2);
            $(this).css("margin-top", marginTop);
        });
    };
    
    $.fn.hvalign = function() {
        return this.each(function() {
            $(this).valign().css("text-align", "center");
        });
    }
})(jQuery);
