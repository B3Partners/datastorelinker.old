<%-- 
    Document   : processOverview
    Created on : 22-apr-2010, 19:31:42
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#createProcess").button();
        $("#updateProcess").button();
        $("#deleteProcess").button();
        $("#executeProcess").button();

        $("#createProcess").click(function() {
            $("<div id='processContainer'/>").appendTo(document.body);

            $("#processContainer").dialog({
                title: "Nieuw Proces...", // TODO: localization
                width: 900,
                height: 600,
                modal: true,
                close: function() {
                    log("processDialog closing");
                    if ($("#createUpdateProcessForm")) {
                        $("#createUpdateProcessForm").formwizard("destroy");
                    }
                    $("#processContainer").dialog("destroy");
                    // volgende regel heel belangrijk!!
                    $("#processContainer").remove();
                }
            });

            ajaxActionEventInto("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction"/>",
                "create", "#processContainer");

            return false;
        });

        $("#updateProcess").click(function() {
            $("<div id='processContainer'/>").appendTo(document.body);

            $("#processContainer").dialog({
                title: "Bewerk Proces...", // TODO: localization
                width: 900,
                height: 600,
                modal: true,
                close: function() {
                    log("processDialog closing");
                    if ($("#createUpdateProcessForm")) {
                        $("#createUpdateProcessForm").formwizard("destroy");
                    }
                    $("#processContainer").dialog("destroy");
                    // volgende regel heel belangrijk!!
                    $("#processContainer").remove();
                }
            });

            ajaxFormEventInto("#processForm", "update", "#processContainer");

            return false;
        });

        $("#executeProcess").click(function() {
            $("<div id='processContainer'/>").appendTo($(document.body));

            $("#processContainer").dialog({
                title: "Proces uitvoeren...", // TODO: localization
                width: 900,
                height: 600,
                modal: true,
                buttons: {
                    "Annuleren": function() { // TODO: localize
                        $(this).dialog("close");
                    }
                },
                close: defaultDialogClose
            });
            
            ajaxFormEventInto("#processForm", "execute", "#processContainer");

            return false;
        });

        $("#deleteProcess").click(function() {//TODO: localize
            $("<div id='processContainer' class='confirmationDialog'>Weet u zeker dat u dit proces wilt verwijderen?</div>").appendTo($(document.body));

            $("#processContainer").dialog({
                title: "Proces verwijderen...", // TODO: localization
                modal: true,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxFormEventInto("#processForm", "delete", "#processesListContainer", function() {
                            $("#processContainer").dialog("close");
                        });
                    }
                },
                close: defaultDialogClose
            });
        });
    });

</script>

<stripes:form id="processForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <stripes:label for="main.process.overview.text.overview"/>:

    <div id="processesListContainer">
        <%@include file="/pages/main/process/list.jsp" %>
    </div>
    
    <div id="buttonPanel">
        <stripes:button id="createProcess" name="create"/>
        <stripes:button id="updateProcess" name="update"/>
        <stripes:button id="deleteProcess" name="delete"/>
        <stripes:button id="executeProcess" name="execute"/>
    </div>
        
</stripes:form>