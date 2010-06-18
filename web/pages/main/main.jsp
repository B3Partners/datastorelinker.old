<%-- 
    Document   : main
    Created on : 23-apr-2010, 15:41:03
    Author     : Erik van de Pol
--%>

<%@include file="/pages/commons/taglibs.jsp" %>

<stripes:layout-render name="/pages/templates/default.jsp" pageTitle="DataStoreLinker">
    <stripes:layout-component name="content">

        <script type="text/javascript">
            $(function() {
                $.blockUI;
                $('#tabs').tabs( {
                    ajaxOptions: {
                        error: function(xhr, status, index, anchor) {
                            $.unblockUI;
                            $(anchor.hash).html("Fout. Kon deze tab niet laden.");
                        },
                        data: {},
                        success: function(data, textStatus) {
                            $.unblockUI;
                        }
                    }
                });
            });
        </script>

        <div id="tabs" class="ui-layout-center">
            <ul>
                <li>
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
                        <stripes:label for="menu.home"/> <%-- TODO: !!! moet eigenlijk met <fmt:message key="menu.home"/> etc. !!!--%>
                    </stripes:link>
                </li>
                <li>
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.ManagementAction">
                        <stripes:label for="menu.management"/>
                    </stripes:link>
                </li>
                <li>
                    <stripes:link beanclass="nl.b3p.datastorelinker.gui.stripes.OptionsAction">
                        <stripes:label for="menu.options"/>
                    </stripes:link>
                </li>
            </ul>
        </div>
        
    </stripes:layout-component>
</stripes:layout-render>
