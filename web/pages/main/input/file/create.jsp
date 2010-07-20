<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="fileUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>
<stripes:url var="inputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>
<stripes:url var="processUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction"/>

<script type="text/javascript">
    $(document).ready(function() {
        $("#createFile").button();
        $("#updateFile").button();
        $("#deleteFile").button();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        $("#createInputForm").formwizard(
            formWizardConfig,
            defaultValidateOptions, {
                // form plugin settings
                beforeSend: function() {
                    ajaxFormEventInto("#createInputForm", "createFileInputComplete", "#inputListContainer", function() {
                        if ($("#inputContainer"))
                            $("#inputContainer").dialog("close");
                    });
                    return false;
                }
            }
        );

        $("#createFile").click(function() {
            $("<div id='createFileContainer'/>").appendTo(document.body);

            $("#createFileContainer").dialog({
                title: "Nieuw Bestand...", // TODO: localization
                width: 700,
                height: 600,
                modal: true,
                buttons: { // TODO: localize button name:
                    "Voltooien" : function() {
                        ajaxActionEventInto("${fileUrl}", "createComplete", "#filesListContainer", function() {
                            $("#createFileContainer").dialog("close");
                        });
                    }
                },
                close: defaultDialogClose
            });

            ajaxActionEventInto("${fileUrl}", "create", "#createFileContainer");
        });

        $("#deleteFile").click(function() {//TODO: localize
            if (!$("#createInputForm").valid())
                return;

            $("<div id='createFileContainer' class='confirmationDialog'><p>Weet u zeker dat u dit bestand van de server wilt verwijderen?</p><p> Alle bestands-invoer die dit bestand gebruikt en alle processen die deze bestands-invoer gebruiken zullen ook worden verwijderd.</p></div>").appendTo(document.body);

            $("#createFileContainer").dialog({
                title: "Bestand van de server verwijderen...", // TODO: localization
                modal: true,
                width: 350,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        ajaxFormEventInto("#createInputForm", "delete", "#filesListContainer", function() {
                            ajaxActionEventInto("${inputUrl}", "list", "#inputListContainer", function() {
                                ajaxActionEventInto("${processUrl}", "list", "#processesListContainer", function() {
                                    $("#createFileContainer").dialog("close");
                                });
                            });
                        }, "${fileUrl}");
                    }
                },
                close: defaultDialogClose
            });
        });


    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <stripes:wizard-fields/>
    <div id="SelecteerBestand" class="step submitstep">
        <h1>Selecteer bestand:</h1>
        <div id="filesListContainer">
            <%@include file="/pages/main/file/list.jsp" %>
        </div>
        <div>
            <%--stripes:button id="createFile" name="create"/>
            <stripes:button id="updateFile" name="update"/--%>
            <%@include file="/pages/main/file/create.jsp" %>
            <stripes:button id="deleteFile" name="delete"/>
        </div>
    </div>
    <!--div id="SelecteerTabel" class="step submitstep">
        <h1>Selecteer tabel:</h1>
    </div-->

    <div class="wizardButtonsArea">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createFileInputComplete"/>
    </div>
</stripes:form>