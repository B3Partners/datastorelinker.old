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

    $(function() {
        $("#createDB").button();
        $("#updateDB").button();
        $("#deleteDB").button();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        // hackhack
        //$("#databasesList").buttonset();

        // breekt validation van buttonset()
        /*$("#inputContainer").layout({
            resizeWithWindow: false
        });*/

        $("#createInputForm").formwizard(
            // form wizard settings
            $.extend({}, formWizardConfig, {
                afterNext: function(wizardData) {
                    formWizardConfig.afterNext(wizardData);
                    if (wizardData.currentStep === "SelecteerTabel") {
                        var inputNode = $("#createInputForm .ui-state-active").prev();
                        // We could be looking at an errormessage from jquery.validate(): if so, we use the previous again:
                        if (!inputNode.is("input")) {
                            inputNode = inputNode.prev();
                        }
                        ajaxActionEventInto(
                            "${inputUrl}",
                            "createTablesList&selectedDatabaseId=" + $(inputNode).val(),
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
            if (!$("#createInputForm").valid())
                return;

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
            if (!$("#createInputForm").valid())
                return;

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

        //$("#inputContainer").layout().resizeAll();
        
    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <div class="ui-layout-center">
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
    </div>

    <div class="wizardButtonsArea ui-layout-south">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createDatabaseInputComplete"/>
    </div>
</stripes:form>
