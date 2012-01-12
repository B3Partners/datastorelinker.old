<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    function recalculateNewUpdateDBCommonDialogOptions() {
        return $.extend({}, defaultDialogOptions, {
            width: calculateDialogWidth(70, 500, 700),
            //height: 600,
            buttons: {
                "<fmt:message key="finish"/>" : function() {
                    testConnection(connectionSuccessInputDBAjaxOpenOptions);
                }
            }
        });
    }
    
    connectionSuccessInputDBAjaxOpenOptions = {
        formSelector: ".form-container .ui-accordion-content-active form",
        event: "createComplete",
        containerSelector: "#databasesListContainer",
        successAfterContainerFill: function(data, textStatus, xhr) {
            $("#dbContainer").dialog("close");
        }
    }

    $(document).ready(function() {
        $("#createDB").click(function() {
            ajaxOpen({
                url: "${databaseOutUrl}",
                event: "create",
                containerId: "dbContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, recalculateNewUpdateDBCommonDialogOptions(), {
                    title: "<fmt:message key="newDatabase"/>"
                })
            });

            return defaultButtonClick(this);
        })

        $("#updateDB").click(function() {
            ajaxOpen({
                url: "${databaseOutUrl}",
                formSelector: "#createInputForm",
                event: "update",
                containerId: "dbContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, recalculateNewUpdateDBCommonDialogOptions(), {
                    title: "<fmt:message key="editDatabase"/>"
                })
            });

            return defaultButtonClick(this);
        })

        $("#deleteDB").click(function() {
            if (!isFormValidAndContainsInput("#createInputForm"))
                return defaultButtonClick(this);

            $("<div><fmt:message key="deleteDatabaseAreYouSure"/></div>").attr("id", "dbContainer").appendTo($(document.body));

            $("#dbContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "<fmt:message key="deleteDatabase"/>",
                width: 350,
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        $.blockUI(blockUIOptions);
                        ajaxOpen({
                            url: "${databaseOutUrl}",
                            formSelector: "#createInputForm",
                            event: "delete",
                            containerSelector: "#databasesListContainer",
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
                                                $("#dbContainer").dialog("close");
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

            return defaultButtonClick(this);
        });

    });
</script>


<stripes:form partial="true" action="#">
    <div>
        <h1><fmt:message key="inputDB.selectDB"/></h1>
    </div>
    <div id="databasesListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/database_out/list.jsp" %>
    </div>
    <div class="crudButtonsArea">
        <stripes:button id="createDB" name="create"/>
        <stripes:button id="updateDB" name="update"/>
        <stripes:button id="deleteDB" name="delete"/>
    </div>
</stripes:form>
