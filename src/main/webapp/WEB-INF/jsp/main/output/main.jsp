<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        $("#drop").prop("checked", ${actionBean.drop ? 'true' : 'false'});
        $("#append").prop("checked", ${actionBean.append ? 'true' : 'false'});
        $("#modify").prop("checked", ${actionBean.modify ? 'true' : 'false'});
        
        $("#drop").change(function() {
            var drop = !!$("#drop").attr("checked");
            $("#append").attr("disabled", drop);
            $("#modify").attr("disabled", drop);
            if (drop) {
                $("#append").attr("checked", false);
                $("#modify").attr("checked", false);
            }
        });      

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
                "<fmt:message key="finish"/>": function() {
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
            if (!isFormValidAndContainsInput("#createUpdateProcessForm"))
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
        <!-- Gewone gebruiker mag niet tijdens proces een uitvoer beheren -->
        <c:if test="${b3p:isUserInRole(pageContext.request,'beheerder')}">
            <div>
                <stripes:button id="createOutput" name="create"/>
                <stripes:button id="updateOutput" name="update"/>
                <stripes:button id="deleteOutput" name="delete"/>
            </div>
        </c:if>        

        <!--<c:if test="${empty actionBean.admin or actionBean.admin == false}">
            <div style="margin-top: 1em">
                <div>
                    <input type="checkbox" name="drop" id="drop"/>
                    <stripes:label name="table.drop" for="drop"/>
                </div>
                <div>
                    <input type="checkbox" name="append" id="append" />
                    <stripes:label name="table.append" for="append"/>
                </div>
                <div>
                    <input type="checkbox" name="modify" id="modify" />
                    <stripes:label name="table.modify" for="modify"/>
                </div>
            </div>
        </c:if> -->
    </div>
</stripes:form>