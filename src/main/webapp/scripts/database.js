function testConnection(connectionSuccessAjaxOpenOptions) {
    var formSelector = connectionSuccessAjaxOpenOptions.formSelector;
    if (!$(formSelector).valid())
        return;

    ajaxOpen({
        formSelector: formSelector,
        event: "testConnection",
        successAfterContainerFill: function(data, textStatus, xhr) {
            ajaxOpen(connectionSuccessAjaxOpenOptions);
        }
    });
}
