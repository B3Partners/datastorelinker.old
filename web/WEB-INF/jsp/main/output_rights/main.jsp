<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {        
        /* Event wordt aangeroepen in back-end als form is ingevuld */
        var newOrgDialogOptions = $.extend({}, defaultDialogOptions, {            
            width: 550,
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : function() {                    
                    ajaxOpen({
                        url: "${outputRightsUrl}",
                        event: "createOutputRightsComplete",
                        extraParams: [
                            {name: "orgName", value: $("#orgName").val()}
                        ],
                        containerSelector: "#orgListContainer",
                        successAfterContainerFill: function(data, textStatus, xhr) {
                            $("#orgContainer").dialog("close");
                        }                    
                    });
                }
            }
        });
        
        /* Event wordt aangeroepen in back-end als form is ingevuld */
        var updateOrgDialogOptions = $.extend({}, defaultDialogOptions, {
            width: 550,
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : function() {                    
                    var selectedOutputId = $("#orgListContainer :radio:checked").val();
                    var organizationIds = $("#organizationIds").val();
                    
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

        /* Als er op nieuw geklikt wordt */
        $("#createOutputRights").click(function() {            
            ajaxOpen({
                url: "${outputRightsUrl}",
                event: "createOrganization",
                containerId: "orgContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newOrgDialogOptions, {
                    title: "<fmt:message key="newAuthOrg"/>"
                })
            });

            return defaultButtonClick(this);
        })

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
        
        /* Als er op verwijder geklikt wordt */
        $("#deleteOutputRights").click(function() {
            var selectedOrgId = $("#orgListContainer :radio:checked").val();
                        
            if (!selectedOrgId) {
                return;
            }
                        
            $("<div><fmt:message key="deleteAuthOrgAreYouSure"/></div>").attr("id", "orgContainer").appendTo($(document.body));

            $("#orgContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "<fmt:message key="deleteAuthOrg"/>",
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        ajaxOpen({
                            url: "${outputRightsUrl}",
                            event: "deleteOutputRights",
                            containerSelector: "#orgListContainer",
                            extraParams: [
                                {name: "selectedOrgId", value: selectedOrgId}
                            ],
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${outputRightsUrl}",
                                    event: "list_orgs",
                                    containerSelector: "#orgListContainer",
                                    successAfterContainerFill: function() {
                                        $("#orgContainer").dialog("close");
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
        <h1><fmt:message key="output.rights.selectOutput"/></h1>
    </div>
    <div id="orgListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/output_rights/list.jsp" %>
    </div>
    <div class="crudButtonsArea">
        <div>
            <stripes:button id="createOutputRights" name="create"/>
            <stripes:button id="updateOutputRights" name="update"/>
            <stripes:button id="deleteOutputRights" name="delete"/>
        </div>        
    </div>
</stripes:form>