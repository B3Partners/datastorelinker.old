<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() { 
        /* Event wordt aangeroepen in back-end als form is ingevuld */
        var updateOrgDialogOptions = $.extend({}, defaultDialogOptions, {
            width: 550,
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : function() {                    
                    var selectedOutputId = $("#orgListContainer :radio:checked").val();
                    var organizationIds = $("#organizationIds").val();
                    
                    if (organizationIds === null){
                    
                        $("#msgOrgIdError").html("<fmt:message key="keys.selorgs"/>");
                        return;
        }
                    
                    ajaxOpen({
                        url: "${outputRightsUrl}",
                        event: "createOutputRightsComplete",
                        extraParams: [
                            {name: "selectedOutputId", value: selectedOutputId},
                            {name: "organizationIds", value: organizationIds}
                        ],
                        containerSelector: "#orgListContainer",
                        successAfterContainerFill: function(data, textStatus, xhr) {
                            $("#orgContainer").dialog("close");
                        }                    
                    });
                }
            }
        });

        /* Als er op bewerken geklikt wordt */
        $("#updateOutputRights").click(function() {
            var selectedOutputId = $("#orgListContainer :radio:checked").val();
            
            if (!selectedOutputId) {
                return;
            }
            
            ajaxOpen({
                url: "${outputRightsUrl}",
                event: "updateOutputRights",
                containerId: "orgContainer",
                extraParams: [
                    {name: "selectedOutputId", value: selectedOutputId}
                ],
                openInDialog: true,
                dialogOptions: $.extend({}, updateOrgDialogOptions, {
                    title: "<fmt:message key="editOutputRights"/>"
                })
            });

            return defaultButtonClick(this);
        })    
    });
</script>

<stripes:form partial="true" action="#">
    <div>
        <h1><fmt:message key="output.rights.selectOutput"/></h1>
    </div>
    <div id="orgListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/output_rights/list.jsp" %>
    </div>
    <div class="crudButtonsArea">
        <div>
            <stripes:button id="updateOutputRights" name="update"/>
        </div>        
    </div>
</stripes:form>