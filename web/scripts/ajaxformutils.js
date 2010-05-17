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
        if (i == 'clone')
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
        if (i == 'clone')
            continue;

        newObj[i] = this[i];
    }
    return newObj;
};*/