debugMode = true;

// IE 8 en Firebug kunnen ook console.info/warn/error aan
function log() {
    if (debugMode) {
		var message = arguments[0];
        if (arguments.length > 1)
            message = Array.prototype.join.call(arguments, '; ');
        
        if (window.console && window.console.log) {
            console.log(message);
        } else if (window.opera && window.opera.postError) {
            window.opera.postError(message);
        }
    }
}

jQuery.fn.log = function(message) {
    if (debugMode) {
        if (window.console && window.console.log) {
            console.log("%s: %o", message, this);
        } else if (window.opera && window.opera.postError) {
            window.opera.postError(message);
        }
    }
    return this;
};