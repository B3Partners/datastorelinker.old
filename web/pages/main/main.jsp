<%--
    Document   : main
    Created on : 23-apr-2010, 15:41:03
    Author     : Erik van de Pol
--%>

<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:layout-render name="/pages/templates/default.jsp" pageTitle="DataStoreLinker">
    <stripes:layout-component name="content">

        <script type="text/javascript">
            $(document).ready(function() {
                $("#tabs").tabs({
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
                    }
                });

                //$("#tabs").layout(defaultLayoutOptions);
                //$("#tabHome").layout(defaultLayoutOptions);
                //$("#tabManagement").layout(defaultLayoutOptions);
                //$("#tabOptions").layout(defaultLayoutOptions);
            });
        </script>

        <div id="tabs" class="ui-layout-center" style="height: 100%">
            <ul>
                <li>
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction" title="tabHome">
                        <fmt:message key="menu.home"/>
                    </stripes:link>
                </li>
                <li>
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.ManagementAction" title="tabManagement">
                        <fmt:message key="menu.management"/>
                    </stripes:link>
                </li>
                <li>
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.OptionsAction" title="tabOptions">
                        <fmt:message key="menu.options"/>
                    </stripes:link>
                </li>
            </ul>
            <div id="tabsTarget" class="ui-layout-content" style="height: 100%">
                <div id="tabHome" title="tabHome" style="height: 100%"></div>
                <div id="tabManagement" title="tabManagement" style="height: 100%"></div>
                <div id="tabOptions" title="tabOptions" style="height: 100%"></div>
            </div>
        </div>

    </stripes:layout-component>
</stripes:layout-render>
