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
                        url: "${authUrl}",
                        event: "createOrganizationComplete",
                        extraParams: [
                            {name: "name", value: $("#name").val()},
                            {name: "upload_path", value: $("#upload_path").val()}
                        ],
                        containerSelector: "#orgListContainer",
                        successAfterContainerFill: function(data, textStatus, xhr) {
                            $("#outputContainer").dialog("close");
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
                    var selectedOrgId = $("#orgListContainer :radio:checked").val();
                    
                    ajaxOpen({
                        url: "${authUrl}",
                        event: "createOrganizationComplete",
                        extraParams: [
                            {name: "selectedOrgId", value: selectedOrgId},
                            {name: "name", value: $("#name").val()},
                            {name: "upload_path", value: $("#upload_path").val()}
                        ],
                        containerSelector: "#orgListContainer",
                        successAfterContainerFill: function(data, textStatus, xhr) {
                            $("#outputContainer").dialog("close");
                        }                    
                    });
                }
            }
        });

        /* Als er op nieuw geklikt wordt */
        $("#createOrganization").click(function() {
            ajaxOpen({
                url: "${authUrl}",
                event: "createOrganization",
                containerId: "outputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newOrgDialogOptions, {
                    title: "<fmt:message key="newAuthOrg"/>"
                })
            });

            return defaultButtonClick(this);
        })

        /* Als er op bewerken geklikt wordt */
        $("#updateOrganization").click(function() {
            var selectedOrgId = $("#orgListContainer :radio:checked").val();
            
            ajaxOpen({
                url: "${authUrl}",
                event: "updateOrganization",
                containerId: "outputContainer",
                extraParams: [
                    {name: "selectedOrgId", value: selectedOrgId}
                ],
                openInDialog: true,
                dialogOptions: $.extend({}, updateOrgDialogOptions, {
                    title: "<fmt:message key="editAuthOrg"/>"
                })
            });

            return defaultButtonClick(this);
        })
        
        /* Als er op verwijder geklikt wordt */
        $("#deleteOrganization").click(function() {
            if (!isFormValidAndContainsInput("#createUpdateOrganizationForm"))
                return defaultButtonClick(this);

            $("<div><fmt:message key="deleteAuthOrgAreYouSure"/></div>").attr("id", "outputContainer").appendTo($(document.body));

            $("#outputContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "<fmt:message key="deleteAuthOrg"/>",
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        ajaxOpen({
                            url: "${authUrl}",
                            formSelector: "#createUpdateOrganizationForm",
                            event: "deleteOrganization",
                            containerSelector: "#orgListContainer",
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${authUrl}",
                                    event: "list_orgs",
                                    containerSelector: "#orgListContainer",
                                    successAfterContainerFill: function() {
                                        $("#outputContainer").dialog("close");
                                    }
                                });
                            }
                        });
                    }
                }
            }));

            return defaultButtonClick(this);
        });
        
        log("output docready");
    });
</script>

<stripes:form partial="true" action="#">
    <div>
        <h1><fmt:message key="auth.selectOrg"/></h1>
    </div>
    <div id="orgListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/auth/orgs/list.jsp" %>
    </div>
    <div class="crudButtonsArea">
        <div>
            <stripes:button id="createOrganization" name="create"/>
            <stripes:button id="updateOrganization" name="update"/>
            <stripes:button id="deleteOrganization" name="delete"/>
        </div>        
    </div>
</stripes:form>