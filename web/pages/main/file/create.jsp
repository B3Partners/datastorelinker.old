<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="fileUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>

<script type="text/javascript">
    $(document).ready(function() {
        $("#uploader").uiload({
            swfuploader: "${contextPath}/scripts/jquery.ui-uploader/flash/jquery-ui-upload.swf",
            script: "${fileUrl}",
            scriptData: {"upload": ""},
            checkScript: "${fileUrl}",
            checkScriptData: {"check": ""},
            checkScriptAjaxOptions: {globals: false},
            //fpath: "<c:out value="${actionBean.uploadDirectory}"/>", // IE kan dit niet lezen. Daardoor wordt uiload geskipped. // is ook niet nodig
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
                "Alle ondersteunde formaten": ["shp", "dxf", "sdl", "sfn", "csv"],
                "Shape formaat": ["shp"],
                "Autodesk formaat": ["dxf", "sdl"],
                "SUF formaat (ook NEN 1878)": ["sfn"],
                "CSV formaat": ["csv"]
            },
            onCheck: function(event, checkScript, fileObj, fileDir, single) {

            },
            onComplete: function(event, fileID, fileObj, response, data) {
                $("#uploaderStop").button("disable");
                $("#fileUploadProgressContainer").dialog("widget").find(".ui-dialog-titlebar-close").css("display", "inline");
                $("#filesListContainer").html(response);
            },
            onSelect: function() {
                var upload = $("<div></div>").attr("id", "fileUploadProgressContainer").appendTo($("body"));

                upload.append($("#uploaderQueue"));
                upload.append($("#uploaderStop"));

                upload.dialog($.extend({}, defaultDialogOptions, {
                    title: "Bestand aan het uploaden...", // TODO: localization
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
        $("#inputContainer").layout(defaultDialogLayoutOptions).initContent("center");
    });
</script>

<stripes:form partial="true" action="#">
    <stripes:file name="uploader" id="uploader" />
</stripes:form>

<!--div>IE is raar: <c:out value="${actionBean.uploadDirectory}"/></div-->

