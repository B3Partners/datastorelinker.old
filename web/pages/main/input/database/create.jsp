<%--
    Document   : create
    Created on : 3-mei-2010, 18:03:12
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="databaseUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction"/>
<stripes:url var="inputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>
<stripes:url var="processUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction"/>

<script type="text/javascript">

    connectionSuccessInputDBAjaxOpenOptions = {
        formSelector: ".form-container .ui-accordion-content-active form",
        event: "createComplete",
        containerSelector: "#databasesListContainer",
        successAfterContainerFill: function(data, textStatus, xhr) {
            $("#dbContainer").dialog("close");
        }
    }

    $(document).ready(function() {
        $("#createDB").button();
        $("#updateDB").button();
        $("#deleteDB").button();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        $("#createInputForm").bind("step_shown", function(event, data) {
            formWizardStep(data);

            $("#inputContainer").layout(defaultDialogLayoutOptions);
            $("#inputSteps").layout(defaultDialogLayoutOptions).destroy();

            if (data.previousStep)
                $("#" + data.previousStep).removeClass("ui-layout-center");
            $("#" + data.currentStep).addClass("ui-layout-center");

            $("#inputSteps").layout(defaultDialogLayoutOptions).initContent("center");

            // layout plugin messes up z-indices; sets them to 1
            var topZIndexCss = { "z-index": "auto" };
            $("#inputContainer, #inputSteps, #inputContainer .wizardButtonsArea").css(topZIndexCss);
            $("#" + data.currentStep).css(topZIndexCss);

            if (data.currentStep === "SelecteerTabel") {
                var database = $("#createInputForm .ui-state-active").prevAll("input").first();
                ajaxOpen({
                    formSelector: "#createInputForm",
                    event: "createTablesList",
                    extraParams: [{
                        name: "selectedDatabaseId",
                        value: database.val()
                    }],
                    containerSelector: "#tablesListContainer"
                });
            }
        });

        $("#createInputForm").formwizard(
            $.extend({}, formWizardConfig, {
                formOptions: {
                    beforeSend: function() {
                        ajaxOpen({
                            formSelector: "#createInputForm",
                            event: "createDatabaseInputComplete",
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

        var newUpdateDBCommonDialogOptions = $.extend({}, defaultDialogOptions, {
            width: 700,
            height: 600,
            buttons: {
                "<fmt:message key="finish"/>" : function() {
                    testConnection(connectionSuccessInputDBAjaxOpenOptions);
                }
            }
        });

        $("#createDB").click(function() {
            ajaxOpen({
                url: "${databaseUrl}",
                event: "create",
                containerId: "dbContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateDBCommonDialogOptions, {
                    title: "<fmt:message key="newDatabase"/>"
                })
            });

            return defaultButtonClick(this);
        })

        $("#updateDB").click(function() {
            ajaxOpen({
                url: "${databaseUrl}",
                formSelector: "#createInputForm",
                event: "update",
                containerId: "dbContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateDBCommonDialogOptions, {
                    title: "<fmt:message key="editDatabase"/>"
                })
            });

            return defaultButtonClick(this);
        })

        $("#deleteDB").click(function() {
            if (!$("#createInputForm").valid())
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
                            url: "${databaseUrl}",
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


<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <stripes:wizard-fields/>
    <div id="inputSteps" class="ui-layout-center">
        <div id="<fmt:message key="inputDB.selectDB.short"/>" class="step ui-layout-center">
            <h1><fmt:message key="inputDB.selectDB"/></h1>
            <div id="databasesListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
                <%@include file="/pages/main/database/list.jsp" %>
            </div>
            <div class="crudButtonsArea">
                <stripes:button id="createDB" name="create"/>
                <stripes:button id="updateDB" name="update"/>
                <stripes:button id="deleteDB" name="delete"/>
            </div>
        </div>
        <div id="<fmt:message key="inputDB.selectTable.short"/>" class="step submitstep">
            <h1><fmt:message key="inputDB.selectTable"/></h1>
            <fmt:message key="inputDB.tablesFitAsInput"/>
            <div id="tablesListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
            </div>
        </div>
    </div>

    <div class="wizardButtonsArea ui-layout-south">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createDatabaseInputComplete"/>
    </div>
</stripes:form>
