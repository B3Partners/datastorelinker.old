<%-- 
    Document   : executeFromDateRow
    Created on : 8-jul-2010, 21:39:49
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<stripes:layout-definition>
    <tr>
        <td><fmt:message key="from"/></td>
        <td>
            <input type="radio" id="${cronType}Today" name="radioFromDate" value="today" checked="checked" />
            <stripes:label name="fromNow" for="${cronType}Today" />
            <input type="radio" id="${cronType}Date" name="radioFromDate" value="date" />
            <stripes:label name="fromDate" for="${cronType}Date" />
            <stripes:text id="${cronType}From" name="fromDate" class="" />
        </td>
    </tr>
</stripes:layout-definition>