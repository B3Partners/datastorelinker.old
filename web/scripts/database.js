function testConnection(connectionSuccessAjaxOpenOptions) {
    var formSelector = connectionSuccessAjaxOpenOptions.formSelector;
    if (!$(formSelector).valid())
        return;

    ajaxOpen({
        formSelector: formSelector,
        event: "testConnection",
        successAfterContainerFill: function(data, textStatus, xhr) {
            if (data.success) {
                ajaxOpen(connectionSuccessAjaxOpenOptions);
            } else {
                openErrorDialog(data);
            }
        }
    });
}

function openErrorDialog(data) {
    $("<div id='errorDialog'>" + data.message + "</div>").appendTo(document.body);
    $("#errorDialog").dialog({
        title: data.title,
        modal: true,
        buttons: {
            "Ok": function() {
                $("#errorDialog").dialog("close");
            }
        },
        close: defaultDialogClose
    });
}
