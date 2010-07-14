<%-- 
    Document   : processOverview
    Created on : 22-apr-2010, 19:31:42
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="processUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction"/>
<stripes:url var="periodicalProcessUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.PeriodicalProcessAction"/>

<style type="text/css">
    .ui-progressbar { position: relative; }
    .progressbarLabel { position: absolute; width: 100%; text-align: center; line-height: 1.9em; color: silver; font-weight: bold; }
</style>

<script type="text/javascript">
    $(function() {
        $("#processForm").validate(defaultValidateOptions);

        $("#createProcess, #updateProcess, #deleteProcess").button();
        $("#executeProcess, #executeProcessPeriodically, #cancelExecuteProcessPeriodically").button();

        $("#createProcess").click(function() {
            // TODO: wacht op een volgende versie van jquery UI waar http://dev.jqueryui.com/ticket/5295
            // in is geïntegreerd.
            // Of bouw eigen jquery UI met de patch uit de link.
            // Of integreer onderstaande korte patch bij elke knop.
            //
            //$(this).removeClass("ui-state-active ui-state-hover ui-state-focus");
            ajaxOpen({
                url: "${processUrl}",
                event: "create",
                containerId: "processContainer",
                openInDialog: true,
                dialogOptions: {
                    title: "Nieuw Proces...", // TODO: localization
                    width: 900,
                    height: 600,
                    modal: true,
                    close: function(event, ui) {
                        $("#createUpdateProcessForm").formwizard("destroy");
                        defaultDialogClose(event, ui);
                    }
                }
            });
        });

        $("#updateProcess").click(function() {
            ajaxOpen({
                formSelector: "#processForm",
                event: "update",
                containerId: "processContainer",
                openInDialog: true,
                dialogOptions: {
                    title: "Bewerk Proces...", // TODO: localization
                    width: 900,
                    height: 600,
                    modal: true,
                    close: function(event, ui) {
                        $("#createUpdateProcessForm").formwizard("destroy");
                        defaultDialogClose(event, ui);
                    }
                }
            });
        });

        $("#executeProcess").click(function() {
            if (!$("#processForm").valid())
                return;

            $("<div id='processContainer'><div id='processOutput'>Proces aan het uitvoeren...</div></div>").appendTo(document.body);

            var progressbar = $("<div></div>")
                .attr("id", "progressbar")
                .append($("<span></span>").addClass("progressbarLabel"));
                
            $("#processContainer").prepend(progressbar);
            $("#progressbar").progressbar({
                value: 0,
                change: function(event, ui) {
                    var newValue = $(this).progressbar('option', 'value');
                    $('.progressbarLabel', this).text(newValue + '%');
                }
            });

            $("#processContainer").data("jobUUID", null);
            $("#processContainer").data("intervalId", 0);
            
            ajaxOpen({
                formSelector: "#processForm",
                event: "execute",
                containerSelector: "#processContainer",
                containerFill: false,
                successAfterContainerFill: function(data, textStatus, xhr) {
                    if (data.success) {
                        var jobUUID = data.message;
                        $("#processContainer").data("jobUUID", jobUUID);
                        var intervalId = setInterval("updateProgressbar()", 1000);
                        $("#processContainer").data("intervalId", intervalId);
                    } else {
                        $("#processOutput").html("Proces kon niet gestart worden:");
                        $("#processOutput").append("<p>" + data.message + "</p>");
                    }
                    $("#processContainer").dialog("option", "disabled", false);
                },
                openInDialog: true,
                dialogOptions: {
                    title: "Proces uitvoeren...", // TODO: localization
                    width: 900,
                    height: 600,
                    modal: true,
                    buttons: {
                        "Annuleren": function() { // TODO: localize
                            $(this).dialog("close");
                        }
                    },
                    close: function(event, ui) {
                        var intervalId = $("#processContainer").data("intervalId");
                        clearInterval(intervalId);

                        cancelProcess();

                        $("#progressbar").progressbar("destroy");
                        
                        $("#processContainer").removeData("jobUUID");
                        $("#processContainer").removeData("intervalId");
                        
                        defaultDialogClose(event, ui);
                    },
                    disabled: true
                }
            });
        });

        $("#executeProcessPeriodically").click(function() {
            ajaxOpen({
                formSelector: "#processForm",
                url: "${periodicalProcessUrl}",
                event: "executePeriodically",
                containerId: "processContainer",
                openInDialog: true,
                dialogOptions: {
                    title: "Voer proces periodiek uit...", // TODO: localization
                    width: 900,
                    height: 600,
                    modal: true,
                    close: defaultDialogClose,
                    buttons: {
                        "Annuleren": function() {
                            $(this).dialog("close");
                        },
                        "Voltooien": function() {
                            submitExecutePeriodicallyForm();
                        }
                    }
                }
            });
        });

        $("#cancelExecuteProcessPeriodically").click(function() {
            if (!$("#processForm").valid())
                return;

            $("<div id='processContainer'>Weet u zeker dat u dit proces niet meer periodiek wilt uitvoeren?</div>").appendTo(document.body);

            $("#processContainer").dialog({
                title: "Proces periodiek uitvoeren annuleren...", // TODO: localization
                modal: true,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxOpen({
                            formSelector: "#processForm",
                            url: "${periodicalProcessUrl}",
                            event: "cancelExecutePeriodically",
                            containerSelector: "#processesListContainer",
                            successAfterContainerFill: function() {
                                $("#processContainer").dialog("close");
                            }
                        });
                     }
                },
                close: defaultDialogClose
            });
        });

        $("#deleteProcess").click(function() {//TODO: localize
            if (!$("#processForm").valid())
                return;

            $("<div id='processContainer'>Weet u zeker dat u dit proces wilt verwijderen?</div>").appendTo(document.body);

            $("#processContainer").dialog({
                title: "Proces verwijderen...", // TODO: localization
                modal: true,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxOpen({
                            formSelector: "#processForm",
                            event: "delete",
                            containerSelector: "#processesListContainer",
                            successAfterContainerFill: function() {
                                $("#processContainer").dialog("close");
                            }
                        });
                    }
                },
                close: defaultDialogClose
            });
        });
    });

    function updateProgressbar() {
        var jobUUID = $("#processContainer").data("jobUUID");
        var intervalId = $("#processContainer").data("intervalId");

        $.getJSON(
            "${processUrl}", [
                {name: "executionProgress", value: ""},
                {name: "jobUUID", value: jobUUID}
            ],
            function(data, textStatus) {
                $("#progressbar").progressbar("value", data.progress);
                if (data.progress >= 100) {
                    log("Process finished");
                    $("#processOutput").html(data.message);
                    clearInterval(intervalId);
                    changeButtonName("#processContainer", "Annuleren", "Voltooien");
                }
            }
        );
    }

    function changeButtonName(dialogSelector, fromName, toName) {
        $(dialogSelector).parent().find(".ui-dialog-buttonpane .ui-button:first .ui-button-text").html(toName);
    }

    function cancelProcess() {
        var jobUUID = $("#processContainer").data("jobUUID");

        $.getJSON(
            "${processUrl}", [
                {name: "cancel", value: ""},
                {name: "jobUUID", value: jobUUID}
            ],
            function(data, textStatus) {

            }
        );
    }

</script>


<stripes:form id="processForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <stripes:label for="main.process.overview.text.overview"/>:

    <div id="processesListContainer">
        <%@include file="/pages/main/process/list.jsp" %>
    </div>

    <div id="buttonPanel">
        <stripes:button id="createProcess" name="create"/>
        <stripes:button id="updateProcess" name="update"/>
        <stripes:button id="deleteProcess" name="delete"/>
        <stripes:button id="executeProcess" name="execute"/>
        <stripes:button id="executeProcessPeriodically" name="executePeriodically"/>
        <stripes:button id="cancelExecuteProcessPeriodically" name="cancelExecutePeriodically"/>
    </div>

</stripes:form>
