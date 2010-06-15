<%-- 
    Document   : processOverview
    Created on : 22-apr-2010, 19:31:42
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="processUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction"/>

<script type="text/javascript">
    $(function() {
        $("#processForm").validate(defaultValidateOptions);

        $("#createProcess").button();
        $("#updateProcess").button();
        $("#deleteProcess").button();
        $("#executeProcess").button();

        $("#createProcess").click(function() {
            // TODO: wacht op een volgende versie van jquery UI waar http://dev.jqueryui.com/ticket/5295
            // in is geïntegreerd.
            // Of bouw eigen jquery UI met de patch uit de link.
            // Of integreer onderstaande korte patch bij elke knop.
            //
            //$(this).removeClass("ui-state-active ui-state-hover ui-state-focus");
            ajaxOpen({
                url: "${processUrl}",
                event: "create",
                containerId: "processContainer",
                openInDialog: true,
                dialogOptions: {
                    title: "Nieuw Proces...", // TODO: localization
                    width: 900,
                    height: 600,
                    modal: true,
                    close: function(event, ui) {
                        $("#createUpdateProcessForm").formwizard("destroy");
                        defaultDialogClose(event, ui);
                    }
                }
            });
        });

        $("#updateProcess").click(function() {
            ajaxOpen({
                formSelector: "#processForm",
                event: "update",
                containerId: "processContainer",
                openInDialog: true,
                dialogOptions: {
                    title: "Bewerk Proces...", // TODO: localization
                    width: 900,
                    height: 600,
                    modal: true,
                    close: function(event, ui) {
                        $("#createUpdateProcessForm").formwizard("destroy");
                        defaultDialogClose(event, ui);
                    }
                }
            });
        });

        $("#executeProcess").click(function() {
            if (!$("#processForm").valid())
                return;

            $("<div id='processContainer'><div id='processOutput'>Proces aan het uitvoeren...</div></div>").appendTo(document.body);

            $("#processContainer").prepend("<div id='progressbar'/>");
            $("#progressbar").progressbar();

            ajaxOpen({
                formSelector: "#processForm",
                event: "execute",
                containerSelector: "#processContainer",
                containerFill: false,
                successAfterContainerFill: function(data, textStatus, xhr) {
                    if (data.success) {
                        $("#progressbar").progressbar("value", 100);
                        $("#processOutput").html("Proces succesvol uitgevoerd:");
                    } else {
                        $("#processOutput").html("Proces niet succesvol uitgevoerd:");
                    }
                    $("#processOutput").append("<p>" + data.message + "</p>");
                },
                openInDialog: true,
                dialogOptions: {
                    title: "Proces uitvoeren...", // TODO: localization
                    width: 900,
                    height: 600,
                    modal: true,
                    buttons: {
                        "Annuleren": function() { // TODO: localize
                            $(this).dialog("close");
                        }
                    },
                    close: function(event, ui) {
                        $("#progressbar").progressbar("destroy");
                        defaultDialogClose(event, ui);
                    }
                }
            });
        });

        $("#deleteProcess").click(function() {//TODO: localize
            if (!$("#processForm").valid())
                return;

            $("<div id='processContainer'>Weet u zeker dat u dit proces wilt verwijderen?</div>").appendTo(document.body);

            $("#processContainer").dialog({
                title: "Proces verwijderen...", // TODO: localization
                modal: true,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxOpen({
                            formSelector: "#processForm",
                            event: "delete",
                            containerSelector: "#processesListContainer",
                            successAfterContainerFill: function() {
                                $("#processContainer").dialog("close");
                            }
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