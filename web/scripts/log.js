function log(text) {
    // avoid crash if console or console.log does not exist:
    if (window.console && window.console.log)
        console.log(text);
}