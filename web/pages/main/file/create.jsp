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
            if (response !== "success") {
                alert(response);
            } else {
                // TODO: roep <stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.FileAction"/> met createComplete ?
            }
        },
        onCancel       : function(event, queueID, fileObj, data){
            // TODO: delete tempfile
        },
        onError        : function(event, queueID, fileObj, errorObj) {
            
        }/*,
        fileExt        : "*.shp;*.ext2;*.ext3",
        fileDesc       : "*.shp;*.ext2;*.ext3"*/
    });
});
</script>

Upload een file:
<input type="file" name="uploadify" id="uploadify" />
