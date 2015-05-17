<%-- 
    Document   : executeDayOfTheMonthRow
    Created on : 9-jul-2010, 17:31:41
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<stripes:layout-definition>
    <tr>
        <td><fmt:message key="onDayOfTheMonth"/></td>
        <td>
            <input type="radio" id="${cronType}RadioLastDayOfTheMonth" name="radioDayOfTheMonth" value="today" checked="checked" />
            <stripes:label name="last" for="${cronType}RadioLastDayOfTheMonth" />
            <input type="radio" id="${cronType}RadioDayOfTheMonth" name="radioDayOfTheMonth" value="date" />
            <stripes:label name="day" for="${cronType}RadioDayOfTheMonth" />
            <stripes:text id="${cronType}OnDayOfTheMonth" name="onDayOfTheMonth" class="" />
        </td>
    </tr>
</stripes:layout-definition>