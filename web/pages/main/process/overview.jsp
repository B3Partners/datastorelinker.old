<%-- 
    Document   : processOverview
    Created on : 22-apr-2010, 19:31:42
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>
<%@include file="/pages/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        $("#processForm").validate(defaultRadioValidateOptions);

        $("#createProcess, #updateProcess, #deleteProcess").button();
        $("#executeProcess, #executeProcessPeriodically, #cancelExecuteProcessPeriodically").button();
        $("#exportToXml").button();

        $("#processOverviewContainer").layout($.extend({}, defaultLayoutOptions, {
            /*north__size: 50,
            north__minSize: 50,*/
            south__size: 100,
            south__minSize: 100
        }));

        var newUpdateProcessCommonDialogOptions = $.extend({}, defaultDialogOptions, {
            width: Math.floor($('body').width() * .70),
            height: Math.floor($('body').height() * .65),
            resize: function(event, ui) {
                $("#processContainer").layout().resizeAll();
                $("#processSteps").layout().resizeAll();
            }
        });

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
                dialogOptions: $.extend({}, newUpdateProcessCommonDialogOptions, {
                    title: I18N.newProcess
                })
            });

            return defaultButtonClick(this);
        });

        $("#updateProcess").click(function() {
            ajaxOpen({
                formSelector: "#processForm",
                event: "update",
                containerId: "processContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateProcessCommonDialogOptions, {
                    title: I18N.editProcess
                })
            });

            return defaultButtonClick(this);
        });

        $("#executeProcess").click(function() {
            if (!$("#processForm").valid())
                return defaultButtonClick(this);

            $("<div id='processContainer'><div id='processOutput'></div></div>").appendTo(document.body);

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
                dialogOptions: $.extend({}, defaultDialogOptions, {
                    title: I18N.executeProcess,
                    width: 600,
                    height: 300,
                    buttons: {
                        "<fmt:message key="cancel"/>": function() {
                            $(this).dialog("close");
                        }
                    },
                    close: function(event, ui) {
                        var intervalId = $("#processContainer").data("intervalId");
                        clearInterval(intervalId);

                        cancelProcess();

                        //$("#progressbar").progressbar("destroy"); is widget; jq ui regelt dit bij enclosing dialog.close
                        
                        $("#processContainer").removeData("jobUUID");
                        $("#processContainer").removeData("intervalId");
                        
                        defaultDialogClose(event, ui);
                    },
                    disabled: true
                })
            });

            return defaultButtonClick(this);
        });

        $("#executeProcessPeriodically").click(function() {
            ajaxOpen({
                formSelector: "#processForm",
                url: "${periodicalProcessUrl}",
                event: "executePeriodically",
                containerId: "processContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, defaultDialogOptions, {
                    title: I18N.periodicallyExecuteProcess,
                    width: 900,
                    //height: 600,
                    buttons: {
                        "<fmt:message key="cancel"/>": function() {
                            $(this).dialog("close");
                        },
                        "<fmt:message key="finish"/>": function() {
                            submitExecutePeriodicallyForm();
                        }
                    }
                })
            });

            return defaultButtonClick(this);
        });

        $("#cancelExecuteProcessPeriodically").click(function() {
            if (!$("#processForm").valid())
                return defaultButtonClick(this);

            $("<div></div>").html(I18N.cancelPeriodicallyExecuteProcessAreYouSure)
                .attr("id", "processContainer").appendTo(document.body);

            $("#processContainer").dialog($.extend({}, defaultDialogOptions, {
                title: I18N.cancelPeriodicallyExecuteProcess,
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
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
                }
            }));

            return defaultButtonClick(this);
        });

        $("#deleteProcess").click(function() {
            if (!$("#processForm").valid())
                return defaultButtonClick(this);

            $("<div></div>").html(I18N.deleteProcessAreYouSure)
                .attr("id", "processContainer").appendTo(document.body);

            $("#processContainer").dialog($.extend({}, defaultDialogOptions, {
                title: I18N.deleteProcess,
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        ajaxOpen({
                            formSelector: "#processForm",
                            event: "delete",
                            containerSelector: "#processesListContainer",
                            successAfterContainerFill: function() {
                                $("#processContainer").dialog("close");
                            }
                        });
                    }
                }
            }));

            return defaultButtonClick(this);
        });

        $("#exportToXml").click(function() {
            if (!$("#processForm").valid())
                return defaultButtonClick(this);

            var selectedProcessId = $("#processesListContainer :radio:checked").val();
            var newLocation = "${processUrl}" + "?exportToXml=&selectedProcessId=" + selectedProcessId;
            window.location.replace(newLocation);
			
            return defaultButtonClick(this);
        });
    });

    function updateProgressbar() {
        var jobUUID = $("#processContainer").data("jobUUID");
        var intervalId = $("#processContainer").data("intervalId");

        $.ajax({
            url: "${processUrl}",
            dataType: "json",
            data: [
                {name: "executionProgress", value: ""},
                {name: "jobUUID", value: jobUUID}
            ],
            success: function(data, textStatus) {
                $("#progressbar").progressbar("value", data.progress);
                if (data.progress >= 100) {
                    //log("Process finished");
                    $("#processOutput").html(data.message);
                    clearInterval(intervalId);
                    changeButtonName("#processContainer", "Annuleren", "Voltooien");
                }
            },
            global: false // prevent ajaxStart and ajaxStop to be called (with blockUI in them)
        });
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

<div id="processOverviewContainer" style="height: 100%">
    <stripes:form id="processForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
        <div id="processHeader" class="ui-layout-north">
            <h1><fmt:message key="main.overview"/></h1>
        </div>

        <div id="processesListContainer" class="ui-layout-center radioList ui-widget-content ui-corner-all">
            <%@include file="/pages/main/process/list.jsp" %>
        </div>

        <div id="buttonPanel" class="ui-layout-south">
            <div>
                <stripes:button id="createProcess" name="create"/>
                <stripes:button id="updateProcess" name="update"/>
                <stripes:button id="deleteProcess" name="delete"/>
            </div>
            <div style="margin-top: 5px">
                <stripes:button id="executeProcess" name="execute"/>
                <stripes:button id="executeProcessPeriodically" name="executePeriodically"/>
                <stripes:button id="cancelExecuteProcessPeriodically" name="cancelExecutePeriodically"/>
                <stripes:button id="exportToXml" name="exportToXml" style="float: right;"/>
            </div>
        </div>

    </stripes:form>
</div>