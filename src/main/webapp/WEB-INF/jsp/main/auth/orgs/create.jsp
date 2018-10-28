<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        <c:choose>
            <c:when test="${not empty actionBean.selectedOrg}">
                $("#orgName").val("<c:out value="${actionBean.selectedOrg.name}"/>");
            </c:when>
            <c:otherwise>
                $("#orgName").val("");
            </c:otherwise>
        </c:choose>

    $("#orgName").keydown(function(event){
        // on enter skip the default behaviour and fire the button to create a new organization
            if (event.which === 13){
                event.preventDefault();
                $("#newOrgCreate").trigger('click');
 
            }
        });
    });
</script>

<stripes:form id="orgForm" action="#">
    <c:if test="${not empty actionBean.selectedOrgId}">
        <stripes:hidden name="selectedOrgId" value="${actionBean.selectedOrgId}"/>
    </c:if>
    <table>
        <tbody>
            <tr>
                <td>* <fmt:message key="keys.name"/></td>
                <td><stripes:text id="orgName" name="orgName" class="required"/></td>
                <td><div id="msgOrgName" class="verplichteInvoer"/></td>
            </tr>          
        </tbody>
    </table>
</stripes:form>