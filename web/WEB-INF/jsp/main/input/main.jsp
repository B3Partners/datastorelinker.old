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

        var selectedTab = 0;
        if (!!"${actionBean.selectedFilePath}") {
            selectedTab = 1;
        }

        $("#inputList").addClass(classesUsed);
        
        $("#inputTabs").tabs({
            /*fx: {
                opacity: "toggle"
            },*/
            select: function(event, ui) {
                //log("tabselect");
            },
            selected: selectedTab,
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