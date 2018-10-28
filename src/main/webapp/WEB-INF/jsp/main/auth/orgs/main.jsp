<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        /* TODO: Zelf maar even simpel validate iets gemaakt. 
         * @Validate via Stripes geeft wel melding maar op
         * ongewenste pagina. validate via jquery ???? 
        */
        function validateForm() {
            $("#msgOrgName").html("");

            if ($("#orgName").val() == "") {
                $("#msgOrgName").html("<fmt:message key="keys.nameobl"/>");
                return false;
            }
            
            return true;
        };
        
        /* Event wordt aangeroepen in back-end als form is ingevuld */
        var newOrgDialogOptions = $.extend({}, defaultDialogOptions, {            
            width: 550,
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : {
                    text:"<fmt:message key="finish"/>",
                    id:"newOrgCreate",
                    click:function() {                    
                        if (!validateForm()) {
                            return;
                                            }

                        ajaxOpen({
                            url: "${authUrl}",
                            event: "createOrganizationComplete",
                            extraParams: [
                                {name: "orgName", value: $("#orgName").val()}
                            ],
                            containerSelector: "#orgListContainer",
                            successAfterContainerFill: function (data, textStatus, xhr) {
                                $("#orgContainer").dialog("close");
                                                    }
                                                });
                                            }
                                        }
                        }});
        
        /* Event wordt aangeroepen in back-end als form is ingevuld */
        var updateOrgDialogOptions = $.extend({}, defaultDialogOptions, {
            width: 550,
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : function() {  
                    if (!validateForm()) {
                        return;
                    }
                    
                    var selectedOrgId = $("#orgListContainer :radio:checked").val();
                    
                    ajaxOpen({
                        url: "${authUrl}",
                        event: "createOrganizationComplete",
                        extraParams: [
                            {name: "selectedOrgId", value: selectedOrgId},
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

        /* Als er op nieuw geklikt wordt */
        $("#createOrganization").click(function() {            
            ajaxOpen({
                url: "${authUrl}",
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
        $("#updateOrganization").click(function() {
            var selectedOrgId = $("#orgListContainer :radio:checked").val();
            
            if (!selectedOrgId) {
                return;
            }
            
            ajaxOpen({
                url: "${authUrl}",
                event: "updateOrganization",
                containerId: "orgContainer",
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
                            url: "${authUrl}",
                            event: "deleteOrganization",
                            containerSelector: "#orgListContainer",
                            extraParams: [
                                {name: "selectedOrgId", value: selectedOrgId}
                            ],
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${authUrl}",
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