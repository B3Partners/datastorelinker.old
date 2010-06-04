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
        successAfterContainerFill: function() {
            $("#dbContainer").dialog("close");
        }
    }

    $(function() {
        $("#createDB").button();
        $("#updateDB").button();
        $("#deleteDB").button();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        $("#createInputForm").formwizard(
            // form wizard settings
            $.extend({}, formWizardConfig, {
                afterNext: function(wizardData) {
                    formWizardConfig.afterNext(wizardData);
                    if (wizardData.currentStep === "SelecteerTabel") {
                        //log("createTablesList&selectedDatabaseId=" + $("#createInputForm .ui-state-active").prev().val());
                        ajaxActionEventInto(
                            "${inputUrl}",
                            "createTablesList&selectedDatabaseId=" + $("#createInputForm .ui-state-active").prev().val(),
                            "#tablesListContainer"
                        );
                    }
                }
            }),
            defaultValidateOptions,
            {
                // form plugin settings
                beforeSend: function() {
                    // beetje een lelijke hack, maar werkt wel mooi:
                    ajaxFormEventInto("#createInputForm", "createDatabaseInputComplete", "#inputListContainer", function() {
                        if ($("#inputContainer"))
                            $("#inputContainer").dialog("close");
                    });
                    return false;
                }
            }
        );

        $("#createDB").click(function() {
            $("<div id='dbContainer'/>").appendTo(document.body);

            $("#dbContainer").dialog({
                title: "Nieuwe Database...", // TODO: localization
                width: 700,
                height: 600,
                modal: true,
                buttons: { // TODO: localize button name:
                    "Voltooien" : function() {
                        testConnection(connectionSuccessInputDBAjaxOpenOptions);
                    }
                },
                close: defaultDialogClose
            });

            $.get("${databaseUrl}", "create", function(data) {
                $("#dbContainer").html(data);
            });
        })

        $("#updateDB").click(function() {
            $("<div id='dbContainer'/>").appendTo(document.body);

            $("#dbContainer").dialog({
                title: "Bewerk Database...", // TODO: localization
                width: 700,
                height: 600,
                modal: true,
                buttons: { // TODO: localize button name:
                    "Voltooien" : function() {
                        testConnection(connectionSuccessInputDBAjaxOpenOptions);
                    }
                },
                close: defaultDialogClose
            });

            ajaxFormEventInto("#createInputForm", "update", "#dbContainer", null, "${databaseUrl}");
        })

        $("#deleteDB").click(function() {//TODO: localize
            $("<div id='dbContainer' class='confirmationDialog'><p>Weet u zeker dat u deze databaseconnectie wilt verwijderen?</p><p> Alle database-invoer die deze databaseconnectie gebruikt en alle processen die die database-invoer gebruiken zullen ook worden verwijderd.</p></div>").appendTo($(document.body));

            $("#dbContainer").dialog({
                title: "Databaseconnectie verwijderen...", // TODO: localization
                modal: true,
                width: 350,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxFormEventInto("#createInputForm", "delete", "#databasesListContainer", function() {
                            ajaxActionEventInto("${inputUrl}", "list", "#inputListContainer", function() {
                                ajaxActionEventInto("${processUrl}", "list", "#processesListContainer", function() {
                                    $("#dbContainer").dialog("close");
                                });
                            });
                        }, "${databaseUrl}");
                    }
                },
                close: defaultDialogClose
            });
        });

    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <stripes:wizard-fields/>
    <div id="SelecteerDatabaseconnectie" class="step">
        <h1>Selecteer databaseconnectie:</h1>
        <div id="databasesListContainer">
            <%@include file="/pages/main/database/list.jsp" %>
        </div>
        <div>
            <stripes:button id="createDB" name="create"/>
            <stripes:button id="updateDB" name="update"/>
            <stripes:button id="deleteDB" name="delete"/>
        </div>
    </div>
    <div id="SelecteerTabel" class="step submitstep">
        <h1>Selecteer tabel:</h1>
        De onderstaande tabellen zijn geschikt om in te voeren.
        <div id="tablesListContainer">
            Bezig met laden...
        </div>
    </div>

    <div class="wizardButtonsArea">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createDatabaseInputComplete"/>
    </div>
</stripes:form>