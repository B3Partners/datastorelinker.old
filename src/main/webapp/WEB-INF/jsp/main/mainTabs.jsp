<%-- 
    Document   : mainTabs
    Created on : 16-sep-2010, 17:26:40
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="DataStoreLinker">
    <stripes:layout-component name="content">
        <script type="text/javascript" class="ui-layout-ignore">
            $(document).ready(function() {
                $("#content").tabs({
                    select: function(event, ui) {
                        // voorkomt het dubbel voorkomen van id's en dus fouten.
                        $("#tabsTarget").children().empty();
                    },
                    /*fx: {
                        opacity: "toggle"
                    },*/
                    ajaxOptions: {
                        error: function(xhr, status, index, anchor) {
                            $(anchor.hash).html("<fmt:message key="menu.error"/>");
                        },
                        data: {},
                        success: function(data, textStatus) {
                        }
                    },
                    show: function(event, ui) {
                        layoutMain();
                    }
                });
                
            });
        </script>

        <ul>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction" title="tabHome">
                    <fmt:message key="menu.home"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction" title="tabDatabase">
                    <fmt:message key="menu.admin.database"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction" title="tabInput">
                    <fmt:message key="menu.admin.input"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link href="${fileUrl}?admin=" title="tabFile">
                    <fmt:message key="menu.admin.file"/>
                </stripes:link>
            </li>
            <%--li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction" event="processDiagram" title="tabProcessDiagram">
                    <fmt:message key="menu.home.diagram"/>
                </stripes:link>
            </li--%>
  
            <c:if test="${b3p:isUserInRole(pageContext.request,'beheerder')}">
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseOutputAction" title="tabDatabaseOutput">
                    <fmt:message key="menu.admin.database.output"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.OutputActionNew" title="tabTableOutput">
                    <fmt:message key="menu.admin.table.output"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.AuthorizationAction" title="tabAuth" event="admin_org">
                    <fmt:message key="menu.admin.auth.org"/>
                </stripes:link>
            </li>            
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.AuthorizationAction" title="tabUsers" event="admin_users">
                    <fmt:message key="menu.admin.auth.users"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.OutputRightsAction" title="tabOutputRights">
                    <fmt:message key="menu.admin.output.rights"/>
                </stripes:link>
            </li>
            <%-- Voor release 4.2 even uitgecomment. Anders gaan mensen het
            toch proberen en het is nog POC
            --%>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.OutputServicesAction" title="tabOutputServices">
                    <fmt:message key="menu.admin.output.services"/>
                </stripes:link>
            </li>
            </c:if>
        </ul>
        
        <div id="tabsTarget" class="ui-layout-content" style="height: 100%">
            <div id="tabHome" style="height: 100%"></div><!-- class="ui-tabs-hide" : optional class for tabs to prevent Flash of Unstyled Content -->
            <div id="tabDatabase" style="height: 100%"></div>
            <div id="tabInput" style="height: 100%"></div>
            <div id="tabFile" style="height: 100%"></div>
            <%--div id="tabProcessDiagram" style="height: 100%"></div--%>
            
            <c:if test="${b3p:isUserInRole(pageContext.request,'beheerder')}">
                <div id="tabDatabaseOutput" style="height: 100%"></div>
                <div id="tabTableOutput" style="height: 100%"></div>
                <div id="tabAuth" style="height: 100%"></div>
                <div id="tabUsers" style="height: 100%"></div>
                <div id="tabOutputRights" style="height: 100%"></div>
                <div id="tabOutputServices" style="height: 100%"></div>
            </c:if>
        </div>
                        
    </stripes:layout-component>
</stripes:layout-render>