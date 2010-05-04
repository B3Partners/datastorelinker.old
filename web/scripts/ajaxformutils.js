/* 
 * Needs jquery.
 * 
 */
function ajaxFormEventInto(formSelector, event, containerSelector, callback) {
    form = $(formSelector).first();
    params = {};
    if (event != null) params = event + '&' + form.serialize();
    $.post(form[0].action,
            params,
            function (xml) {
                $(containerSelector).first().html(xml);
                if (callback)
                    callback();
            });
    return false;
}

function log(text) {
    if (window.console)
        console.log(text);
}