<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    console.log("tad");
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
            console.log("succesaftercontainerfille");
        }
    };

    $(document).ready(function() {
    console.log("document ready");
        $("#publish").click(function() {
            console.log("sdf");
            ajaxOpen({
                url: "${outputServicesUrl}",
                event: "publish",
                containerId: "dbContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, recalculateNewUpdateDBCommonDialogOptions(), {
                    title: "<fmt:message key="publishOutput"/>"
                })
            });

          //  return defaultButtonClick(this);
        })

    });
</script>


<stripes:form partial="true" action="#">
    <div>
        <h1><fmt:message key="inputDB.selectDB"/></h1>
    </div>
    <div id="databasesListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/output_services/list.jsp" %>
    </div>
    <div class="crudButtonsArea">
        <stripes:button id="publish" name="publish"/>
    </div>
</stripes:form>
