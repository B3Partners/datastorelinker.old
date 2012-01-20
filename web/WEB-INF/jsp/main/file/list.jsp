<%-- 
    Document   : list
    Created on : 7-mei-2010, 20:36:03
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initFiletree();
    });

    function initFiletree() {
        selectedFilePath = null;
        selectedFileFound = false;
        <c:if test="${not empty actionBean.selectedFilePath}">
            selectedFilePath = "<c:out value="${actionBean.selectedFilePath}"/>";
        </c:if>
        
        <c:choose>
            <c:when test="${param.adminPage == true}">
                var activeClass = "filetree-dummy-selected";
            </c:when>
            <c:otherwise>
                var activeClass = "ui-state-active";
            </c:otherwise>
        </c:choose>

        $("#filetree").fileTree({
            script: "${fileUrl}",
            scriptEvent: "listDir",
            root: "",
            //spinnerImage: "${contextPath}/scripts/jquery.filetree/images/spinner.png",
            expandEasing: "easeOutBounce",
            collapseEasing: "easeOutBounce",
            dragAndDrop: false,
            extraAjaxOptions: {
                global: false<c:if test="${param.adminPage == true}">,
                data: {adminPage: true}</c:if>
            },
            activeClass: activeClass,
            activateDirsOnClick: false,
            expandOnFirstCallTo: selectedFilePath,
            fileCallback: function(fileName) {

            },
            readyCallback: function(root) {
                if (selectedFilePath != null && !selectedFileFound) {
                    var selectedFile = root.find("input:radio[value='" + selectedFilePath + "']");
                    
                    if (selectedFile.length > 0) {
                        selectedFileFound = true;
                        selectedFile.prop("checked", true);
                        selectedFile.siblings("a").addClass(activeClass);
                        $("#filetree").parent().scrollTo(
                            selectedFile,
                            defaultScrollToDuration,
                            defaultScrollToOptions
                        );
                    }
                }
                var $lis = $("#filetree li.file");
                if ($lis.length > 0) {
                    var $radios = $lis.find("input:radio");
                    if ($radios.filter(":checked").length === 0) {
                        $radios.first().prop("checked", true);
                        $radios.first().siblings("a").first().addClass(activeClass);
                    }
                }
            }
        });
    }
</script>

<div id="filetree"></div>