<%-- 
    Document   : processOverview
    Created on : 22-apr-2010, 19:31:42
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    
    // used by the list.jsp, which reloads and resets this if it is there
    var updateInterval = null;
            
    function recalculateNewUpdateProcessCommonDialogOptions() {
        return $.extend({}, defaultDialogOptions, {
            width: calculateDialogWidth(70, 600, 1200),
            height: calculateDialogHeight(70, 525),
            resize: function(event, ui) {
                if (layouts && layouts.processContainer)
                    layouts.processContainer.resizeAll();
                if (layouts && layouts.processSteps)
                    layouts.processSteps.resizeAll();
            },
            close: function(event, ui) {
                if (window.layouts) {
                    // volgorde is belangrijk! van binnen naar buiten destroyen
                    layouts.tabs.destroy();
                    layouts.tabs = null;
                    
                    layouts.inputTabs.destroy();
                    layouts.inputTabs = null;
                    
                    layouts.processSteps.destroy();
                    layouts.processSteps = null;
                    
                    layouts.processContainer.destroy();
                    layouts.processContainer = null;
                }
                defaultDialogClose(event, ui);
            }
        });
    }
    
    $(document).ready(function() {
        $("#processForm").validate(defaultRadioValidateOptions);

        $("#createProcess, #updateProcess, #deleteProcess, #processDiagram").button();
        $("#executeProcess, #executeProcessPeriodically, #cancelExecuteProcessPeriodically").button();
        $("#exportToXml").button();

        $("#processOverviewContainer").layout($.extend({}, defaultLayoutOptions, {
            /*north__size: 50,
            north__minSize: 50,*/
            south__size: 75,
            south__minSize: 75
        }));

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
                dialogOptions: $.extend({}, recalculateNewUpdateProcessCommonDialogOptions(), {
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
                dialogOptions: $.extend({}, recalculateNewUpdateProcessCommonDialogOptions(), {
                    title: I18N.editProcess
                })
            });

            return defaultButtonClick(this);
        });

        $("#executeProcess").click(function() {
            if (!isFormValidAndContainsInput("#processForm"))
                return defaultButtonClick(this);

            $("<div id='processContainer'></div>").css("height", "100%").appendTo(document.body);

            $("#processContainer").append($("<div></div>")
                .attr("id", "executeNorth")
            );
            $("<div></div>")
                .attr("id", "progressbar")
                .css("margin", "5px 5px")
                .append($("<span></span>").addClass("progressbarLabel"))
                .progressbar({
                    value: 0,
                    change: function(event, ui) {
                        var newValue = $(this).progressbar('option', 'value');
                        $('.progressbarLabel', this).text(newValue + '%');
                    }
                })
                .appendTo("#executeNorth");

            $("#processContainer").append("<div id='processOutput' style='overflow: auto'></div>");
            $("#processContainer").append("<div id='executeSouth'></div>");

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
                        $("#processOutput").append(data.message);
                    }

                    defaultExecuteLayoutOptions = $.extend({}, defaultLayoutOptions, {
                        //north__size: 35
                    });
                    createDefaultVerticalLayout($("#processContainer"), defaultExecuteLayoutOptions);

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
                        if ($("#processContainer").data("isStopped")) {
                            defaultDialogClose(event, ui);
                        } else {
                            var jobUUID = $("#processContainer").data("jobUUID");
                            var intervalId = $("#processContainer").data("intervalId");
                            clearInterval(intervalId);

                            $.getJSON(
                                "${processUrl}", [
                                    {name: "cancel", value: ""},
                                    {name: "jobUUID", value: jobUUID}
                                ],
                                function(data, textStatus) {
                                    if (data.success) {
                                        //$("#progressbar").progressbar("destroy"); is widget; jq ui regelt dit bij enclosing dialog.close
                                        defaultDialogClose(event, ui);
                                    } else {
                                        stopProcess(data.message);
                                    }
                                }
                            );
                        }
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
            if (!isFormValidAndContainsInput("#processForm"))
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
            if (!isFormValidAndContainsInput("#processForm"))
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
            if (!isFormValidAndContainsInput("#processForm"))
                return defaultButtonClick(this);

            var selectedProcessId = $("#processesListContainer :radio:checked").val();
            var newLocation = "${processUrl}" + "?exportToXml=&selectedProcessId=" + selectedProcessId;
            window.location.replace(newLocation);
			
            return defaultButtonClick(this);
        });
        
        $("#processDiagram").click(function() {
            window.open("${processUrl}?processDiagram=true");
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
                if (data.fatalError) {
                    stopProcess(data.fatalError);
                } else {
                    $("#progressbar").progressbar("value", data.progress);
                    if (data.progress >= 100) {
                        stopProcess(data.message);
                    }
                }
            },
            global: false // prevent ajaxStart and ajaxStop to be called (with blockUI in them)
        });
    }

    function stopProcess(message) {
        clearInterval($("#processContainer").data("intervalId"));
        $("#processOutput").html(message);
        //$("#processContainer").layout(defaultExecuteLayoutOptions).initContent("center");
        $("#processContainer").data("isStopped", true);
        $("#processContainer").dialog("option", "buttons", {
            "<fmt:message key="finish"/>": function() {
                $(this).dialog("close");
            }
        });

        // allow server to finish its stuff, then update all statuses:
        setTimeout(
            function() {
                ajaxOpen({
                    formSelector: "#processForm",
                    event: "list",
                    containerSelector: "#processesListContainer",
                    ajaxOptions: {
                        global: false
                    }
                });
            },
            500
        );
    }

</script>

<div id="processOverviewContainer" style="height: 100%">
    <stripes:form id="processForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
        <stripes:wizard-fields/>
        <div id="processHeader" class="ui-layout-north">
            <h1><fmt:message key="main.overview"/></h1><%-- line-height is fix for IE7 --%>
            <p><fmt:message key="keys.nameexplain"/></p>
        </div>

        <div id="processesListContainer" class="mandatory-form-input ui-layout-center radioList ui-widget-content ui-corner-all">
            <%@include file="/WEB-INF/jsp/main/process/list.jsp" %>
        </div>

        <div id="buttonPanel" class="ui-layout-south">
            <div>
                <stripes:button id="createProcess" name="create"/>
                <stripes:button id="updateProcess" name="update"/>
                <stripes:button id="deleteProcess" name="delete"/>
                <stripes:button  id="processDiagram" name="processDiagram" style="float:right;"/>
            </div>
            <div style="margin-top: 5px">
                <!--
                <stripes:button id="exportToXml" name="exportToXml" style="float: right;"/>
                -->
                <stripes:button id="executeProcess" name="execute"/>
                <stripes:button id="executeProcessPeriodically" name="executePeriodically"/>
                <stripes:button id="cancelExecuteProcessPeriodically" name="cancelExecutePeriodically"/>
            </div>
        </div>

    </stripes:form>
</div>