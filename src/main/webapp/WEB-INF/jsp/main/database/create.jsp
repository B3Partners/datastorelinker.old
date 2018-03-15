<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        $("#databaseAccordion").accordion();
        <c:if test="${not empty actionBean.selectedDatabase}">
            $("#databaseAccordion").accordion("activate",
                $("#databaseAccordion input:hidden[name='dbType'][value='<c:out value="${actionBean.selectedDatabase.type}"/>']").parent().parent().prev());
        </c:if>
    });
</script>

<div id="databaseAccordion" class="form-container">
    <h3><a href="#"><fmt:message key="postgis"/></a></h3>
    <div>
        <%@include file="/WEB-INF/jsp/main/database/postgis.jsp" %>
    </div>
    <h3><a href="#"><fmt:message key="oracle"/></a></h3>
    <div>
        <%@include file="/WEB-INF/jsp/main/database/oracle.jsp" %>
    </div>
    <h3><a href="#"><fmt:message key="msaccess"/></a></h3>
    <div>
        <%@include file="/WEB-INF/jsp/main/database/msaccess.jsp" %>
    </div>
    <h3><a href="#"><fmt:message key="wfs"/></a></h3>
    <div>
        <%@include file="/WEB-INF/jsp/main/database/wfs.jsp" %>
    </div>
    <%--h3><a href="#"><fmt:message key="advanced"/></a></h3>
    <div>
        <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
            <stripes:hidden name="dbType" value="freestyle" />
        </stripes:form>
    </div--%>
</div>