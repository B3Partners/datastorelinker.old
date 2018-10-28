<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">    
    $(document).ready(function() {
        /* Bij back-end geselecteerde organisatie id ophalen om 
         * multiselect te kunnen vullen */
        var id;  
        <c:if test="${not empty actionBean.selectedOutputId}">
            var id = <c:out value="${actionBean.selectedOutputId}"/>;
        </c:if>
            
        var params = {fillSelectedOrganizationIds: "", selectedOutputId: id};        
        selectionIds = $.ajax({
            url: "${outputRightsUrl}",
            data: params,
            dataType: "json",
            global: false
        }).done(function(json) {
            var arr = new Array();
            var i = 0;
            
            $.each(json, function(index, value) { 
                arr[i] = value.id;
                i++;
            });
            
            $("#organizationIds").val(arr);
        });        
    });
</script>

<stripes:form id="outputRightsForm" action="#">
    <c:if test="${not empty actionBean.selectedOutputId}">
        <stripes:hidden name="selectedOutputId" value="${actionBean.selectedOutputId}"/>
    </c:if>
    <p><fmt:message key="keys.selorgsrights"/></p>
    <table>
        <tbody>
            <tr>
                <td>    <stripes:select id="organizationIds" name="selectedOrgIds" multiple="true" size="5">
                        <stripes:option value="">-Selecteer organisaties-</stripes:option>
                        <stripes:options-collection collection="${actionBean.orgs}" value="id" label="name" />
                    </stripes:select> </td>
                <td><div id="msgOrgIdError" class="verplichteInvoer"/> </td>
            </tr>
        </tbody>
    </table>

</stripes:form>