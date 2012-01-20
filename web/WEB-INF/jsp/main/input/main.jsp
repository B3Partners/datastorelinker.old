<%-- 
    Document   : main
    Created on : 3-aug-2010, 20:00:28
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        var classesUsed = "ui-layout-content mandatory-form-input";
        var layoutContentClass = "ui-layout-content";

        $("#inputList, #filesListContainer").css({
            /*height: "100%",
            position: "relative",
            overflow: "scroll"*/
        });

        var selectedTab = 0;
        if (!!"${actionBean.selectedFilePath}") {
            selectedTab = 1;
        }

        $("#inputListContainer").addClass(classesUsed);
        
        $("#inputTabs").tabs({
            /*fx: {
                opacity: "toggle"
            },*/
            select: function(event, ui) {
            },
            selected: selectedTab,
            show: function(event, ui) {
                if (layouts.tabs)
                    layouts.tabs.destroy();
                if (layouts.inputTabs)
                    layouts.inputTabs.destroy();
                if (layouts.processSteps)
                    layouts.processSteps.destroy();

                $("#" + ui.panel.id).addClass(layoutContentClass);
                $("#" + ui.panel.id + " input:radio").addClass("required");
                if (ui.panel.id === "databaseTab") {
                    $("#fileTab").removeClass(layoutContentClass);
                    $("#fileTab input:radio").removeClass("required");
                    $("#filesListContainer").removeClass(classesUsed);
                    $("#inputListContainer").addClass(classesUsed);
                } else if (ui.panel.id === "fileTab") {
                    $("#databaseTab").removeClass(layoutContentClass);
                    $("#databaseTab input:radio").removeClass("required");
                    $("#inputListContainer").removeClass(classesUsed);
                    $("#filesListContainer").addClass(classesUsed);
                }

                layouts.processSteps = $("#processSteps").layout(inputDialogLayoutOptions);
                layouts.inputTabs = $("#inputTabs").layout(inputDialogLayoutOptions);
                if (ui.panel.id === "databaseTab") {
                    layouts.tabs = $("#" + ui.panel.id).layout(inputDialogLayoutOptions);
                } else if (ui.panel.id === "fileTab") {
                    layouts.tabs = createDefaultVerticalLayout($("#" + ui.panel.id));
                }

                $("#SelecteerInvoer, .wizardButtonsArea, #inputTabs > *, #" + ui.panel.id + " > *").css("z-index", "auto");
            }
        });

        $("#uploadFile, #deleteFile, #uploader").removeClass("ui-state-default ui-helper-reset");
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