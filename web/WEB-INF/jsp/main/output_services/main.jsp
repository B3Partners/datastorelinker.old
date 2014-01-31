<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">

/* Event wordt aangeroepen in back-end als form is ingevuld */
        var nieuwServiceOptions = $.extend({}, defaultDialogOptions, {            
            width: 550,
            formSelector: ".form-container .ui-accordion-content-active form",
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>": function() {
                   /* if (!validateForm()) {
                        return;
                    }
*/
                    ajaxOpen({
                        url: "${outputServicesUrl}",
                        event: "createComplete",
                        extraParams: [
                            {name: "serviceUser", value: $("#serviceUser").val()},
                            {name: "servicePassword", value: $("#servicePassword").val()},
                            {name: "url", value: $("#url").val()},
                            {name: "style", value: $("#style").val()},
                            {name: "selectedDatabaseId", value: $("#selectedDatabaseId").val()},
                            {name: "publisherType", value: $("#publisherType").val()}
                        ],
                        containerSelector: "#databasesListContainer",
                        successAfterContainerFill: function(data, textStatus, xhr) {
                            $("#publishDialogContainer").dialog("close");
                        }
                    });
                }
            }
        });
        
    $(document).ready(function() {
        $("#publish").click(function() {
           var database = $("#createInputForm .ui-state-active").prevAll("input").first()
         ajaxOpen({
                url: "${outputServicesUrl}",
                event: "publish",
                containerId: "publishDialogContainer",
                extraParams: [{
                         name: "selectedDatabaseId",
                        value: database.val()}
                    ],
                openInDialog: true,
                dialogOptions: $.extend({}, nieuwServiceOptions, {
                title: "<fmt:message key="publishOutput"/>"
                                })
                });

                return defaultButtonClick(this);

            });
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
