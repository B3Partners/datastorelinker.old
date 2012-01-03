<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        <c:choose>
            <c:when test="${not empty actionBean.selectedOrg}">
                $("#name").val("<c:out value="${actionBean.selectedOrg.name}"/>");
                $("#upload_path").val("<c:out value="${actionBean.selectedOrg.uploadPath}"/>");
            </c:when>
            <c:otherwise>
                $("#name").val("");
                $("#upload_path").val("");
            </c:otherwise>
        </c:choose>

        $("#orgForm").validate(defaultValidateOptions);
    });
</script>

<stripes:form id="orgForm" beanclass="nl.b3p.datastorelinker.gui.stripes.AuthorizationAction">
    <c:if test="${not empty actionBean.selectedOrgId}">
        <stripes:hidden name="selectedOrgId" value="${actionBean.selectedOrgId}"/>
    </c:if>
    <stripes:wizard-fields/>
    <table>
        <tbody>
            <tr>
                <td>Naam</td>
                <td><stripes:text id="name" name="name" class="required"/></td>
            </tr>
            <tr>
                <td>Upload path</td>
                <td><stripes:text id="upload_path" name="upload_path" class="required"/></td>
            </tr>            
        </tbody>
    </table>
</stripes:form>