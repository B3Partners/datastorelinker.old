<%-- 
    Document   : list
    Created on : 7-mei-2010, 20:36:03
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>
<%@include file="/pages/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        //$("#filesList").buttonset();

        selectedFileId = null;
        selectedFileFound = false;
        <c:if test="${not empty actionBean.selectedFileId}">
            selectedFileId = <c:out value="${actionBean.selectedFileId}"/>;
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
            fileCallback: function(fileName) {
                
            },
            readyCallback: function(root) {
                if (selectedFileId != null && !selectedFileFound) {
                    log(root);
                    var selectedFile = root.find("input:radio[value=" + selectedFileId + "]");
                    if (selectedFile.length > 0) {
                        selectedFileFound = true;
                        selectedFile.attr("checked", "checked");
                        selectedFile.siblings("a").addClass(activeClass);
                    } else {
                        // TODO recurse with correct dir
                    }
                }
            }
        });

    });
</script>

<div id="filetree"></div>

<%--div id="filesList">
    <stripes:form partial="true" action="/">
        <c:forEach var="file" items="${actionBean.files}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedFileId and file.id == actionBean.selectedFileId}">
                    <input type="radio" id="file${status.index}" name="selectedFileId" value="${file.id}" class="required" checked="checked" />
                    <script type="text/javascript">
                        $(document).ready(function() {
                            $("#filesList").parent().scrollTo(
                                $("#file${status.index}"),
                                defaultScrollToDuration,
                                defaultScrollToOptions
                            );
                        });
                    </script>
                </c:when>
                <c:otherwise>
                    <input type="radio" id="file${status.index}" name="selectedFileId" value="${file.id}" class="required"/>
                </c:otherwise>
            </c:choose>
            <stripes:label for="file${status.index}">
                <c:out value="${file.name}"/>
            </stripes:label>
        </c:forEach>
    </stripes:form>
</div--%>
