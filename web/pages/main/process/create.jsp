<%-- 
    Document   : create
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

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

        $("#createUpdateProcessForm").formwizard(
            formWizardConfig, {
                //validation settings
            }, {
                // form plugin settings
                beforeSend: function() {
                    // beetje een lelijke hack, maar werkt wel mooi:
                    ajaxFormEventInto("#createUpdateProcessForm", "createComplete", "#processesListContainer", function() {
                        log("success!");
                        $("#processContainer").dialog("close");
                    });
                    return false;
                }
            }
        );

        $("#createInputDB").click(function() {
            $("<div id='inputContainer'/>").appendTo(document.body);

            var inputDialog = getInputDialog();
            inputDialog.dialog("option", "title", "Nieuwe Database Invoer...");// TODO: localization
            inputDialog.dialog("open");

            $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>", "createDatabaseInput", function(data) {
                $("#inputContainer").html(data);
            });

            return false;
        });

        $("#createInputFile").click(function() {
            $("<div id='inputContainer'/>").appendTo(document.body);

            var inputDialog = getInputDialog();
            inputDialog.dialog("option", "title", "Nieuwe Bestand Invoer...");// TODO: localization
            inputDialog.dialog("open");

            $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>", "createFileInput", function(data) {
                $("#inputContainer").html(data);
            });

            return false;
        });

        $("#updateInput").click(function() {
            $("<div id='inputContainer'/>").appendTo(document.body);

            var inputDialog = getInputDialog();
            inputDialog.dialog("option", "title", "Bewerk X...");// TODO: localization
            inputDialog.dialog("open");

            ajaxFormEventInto("#createUpdateProcessForm", "update", "#inputContainer", null,
                "<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>");

            return false;
        });


        $("#createOutput").click(function() {
            $("<div id='outputContainer'/>").appendTo(document.body);

            var outputDialog = getOutputDialog();
            outputDialog.dialog("option", "title", "Nieuwe Uitvoer Database...");// TODO: localization
            outputDialog.dialog("open");

            $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.OutputAction"/>", "create", function(data) {
                $("#outputContainer").html(data);
            });
        })

        $("#updateOutput").click(function() {
            $("<div id='outputContainer'/>").appendTo(document.body);

            var outputDialog = getOutputDialog();
            outputDialog.dialog("option", "title", "Bewerk Uitvoer Database...");// TODO: localization
            outputDialog.dialog("open");

            ajaxFormEventInto("#createUpdateProcessForm", "update", "#outputContainer", null,
                "<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.OutputAction"/>");
        })

    });

    function getInputDialog() {
        return $("#inputContainer").dialog({
            autoOpen: false,
            width: 800,
            height: 500,
            modal: true,
            close: function() {
                log("inputContainer closing");
                if ($("#createInputForm")) {
                    $("#createInputForm").formwizard("destroy");
                }
                $("#inputContainer").dialog("destroy");
                // volgende regel heel belangrijk!!
                $("#inputContainer").remove();
            }
        });
    }

    function getOutputDialog() {
        return $("#outputContainer").dialog({
            autoOpen: false,
            width: 700,
            height: 600,
            modal: true,
            buttons: { // TODO: localize button name:
                "Voltooien" : function() {
                    ajaxFormEventInto("#postgisForm", "createComplete", "#outputListContainer", function() {
                        $("#outputContainer").dialog("close");
                    }, "<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.OutputAction"/>");
                }
            },
            close: defaultDialogClose,
            beforeclose: function(event, ui) {
                // TODO: check connection. if bad return false
                return true;
            }
        });
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