<%-- 
    Document   : create
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<script type="text/javascript">

    inputDialogLayoutOptions = $.extend({}, defaultDialogLayoutOptions, {
        center__findNestedContent: true
    });

    $(document).ready(function() {
        initInput();
        initOutput();

        $("#createProcessBackButton, #createProcessNextButton").button();

        initActionsList(
            <c:out value="${actionBean.actionsList}" escapeXml="false"/>,
            "${contextPath}"
        );
        
        $("#createUpdateProcessForm").bind("step_shown", function(event, data) {
            //log("step_shown");
            formWizardStep(data);

            initGuiInput();
            initGuiOutput();

            $("#processContainer").layout(defaultDialogLayoutOptions);
            if (data.currentStep === "SelecteerInvoer") {
                $("#processSteps").layout(inputDialogLayoutOptions).destroy();
            } else {
                $("#processSteps").layout(defaultDialogLayoutOptions).destroy();
            }
            
            if (data.previousStep)
                $("#" + data.previousStep).removeClass("ui-layout-center");
            $("#" + data.currentStep).addClass("ui-layout-center");

            if (data.currentStep === "SelecteerInvoer") {
                $("#processSteps").layout(inputDialogLayoutOptions).initContent("center");
            } else {
                $("#processSteps").layout(defaultDialogLayoutOptions).initContent("center");
            }

            // layout plugin messes up z-indices; sets them to 1
            var topZIndexCss = { "z-index": "auto" };
            $("#processContainer, #processSteps, #inputContainer .wizardButtonsArea").css(topZIndexCss);
            $("#" + data.currentStep).css(topZIndexCss);

            if (data.currentStep === "Overzicht") {
                var inputText = "";
                if ($("#inputTabs").tabs("option", "selected") === 0) {
                    inputText = $("#inputListContainer .ui-state-active .ui-button-text").html();
                } else {
                    inputText = $("#filesListContainer input:radio:checked").val();
                }
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

                        if ($("#inputTabs").tabs("option", "selected") === 0) {
                            $("#createUpdateProcessForm input[name='selectedFilePath']").attr("checked", false);
                        } else {
                            $("#createUpdateProcessForm input[name='selectedInputId']").attr("checked", false);
                        }

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
                },
                validationOptions: $.extend({}, defaultValidateOptions, {
                    errorPlacement: function(error, element) {
                        var state = $("#createUpdateProcessForm").formwizard("state");
                        if (state["currentStep"] !== "SelecteerInvoer") {
                            defaultFormWizardValidateOptions.errorPlacement(error, element);
                        } else {
                            if (error.length > 0 && error.text() != "") {
                                if ($("#inputTabs").tabs("option", "selected") === 0) {
                                    $("#databaseInputHeader").append(error);
                                    $("#databaseTab").layout().resizeAll();
                                } else {
                                    $("#fileHeader").append(error);
                                    $("#fileTab").layout().resizeAll();
                                }
                            }
                        }
                    },
                    success: function(label) {
                        var state = $("#createUpdateProcessForm").formwizard("state");
                        if (state["currentStep"] !== "SelecteerInvoer") {
                            defaultFormWizardValidateOptions.success(label);
                        } else {
                            if (label.length > 0 && label.parent().length > 0) {
                                label.remove();
                                if ($("#inputTabs").tabs("option", "selected") === 0) {
                                    $("#databaseTab").layout().resizeAll();
                                } else {
                                    $("#fileTab").layout().resizeAll();
                                }
                            }
                        }
                    }
                })
            })
        );
    });
</script>

<div id="actionsListMetadata"></div>

<stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <!-- wizard-fields nodig voor bewerken van een proces: selectedProcessId wordt dan meegenomen -->
    <stripes:wizard-fields/>
    <div id="processSteps" class="ui-layout-center">
        <div id="<fmt:message key="process.selectInput.short"/>" class="step ui-layout-center">
            <%@include file="/WEB-INF/jsp/main/input/main.jsp" %>
        </div>
        <div id="<fmt:message key="process.selectOutput.short"/>" class="step">
            <%@include file="/WEB-INF/jsp/main/output/main.jsp" %>
        </div>
        <div id="<fmt:message key="process.overview.short"/>" class="step submit_step">
            <h1><fmt:message key="process.overview"/></h1>
            <div class="ui-layout-content">
                <%@include file="/WEB-INF/jsp/main/overview/view.jsp" %>
            </div>
        </div>
    </div>
    <div class="ui-layout-south wizardButtonsArea">
        <stripes:reset id="createProcessBackButton" name="resetDummyName"/>
        <stripes:submit id="createProcessNextButton" name="createComplete"/>
    </div>
</stripes:form>