<%-- 
    Document   : newDatabase
    Created on : 3-mei-2010, 18:08:19
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#databaseAccordion").accordion();
    });
</script>

<div id="databaseAccordion" class="form-container step">
    <h3><a href="#">PostGIS</a></h3>
    <div>
        <%@include file="/pages/main/database/postgis.jsp" %>
    </div>
    <h3><a href="#">Oracle</a></h3>
    <div>
        <%@include file="/pages/main/database/oracle.jsp" %>
    </div>
    <h3><a href="#">MS Access</a></h3>
    <div>
        <%@include file="/pages/main/database/msaccess.jsp" %>
    </div>
    <%--h3><a href="#">Geavanceerd</a></h3>
    <div>
        <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction">
            <stripes:hidden name="dbType" value="freestyle" />
        </stripes:form>
    </div--%>
</div>