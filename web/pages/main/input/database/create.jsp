<%-- 
    Document   : create
    Created on : 3-mei-2010, 18:03:12
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<style type="text/css">
    .step {margin-bottom: 10px}

    #databasesList { width: 50%; margin-top: 10px; margin-bottom: 10px }
    #databasesList .ui-button { margin: 3px; display: block; text-align: left; background: #eeeeee; color: black }
    #databasesList .ui-state-hover { background: #FECA40; }
    #databasesList .ui-state-active { background: #f2d81c; }
</style>

<script type="text/javascript">
    $(function() {
        $("#createDB").button();
        $("#updateDB").button();
        $("#deleteDB").button();

        $("#databasesList").buttonset();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        $("#createInputForm").formwizard( {
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
            //target: "#databasesList",
            beforeSend: function() {
                // beetje een lelijke hack, maar werkt wel mooi:
                ajaxFormEventInto("#createInputForm", "createDatabaseInputComplete", "#databasesList", function() {
                    log("success!");
                    createInputDBDialog.dialog("close");
                });
                return false;
            }/*,
            success: function() {
                log("success!");
                createInputDBDialog.dialog("close");
            }*/
        });

        $("#createDB").click(function() {
            

            $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction"/>", "create", function(data) {
                $("#createInputDBContainer").html(data);
            });
        })

    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <div id="SelecteerDatabaseconnectie" class="step">
        <h1>Selecteer databaseconnectie:</h1>
        <div id="databasesList">
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
    </div>

    <stripes:reset id="createInputBackButton" name="resetDummyName"/>
    <stripes:submit id="createInputNextButton" name="createDatabaseInputComplete"/>
</stripes:form>