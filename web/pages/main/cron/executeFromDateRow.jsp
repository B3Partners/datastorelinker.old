<%-- 
    Document   : executeFromDateRow
    Created on : 8-jul-2010, 21:39:49
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:layout-definition>
    <tr>
        <td>Vanaf</td><!-- TODO: localize! -->
        <td>
            <input type="radio" id="${cronType}Today" name="radioFromDate" value="today" checked="checked" />
            <stripes:label name="fromNow" for="${cronType}Today" />
            <input type="radio" id="${cronType}Date" name="radioFromDate" value="date" />
            <stripes:label name="fromDate" for="${cronType}Date" />
            <stripes:text id="${cronType}From" name="fromDate" class="" />
        </td>
    </tr>
</stripes:layout-definition>