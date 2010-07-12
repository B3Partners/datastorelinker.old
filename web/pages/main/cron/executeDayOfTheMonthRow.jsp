<%-- 
    Document   : executeDayOfTheMonthRow
    Created on : 9-jul-2010, 17:31:41
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:layout-definition>
    <tr>
        <td>Op dag van de maand</td><!-- TODO: localize! -->
        <td>
            <input type="radio" id="${cronType}RadioLastDayOfTheMonth" name="radioDayOfTheMonth" value="today" checked="checked" />
            <stripes:label name="last" for="${cronType}RadioLastDayOfTheMonth" />
            <input type="radio" id="${cronType}RadioDayOfTheMonth" name="radioDayOfTheMonth" value="date" />
            <stripes:label name="day" for="${cronType}RadioDayOfTheMonth" />
            <stripes:text id="${cronType}OnDayOfTheMonth" name="onDayOfTheMonth" class="" />
        </td>
    </tr>
</stripes:layout-definition>