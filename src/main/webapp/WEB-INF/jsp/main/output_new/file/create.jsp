<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<stripes:url var="fileUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        $("#uploader").uiload({
            swfuploader: "${contextPath}/scripts/jquery.ui-uploader/flash/jquery-ui-upload.swf",
            script: "${fileUrl}",
            scriptData: {"upload": ""},
            checkScript: "${fileUrl}",
            checkScriptData: {"check": ""},
            checkScriptAjaxOptions: {global: false},
            //fpath: "<%--c:out value="${actionBean.uploadDirectory}"/--%>", // IE kan dit niet lezen. Daardoor wordt uiload geskipped. // is ook niet nodig
            fdata: "Filedata",
            maxfiles: 1,
            maxfilesize: 524288000, // == 500 MB
            btnIcon: false,
            btnStart: false,
            btnStop: true,
            overwrite: true,
            fadeOut: false,
            progressValueColor: "silver",
            ftypes: {
                "<fmt:message key="inputFile.type.allSupported"/>": ["shp", "dxf", "sdl", "sfn", "csv", "zip"],
                "<fmt:message key="inputFile.type.shape"/>": ["shp"],
                "<fmt:message key="inputFile.type.autodesk"/>": ["dxf", "sdl"],
                "<fmt:message key="inputFile.type.sufnen"/>": ["sfn"],
                "<fmt:message key="inputFile.type.csv"/>": ["csv"],
                "<fmt:message key="inputFile.type.zip"/>": ["zip"]
            },
            onCheck: function(event, checkScript, fileObj, fileDir, single) {

            },
            onComplete: function(event, fileID, fileObj, response, data) {
                $("#filesListContainer").html(response);
                $("#fileUploadProgressContainer").dialog("close");
                /*$("#uploaderStop").button("disable");
                //$("#uploaderStop").css("display", "none");
                $("#fileUploadProgressContainer").dialog("widget").find(".ui-dialog-titlebar-close").css("display", "inline");
                $("#filesListContainer").html(response);*/
            },
            onError: function(event, fileID, fileObj, errorObj) {
                $("#fileUploadProgressContainer").dialog("close");
            },
            onSelect: function() {
                var upload = $("<div></div>").attr("id", "fileUploadProgressContainer").appendTo($("body"));

                upload.append($("#uploaderQueue"));
                upload.append($("#uploaderStop"));

                upload.dialog($.extend({}, defaultDialogOptions, {
                    title: I18N["inputFile.uploading"],
                    width: 400,
                    close: function(event, ui) {
                        $("#uploaderStop, #uploaderQueue").css("display", "none");
                        $("#uploaderBody").append($("#uploaderStop"));
                        $("#uploaderBody").append($("#uploaderQueue"));
                        defaultDialogClose(event, ui);
                    }
                }));

                upload.dialog("widget").find(".ui-dialog-titlebar-close").css("display", "none");
                $("#uploaderQueue").empty().css("display", "block");
                $("#uploaderStop").css("display", "block");
                $("#uploaderStop").button("enable");
            },
            onCancel: function() {
                $("#fileUploadProgressContainer").dialog("close");
            }
        }, jquery_ui_upload_messages_nl);

        $("#uploaderPanel").append($("#deleteFile"));
        $("#uploaderStop, #uploaderQueue").css("display", "none");

        // get rid of some default jquery ui uploader css:
        $("#uploaderQueue").removeClass("ui-widget-content ui-corner-all");

        // do layout again because we just added the uploader.
        // We could skip the first but it is more complete this way.
        if ($("#inputContainer").length > 0)
            $("#inputContainer").layout(defaultDialogLayoutOptions).initContent("center");
    });
</script>

<stripes:form partial="true" action="#">
    <stripes:file name="uploader" id="uploader" />
</stripes:form>

<%--div>IE is raar: c:out value="${actionBean.uploadDirectory}"/></div--%>

