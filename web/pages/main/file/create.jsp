<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
$(function() {
    $("#uploadify").uploadify({
        uploader       : "${contextPath}/scripts/jquery.uploadify/uploadify.swf",
        script         : "<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/>",//?upload',
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
    });
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

<span><input type="file" name="uploadify" id="uploadify" /></span>

<!-- TODO: localize -->
<div id="messageBox" style="display: none" title="Fout...">Er is een fout opgetreden bij het uploaden van het bestand</div>