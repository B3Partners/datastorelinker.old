<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:url var="fileUrl" beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>

<style type="text/css">
#uploaderBody, #uploaderQueue * {
    width: auto;
}

#uploaderQueue {
    width: auto;
    height: 75px;
}

#uploaderPanel .ui-button {
    height: auto;
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
        checkScriptAjaxOptions: {globals: false},
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
    $("#uploaderPanel *").addClass("ui-helper-reset");
    //$("#uploaderBody").removeClass("ui-helper-reset");
    
    // do layout again because we just added the uploader.
    // We could skip the first but it is more complete this way.
    $("#inputContainer").layout(defaultDialogLayoutOptions).initContent("center");
});
</script>

<stripes:form partial="true" action="#">
    <stripes:file name="uploader" id="uploader" />
</stripes:form>

<!--div>IE is raar: ${actionBean.uploadDirectory}</div-->

