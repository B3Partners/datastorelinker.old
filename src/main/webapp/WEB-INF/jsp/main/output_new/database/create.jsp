<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initDatabase();
        
        $("#createInputBackButton, #createInputNextButton").button();

        $("#createInputForm").bind("step_shown", function(event, data) {
            formWizardStep(data);

            $("#inputContainer").layout(defaultDialogLayoutOptions);
            $("#inputSteps").layout(defaultDialogLayoutOptions).destroy();

            if (data.previousStep)
                $("#" + data.previousStep).removeClass("ui-layout-center");
            $("#" + data.currentStep).addClass("ui-layout-center");

            //$("#inputContainer").layout(defaultDialogLayoutOptions);
            $("#inputSteps").layout(defaultDialogLayoutOptions);//.initContent("center");

            // layout plugin messes up z-indices; sets them to 1
            var topZIndexCss = { "z-index": "auto" }; 
            // z-index auto disabled input fields in IE7
            if($.browser.msie && $.browser.version <= 7) {
                topZIndexCss = { "z-index": "2100" };
            }
            
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

    });

</script>


<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.OutputActionNew">
    <stripes:wizard-fields/>
    <div id="inputSteps" class="ui-layout-center">
        <div id="SelecteerDatabaseconnectie" class="step ui-layout-center">
            <%@include file="/WEB-INF/jsp/main/database_out/main.jsp" %>
        </div>
        <div id="SelecteerTabel" class="step submitstep">
            <div>
                <h1><fmt:message key="output.db.selectTable"/></h1>
                
                <p><fmt:message key="keys.seltypetbl"/></p>
                <p>
                Type: <stripes:select name="selectedTemplateOutput">
                        <stripes:option value="USE_TABLE"><fmt:message key="keys.type1"/></stripes:option>
                        <stripes:option value="AS_TEMPLATE"><fmt:message key="keys.type2"/></stripes:option>
                        <stripes:option value="NO_TABLE"><fmt:message key="keys.type3"/></stripes:option>
                    </stripes:select>
                </p>
                
                <!-- <div><fmt:message key="output.tablesFitAsInput"/></div> -->
            </div>
                
            <div id="tablesListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
            </div>
        </div>
    </div>

    <div class="wizardButtonsArea ui-layout-south">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createDatabaseInputComplete"/>
    </div>
</stripes:form>
