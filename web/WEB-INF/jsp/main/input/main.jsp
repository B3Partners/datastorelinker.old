<%-- 
    Document   : main
    Created on : 3-aug-2010, 20:00:28
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        var newUpdateInputCommonDialogOptions = $.extend({}, defaultDialogOptions, {
            width: Math.floor($('body').width() * .65),
            height: Math.floor($('body').height() * .60),
            resize: function(event, ui) {
                $("#inputContainer").layout().resizeAll();
                if ($("#inputSteps").length != 0) // it exists
                    $("#inputSteps").layout().resizeAll();
            },
            close: function(event, ui) {
                $("#uploader").uiloadDestroy();
                defaultDialogClose(event, ui);
            }
        });

        $("#createInputDB").click(function() {
            ajaxOpen({
                url: "${inputUrl}",
                event: "createDatabaseInput",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateInputCommonDialogOptions, {
                    title: I18N.newDatabaseInput
                })
            });

            return defaultButtonClick(this);
        });

        $("#createInputFile").click(function() {
            ajaxOpen({
                url: "${inputUrl}",
                event: "createFileInput",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateInputCommonDialogOptions, {
                    title: I18N.newFileInput
                })
            });

            return defaultButtonClick(this);
        });

        $("#updateInput").click(function() {
            ajaxOpen({
                url: "${inputUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "update",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateInputCommonDialogOptions, {
                    title: I18N.editInput
                })
            });

            return defaultButtonClick(this);
        });

        $("#deleteInput").click(function() {
            if (!isFormValidAndContainsInput("#createUpdateProcessForm"))
                return defaultButtonClick(this);

            $("<div></div>").html(I18N.deleteInputAreYouSure)
                .attr("id", "inputContainer").appendTo(document.body);

            $("#inputContainer").dialog($.extend({}, defaultDialogOptions, {
                title: I18N.deleteInput,
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        $.blockUI(blockUIOptions);
                        ajaxOpen({
                            url: "${inputUrl}",
                            formSelector: "#createUpdateProcessForm",
                            event: "delete",
                            containerSelector: "#inputListContainer",
                            ajaxOptions: {global: false}, // prevent blockUI being called 2 times. Called manually.
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${processUrl}",
                                    event: "list",
                                    containerSelector: "#processesListContainer",
                                    ajaxOptions: {global: false},
                                    successAfterContainerFill: function() {
                                        $("#inputContainer").dialog("close");
                                        $.unblockUI(unblockUIOptions);
                                    }
                                });
                            }
                        });
                    }
                }
            }));

            return defaultButtonClick(this);
        });

    });
</script>

<stripes:form partial="true" action="#">
    <div>
        <h1><fmt:message key="process.selectInput"/></h1>
    </div>
    <div id="inputListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/input/list.jsp" %>
    </div>
    <div class="crudButtonsArea">
        <stripes:button id="createInputDB" name="createInputDB"/>
        <stripes:button id="createInputFile" name="createInputFile"/>
        <stripes:button id="updateInput" name="update"/>
        <stripes:button id="deleteInput" name="delete"/>
    </div>
</stripes:form>