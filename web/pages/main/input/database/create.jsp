<%--
    Document   : create
    Created on : 3-mei-2010, 18:03:12
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="databaseUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction"/>
<stripes:url var="inputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>
<stripes:url var="processUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction"/>

<script type="text/javascript">

    connectionSuccessInputDBAjaxOpenOptions = {
        formSelector: ".form-container .ui-accordion-content-active form",
        event: "createComplete",
        containerSelector: "#databasesListContainer",
        successAfterContainerFill: function(data, textStatus, xhr, container) {
            //$("#dbContainer").dialog("close");
            container.dialog("close");
        }
    }

    $(document).ready(function() {
        $("#createDB").button();
        $("#updateDB").button();
        $("#deleteDB").button();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        $("#createInputForm").bind("step_shown", function(event, data) {
            formWizardStep(data);

            $("#inputContainer").layout(defaultDialogLayoutOptions);
            $("#inputSteps").layout(defaultDialogLayoutOptions).destroy();

            if (data.previousStep)
                $("#" + data.previousStep).removeClass("ui-layout-center");
            $("#" + data.currentStep).addClass("ui-layout-center");

            $("#inputSteps").layout(defaultDialogLayoutOptions).initContent("center");

            // ui layout plugin zet z-index op 1
            var modalDialogZIndexWorkaroundCss = {
                "z-index": 2000
            };

            $("#inputContainer, #inputSteps, .wizardButtonsArea").css(modalDialogZIndexWorkaroundCss);
            $("#" + data.currentStep).css(modalDialogZIndexWorkaroundCss);

            if (data.currentStep === "SelecteerTabel") {
                var inputNode = $("#createInputForm .ui-state-active").prevAll("input").first();
                ajaxActionEventInto(
                    "${inputUrl}",
                    "createTablesList&selectedDatabaseId=" + $(inputNode).val(),
                    "#tablesListContainer"
                );
            }
        });

        $("#createInputForm").formwizard(
            $.extend({}, formWizardConfig, {
                formOptions: {
                    beforeSend: function() {
                        // beetje een lelijke hack, maar werkt wel mooi:
                        ajaxFormEventInto("#createInputForm", "createDatabaseInputComplete", "#inputListContainer", function() {
                            $("#inputContainer").dialog("close");
                        });
                        return false;
                    }
                }
            })
        );

        var newUpdateDBCommonDialogOptions = $.extend({}, defaultDialogOptions, {
            width: 700,
            height: 600,
            buttons: { // TODO: localize button name:
                "Voltooien" : function() {
                    testConnection(connectionSuccessInputDBAjaxOpenOptions);
                }
            }
        });

        $("#createDB").click(function() {
            ajaxOpen({
                url: "${databaseUrl}",
                event: "create",
                containerId: "dbContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateDBCommonDialogOptions, {
                    title: "Nieuwe Database..." // TODO: localization
                })
            });

            return false;
        })

        $("#updateDB").click(function() {
            ajaxOpen({
                url: "${databaseUrl}",
                formSelector: "#createInputForm",
                event: "update",
                containerId: "dbContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateDBCommonDialogOptions, {
                    title: "Bewerk Database..." // TODO: localization
                })
            });

            return false;
        })

        $("#deleteDB").click(function() {//TODO: localize
            if (!$("#createInputForm").valid())
                return;

            $("<div id='dbContainer' class='confirmationDialog'><p>Weet u zeker dat u deze databaseconnectie wilt verwijderen?</p><p> Alle database-invoer die deze databaseconnectie gebruikt en alle processen die die database-invoer gebruiken zullen ook worden verwijderd.</p></div>").appendTo($(document.body));

            $("#dbContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "Databaseconnectie verwijderen...", // TODO: localization
                width: 350,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        $.blockUI(blockUIOptions);
                        ajaxOpen({
                            url: "${databaseUrl}",
                            formSelector: "#createInputForm",
                            event: "delete",
                            containerSelector: "#databasesListContainer",
                            ajaxOptions: {globals: false}, // prevent blockUI being called 3 times. Called manually.
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${inputUrl}",
                                    event: "list",
                                    containerSelector: "#inputListContainer",
                                    ajaxOptions: {globals: false},
                                    successAfterContainerFill: function() {
                                        ajaxOpen({
                                            url: "${processUrl}",
                                            event: "list",
                                            containerSelector: "#processesListContainer",
                                            ajaxOptions: {globals: false},
                                            successAfterContainerFill: function() {
                                                $("#dbContainer").dialog("close");
                                                $.unblockUI(unblockUIOptions);
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                }
            }));
        });

    });

</script>


<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <stripes:wizard-fields/>
    <div id="inputSteps" class="ui-layout-center">
        <div id="SelecteerDatabaseconnectie" class="step ui-layout-center">
            <h1>Selecteer databaseconnectie:</h1>
            <div id="databasesListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
                <%@include file="/pages/main/database/list.jsp" %>
            </div>
            <div class="crudButtonsArea">
                <stripes:button id="createDB" name="create"/>
                <stripes:button id="updateDB" name="update"/>
                <stripes:button id="deleteDB" name="delete"/>
            </div>
        </div>
        <div id="SelecteerTabel" class="step submitstep">
            <h1>Selecteer tabel:</h1>
            De onderstaande tabellen zijn geschikt om in te voeren.
            <div id="tablesListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
            </div>
        </div>
    </div>

    <div class="wizardButtonsArea ui-layout-south">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createDatabaseInputComplete"/>
    </div>
</stripes:form>
