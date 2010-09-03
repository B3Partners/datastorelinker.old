<%-- 
    Document   : newDatabase
    Created on : 3-mei-2010, 18:08:19
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
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
        <%@include file="/pages/main/database/postgis.jsp" %>
    </div>
    <h3><a href="#"><fmt:message key="oracle"/></a></h3>
    <div>
        <%@include file="/pages/main/database/oracle.jsp" %>
    </div>
    <h3><a href="#"><fmt:message key="msaccess"/></a></h3>
    <div>
        <%@include file="/pages/main/database/msaccess.jsp" %>
    </div>
    <%--h3><a href="#"><fmt:message key="advanced"/></a></h3>
    <div>
        <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
            <stripes:hidden name="dbType" value="freestyle" />
        </stripes:form>
    </div--%>
</div>