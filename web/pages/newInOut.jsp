<%-- 
    Document   : newInOut
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
        $("#newDB").button();
        $("#editDB").button();
        $("#deleteDB").button();

        $("#databasesList").buttonset();

        $("#newInOutBackButton").button();
        $("#newInOutNextButton").button();

        $("#newInOutForm").formwizard( {
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
            target: "#databasesList",
            beforeSend: function(XMLHttpRequest) {
                // TODO: newComplete toevoegen als argument!!!!
            },
            success: function() {
                log("success!");
                newInputDBDialog.dialog("close");
            }/*,
            error: function(xhr, status, index, anchor) {
                $(anchor.hash).html("Couldn't load this tab." + status);
            }*/
        });

    });

</script>

<stripes:form id="newInOutForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InOutAction">
    <div id="SelecteerDatabaseconnectie" class="step">
        <h1>Selecteer databaseconnectie:</h1>
        <div id="databasesList">
            <%@include file="/pages/inoutList.jsp" %>
        </div>
        <div>
            <stripes:button id="newDB" name="new_"/>
            <stripes:button id="editDB" name="edit"/>
            <stripes:button id="deleteDB" name="delete"/>
        </div>
    </div>
    <div id="SelecteerTabel" class="step submitstep">
        <h1>Selecteer tabel:</h1>
    </div>

    <stripes:reset id="newInOutBackButton" name="resetDummyName"/>
    <stripes:submit id="newInOutNextButton" name="newComplete"/>
</stripes:form>