<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        <c:choose>
            <c:when test="${not empty actionBean.selectedUser}">
                $("#userOrgId").val("<c:out value="${actionBean.selectedUser.organization.id}"/>");
                $("#userName").val("<c:out value="${actionBean.selectedUser.name}"/>"); 
                
                <c:if test="${actionBean.selectedUser.isAdmin}">
                    $("#userIsAdmin").attr('checked', true);
                </c:if>                    
                <c:if test="${!actionBean.selectedUser.isAdmin}">
                    $("#userIsAdmin").attr('checked', false);
                </c:if>  
            </c:when>                
            <c:otherwise>
                $("#userName").val("");
                $("#userPassword").val("");
                $("#userPasswordAgain").val("");
            </c:otherwise>
        </c:choose>
    });
</script>

<stripes:form id="userForm" action="#">
    <c:if test="${not empty actionBean.selectedUserId}">
        <stripes:hidden name="selectedUserId" value="${actionBean.selectedUserId}"/>
    </c:if>
    <table>
        <tbody>
            <tr>
                <td><fmt:message key="keys.org"/></td>
                <td>
                    <stripes:select id="userOrgId" name="userOrg">
                    <c:forEach var="org" items="${actionBean.orgs}" varStatus="status">
                        <stripes:option value="${org.id}">${org.name}</stripes:option>
                    </c:forEach>
                    </stripes:select>
                </td> 
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td>* <fmt:message key="keys.name"/></td>
                <td><stripes:text id="userName" name="userName" class="required" size="40" /></td>
                <td><div id="msgUserName" class="verplichteInvoer"/></div>
            </tr>
            <tr>
                <td><fmt:message key="keys.pw"/></td>
                <td><stripes:password id="userPassword" name="userPassword" class="required" size="40"/></td>
                <td><div id="msgUserPassword" class="verplichteInvoer"/></div>
            </tr>
            <tr>
                <td><fmt:message key="keys.pwagain"/></td>
                <td>
                    <stripes:password id="userPasswordAgain" name="userPasswordAgain" class="required" size="40"/>
                </td>
            </tr> 
            <tr>
                <td><fmt:message key="keys.admin"/></td>
                <td><stripes:checkbox id="userIsAdmin" name="userIsAdmin" class="required" /></td>
            </tr>  
        </tbody>
    </table>
</stripes:form>