<%-- 
    Document   : filetreeWrapper
    Created on : 8-okt-2010, 21:15:49
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<textarea>
    ${actionBean.selectedFilePath}
    <%--%@include file="list.jsp" --%>
</textarea>