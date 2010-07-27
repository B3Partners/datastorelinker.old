<%-- 
    Document   : create
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="inputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>
<stripes:url var="outputUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.OutputAction"/>
<stripes:url var="processUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction"/>

<script type="text/javascript">
    $(document).ready(function() {
        $("#createProcessBackButton, #createProcessNextButton").button();

        $("#createInputDB, #createInputFile, #updateInput, #deleteInput").button();
        $("#createOutput, #updateOutput, #deleteOutput").button();

        $("#radioNoDrop").removeAttr("checked");
        $("#radioDrop").attr("checked", "checked");
        <c:if test="${not empty actionBean.drop and actionBean.drop == false}">
            $("#radioDrop").removeAttr("checked");
            $("#radioNoDrop").attr("checked", "checked");
        </c:if>

        initActionsList(
            <c:out value="${actionBean.actionsList}" escapeXml="false"/>,
            "${contextPath}"
        );
        
        $("#createUpdateProcessForm").bind("step_shown", function(event, data) {
            formWizardStep(data);

            $("#processContainer").layout(defaultDialogLayoutOptions);
            $("#processSteps").layout(defaultDialogLayoutOptions).destroy();
            
            if (data.previousStep)
                $("#" + data.previousStep).removeClass("ui-layout-center");
            $("#" + data.currentStep).addClass("ui-layout-center");

            $("#processSteps").layout(defaultDialogLayoutOptions).initContent("center");

            // layout plugin messes up z-indices; sets them to 1
            var topZIndexCss = { "z-index": "auto" };
            $("#processContainer, #processSteps, #inputContainer .wizardButtonsArea").css(topZIndexCss);
            $("#" + data.currentStep).css(topZIndexCss);

            if (data.currentStep === "Overzicht") {
                var inputText = $("#inputListContainer .ui-state-active .ui-button-text").html();
                $("#inputOverviewContainer").html(inputText);
                var outputText = $("#outputListContainer .ui-state-active .ui-button-text").html();
                $("#outputOverviewContainer").html(outputText);
            }
        });

        $("#createUpdateProcessForm").formwizard(
            // form wizard settings
            $.extend({}, formWizardConfig, {
                formOptions: {
                    beforeSend: function() {
                        var actionsListJson = JSON.stringify(getActionsList());

                        ajaxOpen({
                            formSelector: "#createUpdateProcessForm",
                            event: "createComplete",
                            containerSelector: "#processesListContainer",
                            extraParams: [{
                                name: "actionsList",
                                value: actionsListJson
                            }],
                            successAfterContainerFill: function() {
                                $("#processContainer").dialog("close");
                            }
                        });
                        // prevent regular ajax submit:
                        return false;
                    }
                }
            })
        );

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

        var newUpdateOutputCommonDialogOptions = $.extend({}, defaultDialogOptions, {
            width: 550,
            height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : function() {
                    testConnection({
                        url: "${outputUrl}",
                        formSelector: "#postgisForm",
                        event: "createComplete",
                        containerSelector: "#outputListContainer",
                        successAfterContainerFill: function() {
                            $("#outputContainer").dialog("close");
                        }
                    });
                }
            }
        });

        $("#createInputDB").click(function() {
            ajaxOpen({
                url: "${inputUrl}",
                event: "createDatabaseInput",
                containerId: "inputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateInputCommonDialogOptions, {
                    title: "<fmt:message key="newDatabaseInput"/>"
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
                    title: "<fmt:message key="newFileInput"/>"
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
                    title: "<fmt:message key="editInput"/>"
                })
            });

            return defaultButtonClick(this);
        });

        $("#deleteInput").click(function() {
            if (!$("#createUpdateProcessForm").valid())
                return defaultButtonClick(this);

            $("<div><fmt:message key="deleteInputAreYouSure"/></div>").attr("id", "inputContainer").appendTo(document.body);

            $("#inputContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "<fmt:message key="deleteInput"/>",
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
                            ajaxOptions: {globals: false}, // prevent blockUI being called 2 times. Called manually.
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${processUrl}",
                                    event: "list",
                                    containerSelector: "#processesListContainer",
                                    ajaxOptions: {globals: false},
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

        $("#createOutput").click(function() {
            ajaxOpen({
                url: "${outputUrl}",
                event: "create",
                containerId: "outputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateOutputCommonDialogOptions, {
                    title: "<fmt:message key="newDatabaseOutput"/>"
                })
            });

            return defaultButtonClick(this);
        })

        $("#updateOutput").click(function() {
            ajaxOpen({
                url: "${outputUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "update",
                containerId: "outputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateOutputCommonDialogOptions, {
                    title: "<fmt:message key="editOutput"/>"
                })
            });

            return defaultButtonClick(this);
        })

        $("#deleteOutput").click(function() {
            if (!$("#createUpdateProcessForm").valid())
                return defaultButtonClick(this);

            $("<div><fmt:message key="deleteOutputAreYouSure"/></div>").attr("id", "outputContainer").appendTo($(document.body));

            $("#outputContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "<fmt:message key="deleteOutput"/>",
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        ajaxOpen({
                            url: "${outputUrl}",
                            formSelector: "#createUpdateProcessForm",
                            event: "delete",
                            containerSelector: "#outputListContainer",
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${processUrl}",
                                    event: "list",
                                    containerSelector: "#processesListContainer",
                                    successAfterContainerFill: function() {
                                        $("#outputContainer").dialog("close");
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

<div id="actionsListMetadata"></div>

<stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <!-- wizard-fields nodig voor bewerken van een proces: selectedProcessId wordt dan meegenomen -->
    <stripes:wizard-fields/>
    <div id="processSteps" class="ui-layout-center">
        <div id="<fmt:message key="process.selectInput.short"/>" class="step ui-layout-center">
            <h1><fmt:message key="process.selectInput"/></h1>
            <div id="inputListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
                <%@include file="/pages/main/input/list.jsp" %>
            </div>
            <div class="crudButtonsArea">
                <stripes:button id="createInputDB" name="createInputDB"/>
                <stripes:button id="createInputFile" name="createInputFile"/>
                <stripes:button id="updateInput" name="update"/>
                <stripes:button id="deleteInput" name="delete"/>
            </div>
        </div>
        <div id="<fmt:message key="process.selectOutput.short"/>" class="step">
            <h1><fmt:message key="process.selectOutput"/></h1>
            <div id="outputListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
                <%@include file="/pages/main/output/list.jsp" %>
            </div>
            <div class="crudButtonsArea">
                <div>
                    <stripes:button id="createOutput" name="create"/>
                    <stripes:button id="updateOutput" name="update"/>
                    <stripes:button id="deleteOutput" name="delete"/>
                </div>
                <div style="margin-top: 1em">
                    <div>
                        <input type="radio" name="drop" id="radioDrop" value="true" checked="checked"/>
                        <stripes:label name="outputDrop" for="radioDrop"/>
                    </div>
                    <div>
                        <input type="radio" name="drop" id="radioNoDrop" value="false"/>
                        <stripes:label name="outputNoDrop" for="radioNoDrop"/>
                    </div>
                </div>
            </div>
        </div>
        <div id="<fmt:message key="process.overview.short"/>" class="step submit_step">
            <h1><fmt:message key="process.overview"/></h1>
            <div class="ui-layout-content">
                <%@include file="/pages/main/overview/view.jsp" %>
            </div>
        </div>
    </div>
    <div class="ui-layout-south wizardButtonsArea">
        <stripes:reset id="createProcessBackButton" name="resetDummyName"/>
        <stripes:submit id="createProcessNextButton" name="createComplete"/>
    </div>
</stripes:form>