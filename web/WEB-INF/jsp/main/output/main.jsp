<%-- 
    Document   : main
    Created on : 4-aug-2010, 13:32:02
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        $("#radioNoDrop").removeAttr("checked");
        $("#radioDrop").attr("checked", "checked");
        <c:if test="${not empty actionBean.drop and actionBean.drop == false}">
            $("#radioDrop").removeAttr("checked");
            $("#radioNoDrop").attr("checked", "checked");
        </c:if>

        connectionSuccessOutputDBAjaxOpenOptions = {
            url: "${outputUrl}",
            formSelector: ".form-container .ui-accordion-content-active form",
            event: "createComplete",
            containerSelector: "#outputListContainer",
            successAfterContainerFill: function(data, textStatus, xhr) {
                $("#outputContainer").dialog("close");
            }
        }
        
        var newUpdateOutputCommonDialogOptions = $.extend({}, defaultDialogOptions, {
            width: 550,
            //height: 400,
            buttons: {
                "<fmt:message key="finish"/>" : function() {
                    testConnection(connectionSuccessOutputDBAjaxOpenOptions);
                }
            }
        });

        $("#createOutput").click(function() {
            ajaxOpen({
                url: "${outputUrl}",
                event: "create",
                containerId: "outputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateOutputCommonDialogOptions, {
                    title: "<fmt:message key="newDatabaseOutput"/>"
                })
            });

            return defaultButtonClick(this);
        })

        $("#updateOutput").click(function() {
            ajaxOpen({
                url: "${outputUrl}",
                formSelector: "#createUpdateProcessForm",
                event: "update",
                containerId: "outputContainer",
                openInDialog: true,
                dialogOptions: $.extend({}, newUpdateOutputCommonDialogOptions, {
                    title: "<fmt:message key="editOutput"/>"
                })
            });

            return defaultButtonClick(this);
        })

        $("#deleteOutput").click(function() {
            if (!$("#createUpdateProcessForm").valid())
                return defaultButtonClick(this);

            $("<div><fmt:message key="deleteOutputAreYouSure"/></div>").attr("id", "outputContainer").appendTo($(document.body));

            $("#outputContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "<fmt:message key="deleteOutput"/>",
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        ajaxOpen({
                            url: "${outputUrl}",
                            formSelector: "#createUpdateProcessForm",
                            event: "delete",
                            containerSelector: "#outputListContainer",
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${processUrl}",
                                    event: "list",
                                    containerSelector: "#processesListContainer",
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
    });
</script>

<stripes:form partial="true" action="#">
    <div>
        <h1><fmt:message key="process.selectOutput"/></h1>
    </div>
    <div id="outputListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/output/list.jsp" %>
    </div>
    <div class="crudButtonsArea">
        <div>
            <stripes:button id="createOutput" name="create"/>
            <stripes:button id="updateOutput" name="update"/>
            <stripes:button id="deleteOutput" name="delete"/>
        </div>
        <c:if test="${empty actionBean.admin or actionBean.admin == false}">
            <div style="margin-top: 1em">
                <div>
                    <input type="radio" name="drop" id="radioDrop" value="true" checked="checked"/>
                    <stripes:label name="outputDrop" for="radioDrop"/>
                </div>
                <div>
                    <input type="radio" name="drop" id="radioNoDrop" value="false"/>
                    <stripes:label name="outputNoDrop" for="radioNoDrop"/>
                </div>
            </div>
        </c:if>
    </div>
</stripes:form>