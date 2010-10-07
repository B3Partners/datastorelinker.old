<%-- 
    Document   : main
    Created on : 3-aug-2010, 20:00:28
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        var classesUsed = "ui-layout-content mandatory-form-input";
        var layoutContentClass = "ui-layout-content";
        //var classesUsed = "mandatory-form-input";

        var tabLayout = null;
        var inputTabsLayout = null;
        var processStepsLayout = null;

        $("#inputList, #filesListContainer").css({
            /*height: "100%",
            position: "relative",
            overflow: "scroll"*/
        });

        $("#inputList").addClass(classesUsed);
        
        $("#inputTabs").tabs({
            /*fx: {
                opacity: "toggle"
            },*/
            select: function(event, ui) {
                //log("tabselect");
            },
            show: function(event, ui) {
                //log("tabshow");
                //log(ui);

                if (!!tabLayout)
                    tabLayout.destroy();
                if (!!inputTabsLayout)
                    inputTabsLayout.destroy();
                if (!!processStepsLayout)
                    processStepsLayout.destroy();

                $("#" + ui.panel.id).addClass(layoutContentClass);
                $("#" + ui.panel.id + " input:radio").addClass("required");
                if (ui.panel.id === "databaseTab") {
                    $("#fileTab").removeClass(layoutContentClass);
                    $("#fileTab input:radio").removeClass("required");
                    $("#filesListContainer").removeClass(layoutContentClass);
                    $("#inputList").addClass(classesUsed);
                } else if (ui.panel.id === "fileTab") {
                    $("#databaseTab").removeClass(layoutContentClass);
                    $("#databaseTab input:radio").removeClass("required");
                    $("#inputList").removeClass(layoutContentClass);
                    $("#filesListContainer").addClass(classesUsed);
                }

                processStepsLayout = $("#processSteps").layout(inputDialogLayoutOptions);
                inputTabsLayout = $("#inputTabs").layout(inputDialogLayoutOptions);
                if (ui.panel.id === "databaseTab") {
                    tabLayout = $("#" + ui.panel.id).layout(inputDialogLayoutOptions);
                } else if (ui.panel.id === "fileTab") {
                    tabLayout = createDefaultVerticalLayout($("#" + ui.panel.id));
                }

                $("#SelecteerInvoer, .wizardButtonsArea, #inputTabs > *, #" + ui.panel.id + " > *").css("z-index", "auto");
            }
        });

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
    <div id="inputTabs" class="ui-layout-content">
        <ul class="ui-layout-north">
            <li>
                <a href="#databaseTab"><fmt:message key="process.databaseInput"/></a>
            </li>
            <li>
                <a href="#fileTab"><fmt:message key="process.fileInput"/></a>
            </li>
        </ul>
        <div class="ui-layout-center">
            <div id="databaseTab">
                <%@include file="/WEB-INF/jsp/main/input/database/main.jsp" %>
            </div>
            <div id="fileTab">
                <%@include file="/WEB-INF/jsp/main/file/main.jsp" %>
            </div>
        </div>
    </div>
</stripes:form>