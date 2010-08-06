<%-- 
    Document   : main
    Created on : 4-aug-2010, 18:11:55
    Author     : Erik van de Pol
--%>

<%@include file="/pages/commons/taglibs.jsp" %>
<%@include file="/pages/commons/urls.jsp" %>


<script type="text/javascript">
    $(document).ready(function() {
        $("#deleteFile").click(function() {
            if ($("#filetree input:checked").length == 0) {
                // bericht?
                return defaultButtonClick(this);
            }

            /*if (!$("#createInputForm").valid())
                return defaultButtonClick(this);*/

            $("<div><fmt:message key="deleteFileAreYouSure"/></div>").attr("id", "createFileContainer").appendTo(document.body);

            $("#createFileContainer").dialog($.extend({}, defaultDialogOptions, {
                title: "<fmt:message key="deleteFile"/>",
                width: 350,
                buttons: {
                    "<fmt:message key="no"/>": function() {
                        $(this).dialog("close");
                    },
                    "<fmt:message key="yes"/>": function() {
                        $.blockUI(blockUIOptions);

                        var filesToDelete = [];
                        $("#filetree input:checkbox:checked").each(function(index, value) {
                            filesToDelete.push($(value).val());
                        });

                        ajaxOpen({
                            url: "${fileUrl}",
                            //formSelector: "#createInputForm",
                            event: "delete",
                            extraParams: [{
                                name: "selectedFileIds",
                                value: JSON.stringify(filesToDelete)
                            }],
                            containerSelector: "#filesListContainer",
                            ajaxOptions: {global: false}, // prevent blockUI being called 3 times. Called manually.
                            successAfterContainerFill: function() {
                                ajaxOpen({
                                    url: "${inputUrl}",
                                    event: "list",
                                    containerSelector: "#inputListContainer",
                                    ajaxOptions: {global: false},
                                    successAfterContainerFill: function() {
                                        ajaxOpen({
                                            url: "${processUrl}",
                                            event: "list",
                                            containerSelector: "#processesListContainer",
                                            ajaxOptions: {global: false},
                                            successAfterContainerFill: function() {
                                                $("#createFileContainer").dialog("close");
                                                $.unblockUI(unblockUIOptions);
                                            }
                                        });
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
        <h1><fmt:message key="inputFile.selectFile"/></h1>
    </div>
    <div id="filesListContainer" class="ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/pages/main/file/list.jsp" %>
    </div>
    <div>
        <%@include file="/pages/main/file/create.jsp" %>
        <stripes:link href="#" id="deleteFile" onclick="return false;">
            <fmt:message key="delete"/>
        </stripes:link>
    </div>
</stripes:form>