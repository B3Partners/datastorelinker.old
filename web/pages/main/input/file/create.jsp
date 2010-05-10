<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<style type="text/css">
    .step {margin-bottom: 10px}

    #filesList .ui-button { margin: 3px; display: block; text-align: left; background: #eeeeee; color: black }
    #filesList .ui-state-hover { background: #FECA40; }
    #filesList .ui-state-active { background: #f2d81c; }
</style>

<script type="text/javascript">
    $(function() {
        $("#createFile").button();
        $("#updateFile").button();
        $("#deleteFile").button();

        $("#filesList").buttonset();

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
            inAnimation : "slideDown",
            outAnimation : "slideUp"
        }, {
            //validation settings
        }, {
            // form plugin settings
            //target: "#filesList",
            beforeSend: function() {
                // beetje een lelijke hack, maar werkt wel mooi:
                ajaxFormEventInto("#createInputForm", "createFileInputComplete", "#inputList", function() {
                    log("success!");
                    createInputFileDialog.dialog("close");
                    $("#inputList").buttonset();
                });
                return false;
            }/*,
            success: function() {
                log("success!");
                createInputFileDialog.dialog("close");
            }*/
        });

        $("#createFile").click(function() {
            $("<div id='createFileContainer'/>").appendTo(document.body);

            createFileDialog = $("#createFileContainer").dialog({
                title: "Nieuw Bestand...", // TODO: localization
                width: 700,
                height: 600,
                modal: true,
                buttons: { // TODO: localize button name:
                    "Voltooien" : function() {
                        // is deze button wel disabled totdat dialog alles ready is
                        $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>", "createComplete", function(data) {
                            createFileDialog.dialog("close");
                            $("#filesList").html(data);
                            $("#filesList").buttonset();
                        });
                    }
                },
                close: function() {
                    log("createFileContainer closing");
                    createFileDialog.dialog("destroy");
                    // volgende regel heel belangrijk!!
                    createFileDialog.remove();
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