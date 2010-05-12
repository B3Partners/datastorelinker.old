/* 
 * Needs jquery.
 * 
 */
function ajaxFormEventInto(formSelector, event, containerSelector, callback, action) {
    var form = $(formSelector).first();
    var params = {};
    if (!!event)
        params = event + '&' + form.serialize();
    log(params);
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

function log(text) {
    if (window.console && window.console.log)
        console.log(text);
}