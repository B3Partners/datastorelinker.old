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

        $("#filesList").buttonset();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        $("#createInputForm").formwizard(
            formWizardConfig, {
                //validation settings
            }, {
                // form plugin settings
                beforeSend: function() {
                    // beetje een lelijke hack, maar werkt wel mooi:
                    ajaxFormEventInto("#createInputForm", "createFileInputComplete", "#inputList", function() {
                        log("success!");
                        if ($("#createInputFileContainer"))
                            $("#createInputFileContainer").dialog("close");
                        $("#inputList").buttonset();
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
                        // is deze button wel disabled totdat dialog alles ready is
                        $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>", "createComplete", function(data) {
                            $("#createFileContainer").dialog("close");
                            $("#filesList").html(data);
                            $("#filesList").buttonset();
                        });
                    }
                },
                close: function() {
                    log("createFileContainer closing");
                    $("#createFileContainer").dialog("destroy");
                    // volgende regel heel belangrijk!!
                    $("#createFileContainer").remove();
                }
            });

            $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>", "create", function(data) {
                $("#createFileContainer").html(data);
            });
        })

    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <div id="SelecteerBestand" class="step">
        <h1>Selecteer bestand:</h1>
        <div id="filesList" class="radioList">
            <%@include file="/pages/main/file/list.jsp" %>
        </div>
        <div>
            <stripes:button id="createFile" name="create"/>
            <stripes:button id="updateFile" name="update"/>
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