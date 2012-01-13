<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<stripes:form id="outputRightsForm" action="#">
    <c:if test="${not empty actionBean.selectedOutputId}">
        <stripes:hidden name="selectedOutputId" value="${actionBean.selectedOutputId}"/>
    </c:if>
    <p>Selecteer een of meerdere organisaties om rechten toe te kennen:</p>
    
    <stripes:select id="organizationIds" name="selectedOrgIds" multiple="true" size="5">
        <stripes:option value="">-Selecteer organisaties-</stripes:option>
        <stripes:options-collection collection="${actionBean.orgs}" value="id" label="name" />
    </stripes:select> 
</stripes:form>