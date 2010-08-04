<%-- 
    Document   : create
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>
<%@include file="/pages/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        initInput();
        initOutput();

        $("#createProcessBackButton, #createProcessNextButton").button();

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
    });
</script>

<div id="actionsListMetadata"></div>

<stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <!-- wizard-fields nodig voor bewerken van een proces: selectedProcessId wordt dan meegenomen -->
    <stripes:wizard-fields/>
    <div id="processSteps" class="ui-layout-center">
        <div id="<fmt:message key="process.selectInput.short"/>" class="step ui-layout-center">
            <%@include file="/pages/main/input/main.jsp" %>
        </div>
        <div id="<fmt:message key="process.selectOutput.short"/>" class="step">
            <%@include file="/pages/main/output/main.jsp" %>
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