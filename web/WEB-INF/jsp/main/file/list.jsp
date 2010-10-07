<%-- 
    Document   : list
    Created on : 7-mei-2010, 20:36:03
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        selectedFilePath = null;
        selectedFileFound = false;
        <c:if test="${not empty actionBean.selectedFilePath}">
            selectedFilePath = <c:out value="${actionBean.selectedFilePath}"/>;
        </c:if>

        var activeClass = "ui-state-active";

        $("#filetree").fileTree({
            script: "${fileUrl}",
            scriptEvent: "listDir",
            root: "",
            spinnerImage: "${contextPath}/scripts/jquery.filetree/images/spinner.png",
            expandEasing: "easeOutBounce",
            collapseEasing: "easeOutBounce",
            dragAndDrop: false,
            extraAjaxOptions: {
                global: false
            },
            activeClass: activeClass,
            activateDirsOnClick: false,
            expandOnFirstCallTo: selectedFilePath,
            fileCallback: function(fileName) {
                
            },
            readyCallback: function(root) {
                if (selectedFilePath != null && !selectedFileFound) {
                    //log(root);
                    var selectedFile = root.find("input:radio[value=" + selectedFilePath + "]");
                    //log(selectedFile);
                    if (selectedFile.length > 0) {
                        selectedFileFound = true;
                        selectedFile.attr("checked", "checked");
                        selectedFile.siblings("a").addClass(activeClass);
                        $("#filetree").parent().scrollTo(
                            selectedFile,
                            defaultScrollToDuration,
                            defaultScrollToOptions
                        );
                    }
                }
            }
        });

    });
</script>

<div id="filetree"></div>