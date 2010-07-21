<%-- 
    Document   : create
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="inputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>
<stripes:url var="outputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.OutputAction"/>
<stripes:url var="processUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction"/>

<script type="text/javascript">
    function initActionsList() {
        var actionsList = ${actionBean.actionsList};
        log(actionsList);
        setActionsList(actionsList);
        fillActionsList(actionsList, "#actionsOverviewContainer", "${contextPath}", actionsPlaceholder);
    }

    function setActionsList(actionsList) {
        //log("setting actionsList in dom metadata:");
        var actionsListObject = {actionsList: actionsList};
        //log(actionsListObject);
        $("#actionsListMetadata").data("actionsList", actionsListObject);
    }

    function getActionsList() {
        //log("getting actionsList from dom metadata:");
        var metadata = $("#actionsListMetadata").data("actionsList");
        //log(metadata);
        if (!metadata || !metadata.actionsList)
            return [];
        else
            return metadata.actionsList;
    }

    $(document).ready(function() {
        $("#createProcessBackButton, #createProcessNextButton").button();

        $("#createInputDB, #createInputFile, #updateInput, #deleteInput").button();
        $("#createOutput, #updateOutput, #deleteOutput").button();

        initActionsList();
        
        $("#createUpdateProcessForm").bind("step_shown", function(event, data) {
            formWizardStep(data);

            $("#processContainer").layout(defaultDialogLayoutOptions);
            $("#processSteps").layout(defaultDialogLayoutOptions).destroy();
            
            if (data.previousStep)
                $("#" + data.previousStep).removeClass("ui-layout-center");
            $("#" + data.currentStep).addClass("ui-layout-center");

            $("#processSteps").layout(defaultDialogLayoutOptions).initContent("center");

            // layout plugin messes up z-indices; sets them to 1
            var topZIndexCss = { "z-index": "auto" };
            $("#processContainer, #processSteps, #inputContainer .wizardButtonsArea").css(topZIndexCss);
            $("#" + data.currentStep).css(topZIndexCss);

            if (data.currentStep === "Overzicht") {
                var inputText = $("#inputListContainer .ui-state-active .ui-button-text").html();
                $("#inputOverviewContainer").html(inputText);
                var outputText = $("#outputListContainer .ui-state-active .ui-button-text").html();
                $("#outputOverviewContainer").html(outputText);
            }
        });

        $("#createUpdateProcessForm").formwizard(
            // form wizard settings
            $.extend({}, formWizardConfig, {
                formOptions: {
                    beforeSend: function() {
                        var actionsListJson = JSON.stringify(getActionsList());

                        ajaxOpen({
                            formSelector: "#createUpdateProcessForm",
                            event: "createComplete",
                            containerSelector: "#processesListContainer",
                            extraParams: [{
                                name: "actionsList",
                                value: actionsListJson
                            }],
                            successAfterContainerFill: function() {
                                $("#processContainer").dialog("close");
                            }
                        });
                        // prevent regular ajax submit:
                        return false;
                    }
                }
            })
        );

        var newUpdateInputCommonDialogOptions = $.extend({}, defaultDialogOptions, {
            width: Math.floor($('body').width() * .65),
            height: Math.floor($('body').height() * .60),
            resize: function(event, ui) {
                $("#inputContainer").layout().resizeAll();
                if ($("#inputSteps").length != 0) // it exists
                    $("#inputSteps").layout().resizeAll();
            },
            close: function(event, ui) {
                $("#uploader").uiloadDestroy();
                defaultDialogClose(event, ui);
            }
        });

        var newUpdateOutputCommonDialogOptions = $.extend({}, defaultDialogOptions, {
            width: 550,
            height: 400,
            buttons: { // TODO: localize button name:
                "Voltooien" : function() {
                    testConnection({
                        url: "${outputUrl}",
                        formSelector: "#postgisForm",
                        event: "createComplete",
                        containerSelector: "#outputListContainer",
                        successAfterContainerFill: function() {
                            $("#outputContainer").dialog("close");
                        }
                    });
                }
            }
        });

        $("#createInputDB").click(function() {
            ajaxOpen({
                url: "${inputUrl}",
                event: "createDatabaseInput",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateInputCommonDialogOptions, {
                    title: "Nieuwe Database Invoer..." // TODO: localization
                })
            });

            return false;
        });

        $("#createInputFile").click(function() {
            ajaxOpen({
                url: "${inputUrl}",
                event: "createFileInput",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateInputCommonDialogOptions, {
                    title: "Nieuwe Bestand Invoer..." // TODO: localization
                })
            });

            return false;
        });

        $("#updateInput").click(function() {
            ajaxOpen({
                url: "${inputUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "update",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateInputCommonDialogOptions, {
                    title: "Bewerk Invoer..." // TODO: localization
                })
            });

            return false;
        });

        $("#deleteInput").click(function() {//TODO: localize
            if (!$("#createUpdateProcessForm").valid())
                return false;

            $("<div id='inputContainer' class='confirmationDialog'>Weet u zeker dat u deze invoer wilt verwijderen? Alle processen die deze invoer gebruiken zullen ook worden verwijderd.</div>").appendTo(document.body);

            $("#inputContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "Invoer verwijderen...", // TODO: localization
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        $.blockUI(blockUIOptions);
                        ajaxOpen({
                            url: "${inputUrl}",
                            formSelector: "#createUpdateProcessForm",
                            event: "delete",
                            containerSelector: "#inputListContainer",
                            ajaxOptions: {globals: false}, // prevent blockUI being called 2 times. Called manually.
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${processUrl}",
                                    event: "list",
                                    containerSelector: "#processesListContainer",
                                    ajaxOptions: {globals: false},
                                    successAfterContainerFill: function() {
                                        $("#inputContainer").dialog("close");
                                        $.unblockUI(unblockUIOptions);
                                    }
                                });
                            }
                        });
                    }
                }
            }));

            return false;
        });

        $("#createOutput").click(function() {
            ajaxOpen({
                url: "${outputUrl}",
                event: "create",
                containerId: "outputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateOutputCommonDialogOptions, {
                    title: "Nieuwe Uitvoer Database..." // TODO: localization
                })
            });

            return false;
        })

        $("#updateOutput").click(function() {
            ajaxOpen({
                url: "${outputUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "update",
                containerId: "outputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateOutputCommonDialogOptions, {
                    title: "Bewerk Uitvoer Database..." // TODO: localization
                })
            });

            return false;
        })

        $("#deleteOutput").click(function() {//TODO: localize
            if (!$("#createUpdateProcessForm").valid())
                return false;

            $("<div id='outputContainer'>Weet u zeker dat u deze uitvoer wilt verwijderen? Alle processen die deze uitvoer gebruiken zullen ook worden verwijderd.</div>").appendTo($(document.body));

            $("#outputContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "Uitvoer verwijderen...", // TODO: localization
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxOpen({
                            url: "${outputUrl}",
                            formSelector: "#createUpdateProcessForm",
                            event: "delete",
                            containerSelector: "#outputListContainer",
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${processUrl}",
                                    event: "list",
                                    containerSelector: "#processesListContainer",
                                    successAfterContainerFill: function() {
                                        $("#outputContainer").dialog("close");
                                    }
                                });
                            }
                        });
                    }
                }
            }));

            return false;
        });
    });

</script>

<div id="actionsListMetadata"></div>

<stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <!-- wizard-fields nodig voor bewerken van een proces: selectedProcessId wordt dan meegenomen -->
    <stripes:wizard-fields/>
    <div id="processSteps" class="ui-layout-center">
        <div id="SelecteerInvoer" class="step ui-layout-center">
            <h1>Selecteer bestand- of database-invoer:</h1>
            <div id="inputListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
                <%@include file="/pages/main/input/list.jsp" %>
            </div>
            <div class="crudButtonsArea">
                <stripes:button id="createInputDB" name="createInputDB"/>
                <stripes:button id="createInputFile" name="createInputFile"/>
                <stripes:button id="updateInput" name="update"/>
                <stripes:button id="deleteInput" name="delete"/>
            </div>
        </div>
        <div id="SelecteerUitvoer" class="step">
            <h1>Selecteer database om naar uit te voeren:</h1>
            <div id="outputListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
                <%@include file="/pages/main/output/list.jsp" %>
            </div>
            <div class="crudButtonsArea">
                <stripes:button id="createOutput" name="create"/>
                <stripes:button id="updateOutput" name="update"/>
                <stripes:button id="deleteOutput" name="delete"/>
            </div>
        </div>
        <div id="Overzicht" class="step submit_step">
            <h1>Overzicht:</h1>
            <div class="ui-layout-content">
                <%@include file="/pages/main/overview/view.jsp" %>
            </div>
        </div>
    </div>
    <div class="ui-layout-south wizardButtonsArea">
        <stripes:reset id="createProcessBackButton" name="resetDummyName"/>
        <stripes:submit id="createProcessNextButton" name="createComplete"/>
    </div>
</stripes:form>