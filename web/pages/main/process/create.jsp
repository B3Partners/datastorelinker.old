<%-- 
    Document   : create
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<style type="text/css">
    .step {margin-bottom: 10px}

    #inputList { width: 50%; margin-top: 10px; margin-bottom: 10px }
    #inputList .ui-button { margin: 3px; display: block; text-align: left; background: #eeeeee; color: black }
    #inputList .ui-state-hover { background: #FECA40; }
    #inputList .ui-state-active { background: #f2d81c; }

    #outputList { width: 50%; margin-top: 10px; margin-bottom: 10px }
    #outputList .ui-button { margin: 3px; display: block; text-align: left; background: #eeeeee; color: black }
    #outputList .ui-state-hover { background: #FECA40; }
    #outputList .ui-state-active { background: #f2d81c; }

</style>

<script type="text/javascript">
    $(function() {
        $("#inputList").buttonset();
        $("#outputList").buttonset();

        $("#createProcessBackButton").button();
        $("#createProcessNextButton").button();

        $("#createInputDB").button();
        $("#createInputFile").button();
        $("#updateInput").button();
        $("#deleteInput").button();

        $("#createProcessWizardForm").formwizard( {
            //form wizard settings
            historyEnabled : false,
            formPluginEnabled : true,
            validationEnabled : false,
            focusFirstInput : true,
            textNext : "Volgende",
            textBack : "Vorige",
            textSubmit : "Voltooien",
            inAnimation : "slideDown", //"show",
            outAnimation : "slideUp" //"hide"
        }, {
            //validation settings
        }, {
            // form plugin settings
            target: "#ui-tabs-1",
            success: function() {
                log("success!");
                createProcessDialog.dialog("close");
            }
        });

        $("#createInputDB").click(function() {
            $("<div id='createInputDBContainer'/>").appendTo($(document.body));

            createInputDBDialog = $("#createInputDBContainer").dialog({
                title: "Nieuwe Database Invoer...", // TODO: localization
                width: 800,
                height: 500,
                modal: true,
                close: function() {
                    log("createInputDBDialog closing");
                    if ($("#createInputForm")) {
                        $("#createInputForm").formwizard("destroy");
                    }
                    createInputDBDialog.dialog("destroy");
                    // volgende regel heel belangrijk!!
                    createInputDBDialog.remove();
                }
            });

            $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>", "createDatabaseInput", function(data) {
                $("#createInputDBContainer").html(data);
            });

            return false;
        });

    });

</script>

<stripes:form id="createProcessWizardForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <div id="SelecteerInvoer" class="step">
        <h1>Selecteer bestand- of database-invoer:</h1>
        <div id="inputList">
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
        <div id="outputList">
            <%@include file="/pages/main/output/list.jsp" %>
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
    <stripes:reset id="createProcessBackButton" name="resetDummyName"/>
    <stripes:submit id="createProcessNextButton" name="createComplete"/>
</stripes:form>