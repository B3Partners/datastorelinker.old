<%-- 
    Document   : create
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    if (!window.layouts) {
        window.layouts = {};
    }

    inputDialogLayoutOptions = $.extend({}, defaultDialogLayoutOptions, {
        center__findNestedContent: true
    });

    $(document).ready(function() {
        //log("docready");
        initInput();
        initOutput();

        $("#createProcessBackButton, #createProcessNextButton").button();

        initActionsList(
    <c:out value="${actionBean.actionsList}" escapeXml="false"/>,
                "${contextPath}"
                );

        $("#createUpdateProcessForm").children("div:last").addClass("ui-layout-ignore");
        $("#createUpdateProcessForm").bind("step_shown", function(event, data) {
            formWizardStep(data);

            initGuiInput();
            initGuiOutput();

            layouts.processContainer = $("#processContainer").layout(defaultDialogLayoutOptions);
            if (layouts.processSteps)
                layouts.processSteps.destroy();

            if (data.previousStep && data.previousStep !== data.currentStep)
                $("#" + data.previousStep).removeClass("ui-layout-center");
            $("#" + data.currentStep).addClass("ui-layout-center");

            $("#" + data.previousStep).hide();
            if (data.previousStep === "SelecteerInvoer" && data.currentStep !== "SelecteerInvoer") {
                getColumnsNames();
            } else if (data.previousStep === "SelecteerUitvoer" && data.currentStep !== "SelecteerUitvoer") {
                getColumnsNamesOutput();
            } else if (data.previousStep === "Overzicht") {
                overviewLayoutDestroy();
            }

            $("#" + data.currentStep).show();
            if (data.currentStep === "SelecteerInvoer") {
                layouts.processSteps = $("#processSteps").layout(inputDialogLayoutOptions);
                // overige layout init van SelecteerInvoer in tabs.show.
            } else if (data.currentStep === "SelecteerUitvoer") {
                layouts.processSteps = $("#processSteps").layout(defaultDialogLayoutOptions);
            } else if (data.currentStep === "Overzicht") {
                layouts.processSteps = $("#processSteps").layout(defaultDialogLayoutOptions);
                overviewLayoutCreate();

                var outputText = $("#outputListContainer .ui-state-active .ui-button-text").html();
                $("#outputOverviewContainer .titleContainer").html(outputText);
            }

            // layout plugin messes up z-indices; sets them to 1
            var topZIndexCss = {"z-index": "auto"};
            // z-index auto disabled input fields in IE7
            if ($.browser.msie && $.browser.version <= 7) {
                topZIndexCss = {"z-index": "2100"};
            }

            $("#processContainer, #processSteps, #inputContainer .wizardButtonsArea").css(topZIndexCss);
            $("#" + data.currentStep).css(topZIndexCss);
        });

        $("#createUpdateProcessForm").formwizard(
                // form wizard settings
                $.extend({}, formWizardConfig, {
                    formOptions: {
                        beforeSend: function() {
                            var actionsListJson = JSON.stringify(getActionsList());

                            // 0 = tabelinvoer, 1 = bestandsinvoer
                            if ($("#inputTabs").tabs("option", "selected") === 0) {                                
                                if ($("#createUpdateProcessForm input[name='selectedFilePath']").length > 0) {                                    
                                    $("#createUpdateProcessForm input[name='selectedFilePath']").prop("checked", false);
                                    $("#createUpdateProcessForm input[name='selectedFilePath']").rules("add", {
                                        required: false
                                    }); 
                                }                                
                            } else {
                                $("#createUpdateProcessForm input[name='selectedInputId']").prop("checked", false);
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

    function getDefaultActionBlocks() {
        var params = {createDefaultActionBlocks: ""};

        blokken = $.ajax({
            url: "${processUrl}",
            data: params,
            dataType: "json",
            global: false
        }).done(function(columns) {
            initActionsList(columns, "${contextPath}");
        });
    }

    function getColumnsNames() {
        var inputText = "";
        if ($("#inputTabs").tabs("option", "selected") === 0) {
            inputText = $("#inputListContainer .ui-state-active .ui-button-text").html();
        } else {
            inputText = $("#filesListContainer input:radio:checked").val();
        }
        $("#inputOverviewContainer .titleContainer").html(inputText);
        $("#inputOverviewContainer .colsContainer").html('\
            <div class="ui-widget">\
                <div style="padding: 0 .7em;" class="ui-state-highlight ui-corner-all"> \
                    <p><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-info"></span>\
                    <strong><fmt:message key="keys.watchout"/></strong> <img src="${contextPath}/images/spinner.gif"/> <fmt:message key="keys.waitnoprocess"/></p>\
                </div>\
            </div>\
        ');

        var params = {getTypeNames: ""};
        if ($("#inputTabs").tabs("option", "selected") === 0) {
            params.selectedInputId = $("#inputListContainer input:radio:checked").val();
        } else {
            params.selectedFilePath = $("#filesListContainer input:radio:checked").val();
        }

        //setTimeout(function() {
        inputColumnNamesJqXhr = $.ajax({
            url: "${inputUrl}",
            data: params,
            dataType: "json",
            global: false,
            error: function(jqXHR, textStatus, errorThrown) {
                $("#inputOverviewContainer .colsContainer").html('\
                    <div class="ui-widget" style="margin: 0 .3em">\
                        <div style="padding: 0 .7em;" class="ui-state-error ui-corner-all"> \
                            <p><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span> \
                            <strong><fmt:message key="keys.watchout"/></strong> <fmt:message key="keys.stopnoprocess"/></p>\
                        </div>\
                    </div>\
                ');
                handleError(jqXHR, textStatus, errorThrown);
            }
        }).done(function(columns) {
            var colTable = $("<table>").css("width", "100%");
            var thead = $("<thead></thead>").append($("<tr>").append(
                    $("<td>", {text: "Attribuutnaam"}),
                    $("<td>", {text: "Attribuuttype"})
                    )).addClass("ui-widget-header action-list-header");
            colTable.append(thead);
            var tbody = $("<tbody></tbody>");
            $.each(columns, function(key, value) {
                var tdKey = $("<td>", {text: key});
                var tdValue = $("<td>", {text: value});
                tbody.append($("<tr>").append(tdKey, tdValue));
            });
            colTable.append(tbody);
            $("#inputOverviewContainer .colsContainer").html(colTable);
        });
        //}, 5000);
    }

    function getColumnsNamesOutput() {
        var inputText = "";

        inputText = $("#outputListContainer .ui-state-active .ui-button-text").html();

        $("#outputOverviewContainer .titleContainer").html(inputText);
        $("#outputOverviewContainer .colsContainer").html('\
            <div class="ui-widget">\
                <div style="padding: 0 .7em;" class="ui-state-highlight ui-corner-all"> \
                    <p><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-info"></span>\
                    <strong><fmt:message key="keys.watchout"/></strong> <img src="${contextPath}/images/spinner.gif"/> <fmt:message key="keys.waitnoprocess"/></p>\
                </div>\
            </div>\
        ');

        var params = {getTypeNames: ""};

        params.selectedOutputId = $("#outputListContainer input:radio:checked").val();

        outputColumnNamesJqXhr = $.ajax({
            url: "${outputNewUrl}",
            data: params,
            dataType: "json",
            global: false,
            error: function(jqXHR, textStatus, errorThrown) {
                $("#outputOverviewContainer .colsContainer").html('\
                    <div class="ui-widget" style="margin: 0 .3em">\
                        <div style="padding: 0 .7em;" class="ui-state-error ui-corner-all"> \
                            <p><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span> \
                            <fmt:message key="keys.noouttbl"/> \
                        </div>\
                    </div>\
                ');
                handleError(jqXHR, textStatus, errorThrown);
            }
        }).done(function(columns) {
            /* backend geeft null indien uitvoertemplate NO_TABLE is */
            if (columns) {
                var colTable = $("<table>").css("width", "100%");

                var thead = $("<thead></thead>").append($("<tr>").append(
                        $("<td>", {text: "Attribuutnaam"}),
                        $("<td>", {text: "Attribuuttype"})
                        )).addClass("ui-widget-header action-list-header");
                colTable.append(thead);
                var tbody = $("<tbody></tbody>");

                /* backend geeft null indien uitvoertemplate NO_TABLE is */
                if (columns) {
                    $.each(columns, function(key, value) {
                        var tdKey = $("<td>", {text: key});
                        var tdValue = $("<td>", {text: value});
                        tbody.append($("<tr>").append(tdKey, tdValue));
                    });
                }

                colTable.append(tbody);

                $("#outputOverviewContainer .colsContainer").html(colTable);
            } else {
                $("#outputOverviewContainer .titleContainer").html("<fmt:message key="keys.settbl"/>");

                var html = "<p><fmt:message key="keys.notbl"/></p>";
                $("#outputOverviewContainer .colsContainer").html(html);
            }

            /* Default blokken ophalen indien lijst nog leeg is */
    <c:if test="${actionBean.actionsList == '[]'}">
            getDefaultActionBlocks();
    </c:if>
        });
    }
</script>

<stripes:form id="createUpdateProcessForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">

    <div id="actionsListMetadata" class="ui-layout-ignore"></div>

    <!-- wizard-fields nodig voor bewerken van een proces: selectedProcessId wordt dan meegenomen -->
    <stripes:wizard-fields/>
    <div id="processSteps" class="ui-layout-center" style="height: 100%;">
        <div id="SelecteerInvoer" class="step ui-layout-center">
            <%@include file="/WEB-INF/jsp/main/input/main.jsp" %>
        </div>
        <div id="SelecteerUitvoer" class="step">
            <%@include file="/WEB-INF/jsp/main/output/main.jsp" %>
        </div>
        <div id="Overzicht" class="step submit_step">
            <%@include file="/WEB-INF/jsp/main/overview/view.jsp" %>
        </div>
    </div>
    <div class="ui-layout-south wizardButtonsArea">
        <stripes:reset id="createProcessBackButton" name="resetDummyName"/>
        <stripes:submit id="createProcessNextButton" name="createComplete"/>
    </div>
</stripes:form>