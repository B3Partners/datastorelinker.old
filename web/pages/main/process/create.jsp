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
    $(function() {
        $("#createProcessBackButton").button();
        $("#createProcessNextButton").button();

        $("#createInputDB").button();
        $("#createInputFile").button();
        $("#updateInput").button();
        $("#deleteInput").button();

        $("#createOutput").button();
        $("#updateOutput").button();
        $("#deleteOutput").button();

        currentActionsList = null;
        
        var actionsList = ${actionBean.actionsList};
        log(actionsList);
        fillActionsList(actionsList, "#actionsOverviewContainer", "${contextPath}");

        $("#createUpdateProcessForm").formwizard(
            // form wizard settings
            $.extend({}, formWizardConfig, {
                afterNext: function(wizardData) {
                    formWizardConfig.afterNext(wizardData);
                    $("#createUpdateProcessForm :reset").button("enable");
                    if (wizardData.currentStep === "Overzicht") {
                        var inputText = $("#inputListContainer .ui-state-active .ui-button-text").html();
                        $("#inputOverviewContainer").html(inputText);
                        var outputText = $("#outputListContainer .ui-state-active .ui-button-text").html();
                        $("#outputOverviewContainer").html(outputText);
                    }
                }
            }),
            defaultValidateOptions,
            {
                // form plugin settings
                beforeSend: function() {
                    //log(typeof currentActionsList);
                    if (typeof currentActionsList == "undefined" || !currentActionsList)
                        currentActionsList = [];
                    var actionsListJson = JSON.stringify(currentActionsList);
                    
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
        );

        $("#createInputDB").click(function() {
            $("<div id='inputContainer'/>").appendTo(document.body);

            var inputDialog = getInputDialog();
            inputDialog.dialog("option", "title", "Nieuwe Database Invoer...");// TODO: localization
            inputDialog.dialog("open");

            ajaxActionEventInto("${inputUrl}", "createDatabaseInput", "#inputContainer");

            return false;
        });

        $("#createInputFile").click(function() {
            $("<div id='inputContainer'/>").appendTo(document.body);

            var inputDialog = getInputDialog();
            inputDialog.dialog("option", "title", "Nieuwe Bestand Invoer...");// TODO: localization
            inputDialog.dialog("open");

            ajaxActionEventInto("${inputUrl}", "createFileInput", "#inputContainer");

            return false;
        });

        $("#updateInput").click(function() {
            if (!$("#createUpdateProcessForm").valid())
                return;

            $("<div id='inputContainer'/>").appendTo(document.body);

            var inputDialog = getInputDialog();
            inputDialog.dialog("option", "title", "Bewerk Invoer...");// TODO: localization // TODO: get Invoer type (db or file)
            inputDialog.dialog("open");

            ajaxFormEventInto("#createUpdateProcessForm", "update", "#inputContainer", null, "${inputUrl}");
        });

        $("#deleteInput").click(function() {//TODO: localize
            if (!$("#createUpdateProcessForm").valid())
                return;

            $("<div id='inputContainer' class='confirmationDialog'>Weet u zeker dat u deze invoer wilt verwijderen? Alle processen die deze invoer gebruiken zullen ook worden verwijderd.</div>").appendTo(document.body);

            $("#inputContainer").dialog({
                title: "Invoer verwijderen...", // TODO: localization
                modal: true,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxFormEventInto("#createUpdateProcessForm", "delete", "#inputListContainer", function() {
                            ajaxActionEventInto("${processUrl}", "list", "#processesListContainer",
                                function() {
                                    $("#inputContainer").dialog("close");
                                }
                            );
                        }, "${inputUrl}");
                    }
                },
                close: defaultDialogClose
            });
        });

        $("#createOutput").click(function() {
            $("<div id='outputContainer'/>").appendTo(document.body);

            var outputDialog = getOutputDialog();
            outputDialog.dialog("option", "title", "Nieuwe Uitvoer Database...");// TODO: localization
            outputDialog.dialog("open");

            $.get("${outputUrl}", "create", function(data) {
                $("#outputContainer").html(data);
            });
        })

        $("#updateOutput").click(function() {
            if (!$("#createUpdateProcessForm").valid())
                return;

            $("<div id='outputContainer'/>").appendTo(document.body);

            var outputDialog = getOutputDialog();
            outputDialog.dialog("option", "title", "Bewerk Uitvoer Database...");// TODO: localization
            outputDialog.dialog("open");

            ajaxFormEventInto("#createUpdateProcessForm", "update", "#outputContainer", null, "${outputUrl}");
        })

        $("#deleteOutput").click(function() {//TODO: localize
            if (!$("#createUpdateProcessForm").valid())
                return;

            $("<div id='outputContainer'>Weet u zeker dat u deze uitvoer wilt verwijderen? Alle processen die deze uitvoer gebruiken zullen ook worden verwijderd.</div>").appendTo($(document.body));

            $("#outputContainer").dialog({
                title: "Uitvoer verwijderen...", // TODO: localization
                modal: true,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxFormEventInto("#createUpdateProcessForm", "delete", "#outputListContainer", function() {
                            ajaxActionEventInto("${processUrl}", "list", "#processesListContainer",
                                function() {
                                    $("#outputContainer").dialog("close");
                                }
                            );
                        }, "${outputUrl}");
                    }
                },
                close: defaultDialogClose
            });
        });
    });

    function getInputDialog() {
        return $("#inputContainer").dialog({
            autoOpen: false,
            width: 800,
            height: 500,
            modal: true,
            close: function(event, ui) {
                $("#uploader").uiloadDestroy();
                $("#createInputForm").formwizard("destroy");
                defaultDialogClose(event, ui);
            }
        });
    }

    function getInputDialogOptions() {
        return {
            width: 800,
            height: 500,
            modal: true,
            close: function(event, ui) {
                $("#createInputForm").formwizard("destroy");
                defaultDialogClose(event, ui);
            }
        };
    }

    function getOutputDialog() {
        return $("#outputContainer").dialog({
            autoOpen: false,
            width: 700,
            height: 600,
            modal: true,
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
            },
            close: defaultDialogClose
        });
    }

    function getOutputDialogOptions() {
        return {
            width: 700,
            height: 600,
            modal: true,
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
            },
            close: defaultDialogClose
        };
    }

</script>

<stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <!-- wizard-fields nodig voor bewerken van een proces: selectedProcessId wordt dan meegenomen -->
    <stripes:wizard-fields/>
    <div id="SelecteerInvoer" class="step">
        <h1>Selecteer bestand- of database-invoer:</h1>
        <div id="inputListContainer">
            <%@include file="/pages/main/input/list.jsp" %>
        </div>
        <div>
            <stripes:button id="createInputDB" name="createInputDB"/>
            <stripes:button id="createInputFile" name="createInputFile"/>
            <stripes:button id="updateInput" name="update"/>
            <stripes:button id="deleteInput" name="delete"/>
        </div>
    </div>
    <div id="SelecteerUitvoer" class="step">
        <h1>Selecteer database om naar uit te voeren:</h1>
        <div id="outputListContainer">
            <%@include file="/pages/main/output/list.jsp" %>
        </div>
        <div>
            <stripes:button id="createOutput" name="create"/>
            <stripes:button id="updateOutput" name="update"/>
            <stripes:button id="deleteOutput" name="delete"/>
        </div>
    </div>
    <div id="Overzicht" class="step submit_step">
        <h1>Overzicht:</h1>
        <div>
            <%@include file="/pages/main/overview/view.jsp" %>
        </div>
    </div>
    <!--div id="secondStep" class="step">
        <h1>step 2 - branch step</h1>
        <input  type="text" value="" /><br />
        <input  type="text" value="" /><br />
        <input  type="text" value="" /><br />
        <select  class="link" >
            <option value="" >Choose the step to go to...</option>
            <option value="thirdStep" >Go to Step3</option>
            <option value="fourthStep" >Go to Step4</option>
        </select><br />
    </div>
    <div id="thirdStep" class="step submit_step">
        <h1>step 3 - submit step</h1>
        <input  type="text" value="" /><br />
        <input  type="text" value="" class="required"/><br />
    </div>
    <div id="fourthStep" class="step">
        <h1>step 4</h1>
        <input  type="text" value="" /><br />
        <input  type="text" name="email" class="required email" /><br />
    </div>
    <div id="lastStep" class="step">
        <h1>step 5 - last step</h1>
        <input  type="text" value="" /><br />
        <input  type="text" value="" /><br />
    </div-->
    <div class="wizardButtonsArea">
        <stripes:reset id="createProcessBackButton" name="resetDummyName"/>
        <stripes:submit id="createProcessNextButton" name="createComplete"/>
    </div>
</stripes:form>