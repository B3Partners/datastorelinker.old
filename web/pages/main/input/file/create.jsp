<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#createFile").button();
        $("#updateFile").button();
        $("#deleteFile").button();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        $("#createInputForm").formwizard(
            formWizardConfig, {
                //validation settings
            }, {
                // form plugin settings
                beforeSend: function() {
                    // beetje een lelijke hack, maar werkt wel mooi:
                    ajaxFormEventInto("#createInputForm", "createFileInputComplete", "#inputListContainer", function() {
                        if ($("#createInputFileContainer"))
                            $("#createInputFileContainer").dialog("close");
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
                        ajaxActionEventInto("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>",
                            "createComplete", "#filesListContainer",
                            function() {
                                $("#createFileContainer").dialog("close");
                            }
                        );
                    }
                },
                close: defaultDialogClose
            });

            ajaxActionEventInto("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>",
                "create", "#createFileContainer");
        })

    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <stripes:wizard-fields/>
    <div id="SelecteerBestand" class="step">
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
    <div id="SelecteerTabel" class="step submitstep">
        <h1>Selecteer tabel:</h1>
    </div>

    <div class="wizardButtonsArea">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createFileInputComplete"/>
    </div>
</stripes:form>