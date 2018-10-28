<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        var dialogWidth = 625;
        
        /* TODO: Zelf maar even simpel validate iets gemaakt. 
         * @Validate via Stripes geeft wel melding maar op
         * ongewenste pagina. validate via jquery ???? 
        */
        function validateNewUserForm() {
            $("#msgUserName").html("");
            $("#msgUserPassword").html("");

            if ($("#userName").val() == "") {
                $("#msgUserName").html("<fmt:message key="keys.nameobl"/>");
                return false;
            }
            
            if ($("#userPassword").val() == "") {
                $("#msgUserPassword").html("<fmt:message key="keys.pwobl"/>");
                return false;
            }
            
            if ($("#userPassword").val() != $("#userPasswordAgain").val()) {
                $("#msgUserPassword").html("<fmt:message key="keys.pwnomatch"/>");
                return false;
            }
            
            return true;
        }
        
        function validateUpdateUserForm() {
            $("#msgUserName").html("");
            $("#msgUserPassword").html("");

            if ($("#userName").val() == "") {
                $("#msgUserName").html("<fmt:message key="keys.nameobl"/>");
                return false;
            }
            
            if ($("#userPassword").val() != $("#userPasswordAgain").val()) {
                $("#msgUserPassword").html("<fmt:message key="keys.pwnomatch"/>");
                return false;
            }
            
            return true;
        }
        
        /* Event wordt aangeroepen in back-end als form is ingevuld */
        var newUserDialogOptions = $.extend({}, defaultDialogOptions, {            
            width: dialogWidth,
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : function() {                    
                    if (!validateNewUserForm()) {
                        return;
                    }
                    
                    if ($("#userIsAdmin").is(':checked')) {
                        $("#userIsAdmin").val(true);
                    } else {
                        $("#userIsAdmin").val(false);
                    }              
                    
                    ajaxOpen({
                        url: "${authUrl}",
                        event: "createUserComplete",
                        extraParams: [
                            {name: "userOrgId", value: $("#userOrgId").val()},
                            {name: "userName", value: $("#userName").val()},
                            {name: "userPassword", value: $("#userPassword").val()},
                            {name: "userPasswordAgain", value: $("#userPasswordAgain").val()},
                            {name: "userIsAdmin", value: $("#userIsAdmin").val()}
                        ],
                        containerSelector: "#userListContainer",
                        successAfterContainerFill: function(data, textStatus, xhr) {
                            $("#userContainer").dialog("close");
                        }                    
                    });
                }
            }
        });
        
        /* Event wordt aangeroepen in back-end als form is ingevuld */
        var updateUserDialogOptions = $.extend({}, defaultDialogOptions, {
            width: dialogWidth,
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : function() {  
                    if (!validateUpdateUserForm()) {
                        return;
                    }
                    
                    if ($("#userIsAdmin").is(':checked')) {
                        $("#userIsAdmin").val(true);
                    } else {
                        $("#userIsAdmin").val(false);
                    }
                    
                    var selectedUserId = $("#userListContainer :radio:checked").val();
                    
                    ajaxOpen({
                        url: "${authUrl}",
                        event: "createUserComplete",
                        extraParams: [
                            {name: "selectedUserId", value: selectedUserId},
                            {name: "userOrgId", value: $("#userOrgId").val()},
                            {name: "userName", value: $("#userName").val()},
                            {name: "userPassword", value: $("#userPassword").val()},
                            {name: "userPasswordAgain", value: $("#userPasswordAgain").val()},
                            {name: "userIsAdmin", value: $("#userIsAdmin").val()}
                        ],
                        containerSelector: "#userListContainer",
                        successAfterContainerFill: function(data, textStatus, xhr) {
                            $("#userContainer").dialog("close");
                        }                    
                    });
                }
            }
        });

        /* Als er op nieuw geklikt wordt */
        $("#createUser").click(function() {            
            ajaxOpen({
                url: "${authUrl}",
                event: "createUser",
                containerId: "userContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUserDialogOptions, {
                    title: "<fmt:message key="newAuthUser"/>"
                })
            });

            return defaultButtonClick(this);
        })

        /* Als er op bewerken geklikt wordt */
        $("#updateUser").click(function() {
            var selectedUserId = $("#userListContainer :radio:checked").val();
            
            if (!selectedUserId) {
                return;
            }
            
            ajaxOpen({
                url: "${authUrl}",
                event: "updateUser",
                containerId: "userContainer",
                extraParams: [
                    {name: "selectedUserId", value: selectedUserId}
                ],
                openInDialog: true,
                dialogOptions: $.extend({}, updateUserDialogOptions, {
                    title: "<fmt:message key="editAuthUser"/>"
                })
            });

            return defaultButtonClick(this);
        })
        
        /* Als er op verwijder geklikt wordt */
        $("#deleteUser").click(function() {
            var selectedUserId = $("#userListContainer :radio:checked").val();
                        
            if (!selectedUserId) {
                return;
            }
                        
            $("<div><fmt:message key="deleteAuthUserAreYouSure"/></div>").attr("id", "userContainer").appendTo($(document.body));

            $("#userContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "<fmt:message key="deleteAuthUser"/>",
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        ajaxOpen({
                            url: "${authUrl}",
                            event: "deleteUser",
                            containerSelector: "#userListContainer",
                            extraParams: [
                                {name: "selectedUserId", value: selectedUserId}
                            ],
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${authUrl}",
                                    event: "list_users",
                                    containerSelector: "#userListContainer",
                                    successAfterContainerFill: function() {
                                        $("#userContainer").dialog("close");
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
        <h1><fmt:message key="auth.selectUser"/></h1>
    </div>
    <div id="userListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/auth/users/list.jsp" %>
    </div>
    <div class="crudButtonsArea">
        <div>
            <stripes:button id="createUser" name="create"/>
            <stripes:button id="updateUser" name="update"/>
            <stripes:button id="deleteUser" name="delete"/>
        </div>        
    </div>
</stripes:form>