<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    function recalculateNewUpdateInputCommonDialogOptions() {
        return $.extend({}, defaultDialogOptions, {
            width: calculateDialogWidth(65, 500, 800),
            height: calculateDialogHeight(60, 400),
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
    }
    
    $(document).ready(function() {
        $("#createInputDB").click(function() {
            ajaxOpen({
                url: "${outputNewUrl}",
                event: "createDatabaseInput",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, recalculateNewUpdateInputCommonDialogOptions(), {
                    title: I18N.newDatabaseOutput
                })
            });

            return defaultButtonClick(this);
        });

        $("#updateInput").click(function() {
            ajaxOpen({
                url: "${outputNewUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "update",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, recalculateNewUpdateInputCommonDialogOptions(), {
                    title: I18N.editOutput
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
                            url: "${outputNewUrl}",
                            formSelector: "#createUpdateProcessForm",
                            event: "delete",
                            containerSelector: "#inputListContainer",
                            ajaxOptions: {global: false}, // prevent blockUI being called 2 times. Called manually.
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${outputNewUrl}",
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
    <div id="databaseInputHeader" class="ui-layout-north">
    </div>
    <div id="inputListContainer" class="mandatory-form-input ui-layout-center radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/output_new/database/list.jsp" %>
    </div>
    <div class="ui-layout-south crudButtonsArea">
        <stripes:button id="createInputDB" name="create"/>
        <stripes:button id="updateInput" name="update"/>
        <stripes:button id="deleteInput" name="delete"/>
    </div>
</stripes:form>