<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="fileUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>

<style type="text/css">
#uploaderQueue {
    height: 75px;
}

#filesList {
    height: 125px;
}
</style>

<script type="text/javascript">
$(document).ready(function() {
    $("#uploader").uiload({
        swfuploader: "${contextPath}/scripts/jquery.ui-uploader/flash/jquery-ui-upload.swf",
        script: "${fileUrl}",
        scriptData: {"upload": ""},
        checkScript: "${fileUrl}",
        checkScriptData: {"check": ""},
        //fpath: "${actionBean.uploadDirectory}", // IE kan dit niet lezen. Daardoor wordt uiload geskipped. // is ook niet nodig
        fdata: "Filedata",
        maxfiles: 1,
        maxfilesize: 524288000, // == 500 MB
        btnIcon: false,
        btnStart: false,
        btnStop: true,
        overwrite: true,
        ftypes: {
            "Alles": ["*"],
            "Iets anders": ["txt", "jpg", "blaat"]
        },
        onCheck: function(event, checkScript, fileObj, fileDir, single) {
            
        },
        onComplete: function(event, fileID, fileObj, response, data) {
            $("#filesListContainer").html(response);
        }/*,
        onFinished: function() {
            alert("finished success!");
        },
        onError: function() {
            alert("error!");
        }*/
    }, jquery_ui_upload_messages_nl);

    $("#uploaderPanel").append($("#deleteFile"));

    /*var uploadDiv = $("<div></div>")
        .attr("id", "uploadDialog")
        .attr("style", "display: none")
        .appendTo(document.body);
    uploadDiv.append($("#uploaderQueue"));

    $("#uploaderBrowse").removeAttr("onclick");
    $("#uploaderBrowse").click(function() {
        uploadDiv.dialog({
            title: "Bezig met uploaden...", // TODO: localization
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
    });*/
});
</script>

<stripes:form partial="true" action="#">
    <stripes:file name="uploader" id="uploader" />
</stripes:form>

<!--div>IE is raar: ${actionBean.uploadDirectory}</div-->

