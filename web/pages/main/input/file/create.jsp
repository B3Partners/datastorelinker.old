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
        $("#deleteFile").button();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        $("#createInputForm").formwizard(
            $.extend({}, formWizardConfig, {
                formOptions: {
                    beforeSend: function() {
                        ajaxOpen({
                            formSelector: "#createInputForm",
                            event: "createFileInputComplete",
                            containerSelector: "#inputListContainer",
                            successAfterContainerFill: function() {
                                $("#inputContainer").dialog("close");
                            }
                        });
                        return false;
                    }
                }
            })
        );

        $("#inputContainer").layout(defaultDialogLayoutOptions);

        // layout plugin messes up z-indices; sets them to 1
        $("#inputContainer, #SelecteerBestand, #inputContainer .wizardButtonsArea").css({ "z-index": "auto" });

        $("#deleteFile").click(function() {//TODO: localize
            if (!$("#createInputForm").valid())
                return;

            $("<div id='createFileContainer' class='confirmationDialog'><p>Weet u zeker dat u dit bestand van de server wilt verwijderen?</p><p> Alle bestands-invoer die dit bestand gebruikt en alle processen die deze bestands-invoer gebruiken zullen ook worden verwijderd.</p></div>").appendTo(document.body);

            $("#createFileContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "Bestand van de server verwijderen...", // TODO: localization
                width: 350,
                buttons: {
                    "Nee": function() { // TODO: localize
                        $(this).dialog("close");
                    },
                    "Ja": function() {
                        $.blockUI(blockUIOptions);
                        ajaxOpen({
                            url: "${fileUrl}",
                            formSelector: "#createInputForm",
                            event: "delete",
                            containerSelector: "#filesListContainer",
                            ajaxOptions: {globals: false}, // prevent blockUI being called 3 times. Called manually.
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${inputUrl}",
                                    event: "list",
                                    containerSelector: "#inputListContainer",
                                    ajaxOptions: {globals: false},
                                    successAfterContainerFill: function() {
                                        ajaxOpen({
                                            url: "${processUrl}",
                                            event: "list",
                                            containerSelector: "#processesListContainer",
                                            ajaxOptions: {globals: false},
                                            successAfterContainerFill: function() {
                                                $("#createFileContainer").dialog("close");
                                                $.unblockUI(unblockUIOptions);
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                }
            }));
        });


    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <stripes:wizard-fields/>
    <div id="SelecteerBestand" class="step submitstep ui-layout-center">
        <h1>Selecteer bestand:</h1>
        <div id="filesListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
            <%@include file="/pages/main/file/list.jsp" %>
        </div>
        <div>
            <%@include file="/pages/main/file/create.jsp" %>
            <stripes:link href="#" id="deleteFile" onclick="return false;">
                <stripes:label for="delete" class="layoutTitle"/>
            </stripes:link>
        </div>
    </div>

    <div class="wizardButtonsArea ui-layout-south">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createFileInputComplete"/>
    </div>
</stripes:form>