<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<script type="text/javascript" class="ui-layout-ignore">

    function getId() {
        var ids = new Array();
        $.each($("input[name = selectedTable]:checked"), function(index, val) {
            ids.push(val.value);
        });
        return ids.toString();
    }
    
    function validateForm(){
        $("#msgTables").html("");
        if(getId() === ""){
            $("#msgTables").html("<fmt:message key="keys.seltbl"/>");
            return false;
        }else{
            return true;
        }
    }
        /* Event wordt aangeroepen in back-end als form is ingevuld */
    var nieuwServiceOptions = $.extend({}, defaultDialogOptions, {
        width: 550,
        height: 500,
        formSelector: ".form-container .ui-accordion-content-active form",
        buttons: {
            "<fmt:message key="finish"/>": function() {
                if (!validateForm()) {
                    return;
                }

                ajaxOpen({
                    url: "${outputServicesUrl}",
                    event: "createComplete",
                    extraParams: [
                        {name: "selectedTables", value: getId()},
                        {name: "selectedDatabaseId", value: $("#selectedDatabaseId").val()},
                        {name: "publisherType", value: $("#publisherType").val()},
                        {name: "namePublisher", value: $("#namePublisher").val()}
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
            var database = $("#createInputForm .ui-state-active").prevAll("input").first();
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
