<%-- 
    Document   : main
    Created on : 4-aug-2010, 18:11:55
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>


<script type="text/javascript">
    $(document).ready(function() {
        initFile();

        $("#uploadFile").click(function() {
            //log($("#createUpdateProcessForm"));
            var oldAction = $("#createUpdateProcessForm").attr("action");
            var oldMethod = $("#createUpdateProcessForm").attr("method");
            var oldEncType = $("#createUpdateProcessForm").attr("enctype");
            var oldEncoding = $("#createUpdateProcessForm").attr("encoding");
            //log("oldEncType: " + oldEncType);

            $("#createUpdateProcessForm")
                .attr("action", "${fileUrl}")
                .attr("method", "POST")
                .attr((this.encoding ? "encoding" : "enctype"), "multipart/form-data");

            $("#createUpdateProcessForm").ajaxSubmit({
                success: function(responseText, statusText, xhr, form) {
                    /*log("ajaxSubmit success");
                    log(responseText);
                    log(statusText);
                    log(xhr);
                    log(form);*/
                    $("#filesListContainer").html($(responseText).find("textarea").val());
                    initFiletree();
                }
            });
            $("#createUpdateProcessForm")
                .attr("action", oldAction)
                .attr("method", oldMethod)
                .attr("enctype", oldEncType)
                .attr("encoding", oldEncoding);

            //log("enctype: " + $("#createUpdateProcessForm").attr("enctype"));
            //log("encoding: " + $("#createUpdateProcessForm").attr("encoding"));

            return defaultButtonClick(this);
        });

        $("#deleteFile").click(function() {
            if (!containsInput("#filesListContainer"))
                return defaultButtonClick(this);
            /*if (!isFormValidAndContainsInput("#createInputForm"))
                return defaultButtonClick(this);*/

            if ($("#filetree input:checkbox:checked").length == 0) {
                $("<div></div").html(I18N.deleteFileFail).dialog($.extend({}, defaultDialogOptions, {
                    title: I18N.error,
                    buttons: {
                        "<fmt:message key="ok"/>": function() {
                            $(this).dialog("close");
                        }
                    }
                }));
                return defaultButtonClick(this);
            }

            /*if (!$("#createInputForm").valid())
                return defaultButtonClick(this);*/

            var filesToDelete = [];
            $("#filetree input:checkbox:checked").each(function(index, value) {
                filesToDelete.push($(value).val());
            });

            ajaxOpen({
                url: "${fileUrl}",
                event: "deleteCheck",
                extraParams: [{
                    name: "selectedFilePaths",
                    value: JSON.stringify(filesToDelete)
                }],
                successAfterContainerFill: function(data) {
                    var dialogElem = $("<div></div>").attr("id", "createFileContainer").appendTo(document.body);
                    if (data.success) {
                        if (filesToDelete.length > 1)
                            dialogElem.html(I18N.deleteFilesAreYouSure);
                        else
                            dialogElem.html(I18N.deleteFileAreYouSure);
                    } else {
                        dialogElem.append("<p>" + I18N.filePreambleAllWillBeDeleted + "</p>");
                        var list = "<ul>";
                        $.each(data.array, function(index, value) {
                            list += "<li>" + value + "</li>";
                        });
                        list += "</ul>";
                        dialogElem.append(list);
                        if (filesToDelete.length > 1)
                            dialogElem.append("<p>" + I18N.filesConfirmAllWillBeDeleted + "</p>");
                        else
                            dialogElem.append("<p>" + I18N.fileConfirmAllWillBeDeleted + "</p>");
                    }

                    $("#createFileContainer").dialog($.extend({}, defaultDialogOptions, {
                        title: I18N.deleteFile,
                        width: 500,
                        buttons: {
                            "<fmt:message key="no"/>": function() {
                                $(this).dialog("close");
                            },
                            "<fmt:message key="yes"/>": function() {
                                $.blockUI(blockUIOptions);

                                ajaxOpen({
                                    url: "${fileUrl}",
                                    //formSelector: "#createInputForm",
                                    event: "delete",
                                    extraParams: [{
                                        name: "selectedFilePaths",
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
                }
            });

            return defaultButtonClick(this);
        });
    });
</script>

<stripes:form partial="true" action="#">
    <div id="fileHeader">
    </div>
    <div id="filesListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <%@include file="/WEB-INF/jsp/main/file/list.jsp" %>
    </div>
    <div>
        <input type="file" name="uploader" id="uploader" size="40"/>
        <stripes:button id="uploadFile" name="upload" value="upload"/>
        <%--stripes:link href="#" id="uploadFile" onclick="return false;">
            <fmt:message key="upload"/>
        </stripes:link--%>
        <%--%@include file="/WEB-INF/jsp/main/file/create.jsp" %--%>
        <stripes:button id="deleteFile" name="delete" value="delete"/>
        <%--stripes:link href="#" id="deleteFile" onclick="return false;">
            <fmt:message key="delete"/>
        </stripes:link--%>
    </div>
</stripes:form>