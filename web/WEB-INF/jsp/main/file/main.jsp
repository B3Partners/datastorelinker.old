<%-- 
    Document   : main
    Created on : 4-aug-2010, 18:11:55
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initFile();

        $("#uploadFile").click(function() {              
            if (!$("#uploader").val()) {
                return defaultButtonClick(this);
            }
            
            var oldAction = $("#createUpdateProcessForm").prop("action");
            var oldMethod = $("#createUpdateProcessForm").prop("method");
            var oldEncType = $("#createUpdateProcessForm").prop("enctype");
            var oldEncoding = $("#createUpdateProcessForm").prop("encoding");

            $("#createUpdateProcessForm").prop({
                action: "${fileUrl}",
                method: "POST",
                enctype: "multipart/form-data",
                encoding: "multipart/form-data"
            });

            //$.fn.ajaxSubmit.debug = true;
            $("#createUpdateProcessForm").ajaxSubmit({
                dataType: "html",
                success: function(responseText, statusText, xhr, form) {
                    $.blockUI(blockUIOptions);
                    // allow server to finish its stuff, then update all statuses:
                    setTimeout(
                        function() {
                            ajaxOpen({
                                url: "${fileUrl}",
                                event: "list",
                                extraParams: [
                                    {name: "selectedFilePath", value: $(responseText).text()},
                                    {name: "adminPage", value: "${param.adminPage}"}
                                ],
                                containerSelector: "#filesListContainer"
                            });
                        },
                        100
                    );
                },
                global: false
            });
            $("#createUpdateProcessForm").prop({
                action: oldAction,
                method: oldMethod,
                enctype: oldEncType,
                encoding: oldEncoding
            });

            startFileUploadProgress();

            return defaultButtonClick(this);
        });

        $("#deleteFile").click(function() {
            if (!containsInput("#filesListContainer")) {
                return defaultButtonClick(this);
            }   

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
                extraParams: [
                    {name: "selectedFilePaths", value: JSON.stringify(filesToDelete)}
                ],
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
                                    extraParams: [
                                        {name: "selectedFilePaths", value: JSON.stringify(filesToDelete)},
                                        {name: "adminPage", value: "${param.adminPage}"}
                                    ],
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
        
        /* Bladeren button z-index fix voor IE7 */
        if($.browser.msie && $.browser.version <= 7) {            
            $("#uploader").css("z-index", "2100");
        }
    });
    
    function startFileUploadProgress() {
        $("<div></div>")
            .attr("id", "uploadDialog")
            .appendTo($("body"))
            .dialog($.extend({}, defaultDialogOptions, {
                title: I18N.uploading,
                height: 100,
                closeOnEscape: false
            }
        ));
        $("#uploadDialog").parents(".ui-dialog").first()
            .find(".ui-dialog-titlebar-close").remove();
        $("<div></div>")
            .attr("id", "progressbar")
            .appendTo($("#uploadDialog"))
            .css("margin", "5px 5px")
            .append($("<span></span>").addClass("progressbarLabel"))
            .progressbar({
                value: 0,
                change: function(event, ui) {
                    var newValue = $(this).progressbar('option', 'value');
                    $('.progressbarLabel', this).text(newValue + '%');
                }
        });
        setTimeout(refreshFileUploadProgress, 1000);
    }

    function refreshFileUploadProgress() {
        $.ajax({
            url: "${fileUrl}",
            dataType: "json",
            data: {uploadProgress: ""},
            success: function(data, textStatus) {
                if (data.fatalError) {
                    stopFileUploadProgress();
                } else {
                    $("#progressbar").progressbar("value", data.progress);
                    if (data.progress >= 100) {
                        stopFileUploadProgress();
                    } else {
                        setTimeout(refreshFileUploadProgress, 1000);
                    }
                }
            },
            global: false // prevent ajaxStart and ajaxStop to be called (with blockUI in them)
        });
    }

    function stopFileUploadProgress() {
        $("#uploadDialog").dialog("close");
    }
</script>

<stripes:form partial="true" action="#">
    <div id="fileHeader">
    </div>
    <div id="filesListContainer" class="mandatory-form-input ui-layout-content radioList ui-widget-content ui-corner-all">
        <jsp:include page="/WEB-INF/jsp/main/file/list.jsp">
            <jsp:param name="adminPage" value="${param.adminPage}"/>
        </jsp:include>
    </div>
    <div id="uploadButtons">
        <input type="file" name="uploader" id="uploader" size="40"/>
        <stripes:button id="uploadFile" name="upload" value="upload" />
        <c:if test="${param.adminPage == true}">
            <stripes:button id="deleteFile" name="delete" value="delete"/>
        </c:if>
    </div>
</stripes:form>