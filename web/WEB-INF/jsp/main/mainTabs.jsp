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

                        /*log(ui.panel);
                        $("#tabs").data("currentTabTitle", $(ui.panel).attr("title"));
                        $(ui.panel).removeAttr("title");*/
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
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction" title="tabInput">
                    <fmt:message key="menu.admin.input"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link href="${fileUrl}?admin=" title="tabFile">
                    <fmt:message key="menu.admin.file"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction" title="tabDatabase">
                    <fmt:message key="menu.admin.database"/>
                </stripes:link>
            </li>
            <li>
                <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.OutputAction" title="tabOutput">
                    <fmt:message key="menu.admin.output"/>
                </stripes:link>
            </li>
        </ul>
        <div id="tabsTarget" class="ui-layout-content" style="height: 100%">
            <div id="tabHome" style="height: 100%"></div><!-- class="ui-tabs-hide" : optional class for tabs to prevent Flash of Unstyled Content -->
            <div id="tabInput" style="height: 100%"></div>
            <div id="tabOutput" style="height: 100%"></div>
            <div id="tabDatabase" style="height: 100%"></div>
            <div id="tabFile" style="height: 100%"></div>
        </div>
                        
    </stripes:layout-component>
</stripes:layout-render>