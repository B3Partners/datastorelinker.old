<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="fileUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>

<script type="text/javascript">
$(function() {
    
    $("#uploader").uiload({
        swfuploader: "${contextPath}/scripts/jquery.ui-uploader/flash/jquery-ui-upload.swf",
        script: "${fileUrl}",
        fpath: "${actionBean.uploadDirectory}",
        fdata: "Filedata",
        maxfiles: 1,
        maxfilesize: 524288000, // == 500 MB
        btnIcon: false,
        btnStart: false,
        btnStop: false,
        ftypes: {
            "Alles": ["*"],
            "Iets anders": ["txt", "jpg", "blaat"]
        },
        onComplete: function(event, fileID, fileObj, response, data) {
            $("#filesListContainer").html(response);
            log("fileupload-complete success!");
        }/*,
        onFinished: function() {
            alert("finished success!");
        },
        onError: function() {
            alert("error!");
        }*/
    }, jquery_ui_upload_messages_nl);

    $("#uploaderPanel").append($("#deleteFile"));

    var uploadDiv = $("<div></div>")
        .attr("id", "uploadDialog")
        .attr("style", "display: none")
        .appendTo(document.body);
    uploadDiv.append($("#uploaderQueue"));

    $("#uploaderBrowse").removeAttr("onclick");
    $("#uploaderBrowse").click(function() {
        uploadDiv.dialog({
            title: "Bezig met uploaden ...", // TODO: localization
            width: 400,
            height: 200,
            modal: true,
            buttons: {
                "Ok" : function() {
                    uploadDiv.close();
                },
                "Annuleren" : function() {
                    uploadDiv.close();
                }
            },
            close: defaultDialogClose
        });
    });

    <%--$("#uploader").uploadify({
        uploader       : "${contextPath}/scripts/jquery.uploadify/uploadify.swf",
        script         : "${fileUrl}",
        cancelImg      : "${contextPath}/scripts/jquery.uploadify/cancel.png",
        folder         : "${actionBean.uploadDirectory}",
        auto           : true,
        buttonText     : "Zoek bestand...", // TODO: localize
        //hideButton     : true,
        onComplete     : function(event, queueID, fileObj, response, data){
            $("#filesListContainer").html(response);
            // Let ajaxError handle errors.
            /*if ($(response).first().attr("id") == "filesList") {
                $("#filesListContainer").html(response);
            } else {
                showErrorDialog();
            }*/
        },
        onCancel       : function(event, queueID, fileObj, data){
            // TODO: delete tempfile
        },
        onError        : function(event, queueID, fileObj, errorObj) {
            //showErrorDialog();
        } /*,
        fileExt        : "*.shp;*.ext2;*.ext3",
        fileDesc       : "*.shp;*.ext2;*.ext3"*/
    });--%>
});

<%--function showErrorDialog() {
    $("#messageBox").dialog({
        buttons: {
            "Ok": function() {
                $(this).dialog("close");
            }
        }
    });
}--%>
</script>

<!-- TODO: localize -->
<!--div id="messageBox" style="display: none" title="Fout...">Er is een fout opgetreden bij het uploaden van het bestand</div-->

<input type="file" name="uploader" id="uploader" />

