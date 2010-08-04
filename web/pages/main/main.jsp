<%--
    Document   : main
    Created on : 23-apr-2010, 15:41:03
    Author     : Erik van de Pol
--%>

<%@include file="/pages/commons/taglibs.jsp" %>
<%@include file="/pages/commons/urls.jsp" %>

<stripes:layout-render name="/pages/templates/default.jsp" pageTitle="DataStoreLinker">
    <stripes:layout-component name="content">

        <script type="text/javascript">
            $(document).ready(function() {
                $("#tabs").tabs({
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
                    }
                });

                //$("#tabs").layout(defaultLayoutOptions);
                //$("#tabHome").layout(defaultLayoutOptions);
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
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction" title="tabInput">
                        <fmt:message key="menu.admin.input"/>
                    </stripes:link>
                </li>
                <li>
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.OutputAction" title="tabOutput">
                        <fmt:message key="menu.admin.output"/>
                    </stripes:link>
                </li>
                <li>
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction" title="tabDatabase">
                        <fmt:message key="menu.admin.database"/>
                    </stripes:link>
                </li>
                <li>
                    <stripes:link href="${fileUrl}?admin=" title="tabFile">
                        <fmt:message key="menu.admin.file"/>
                    </stripes:link>
                </li>
            </ul>
            <div id="tabsTarget" class="ui-layout-content" style="height: 100%">
                <div id="tabHome" title="tabHome" style="height: 100%"></div>
                <div id="tabInput" title="tabInput" style="height: 100%"></div>
                <div id="tabOutput" title="tabOutput" style="height: 100%"></div>
                <div id="tabDatabase" title="tabDatabase" style="height: 100%"></div>
                <div id="tabFile" title="tabFile" style="height: 100%"></div>
            </div>
        </div>

    </stripes:layout-component>
</stripes:layout-render>
