<%-- 
    Document   : template
    Created on : 22-apr-2010, 17:57:44
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<stripes:layout-definition>

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
    <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
            <meta http-equiv="Expires" content="-1" />
            <meta http-equiv="Cache-Control" content="max-age=0, no-store" />

            <title>${pageTitle}</title>

            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/jquery-ui-1.8.2.custom.css" />
            <link rel="stylesheet" type="text/css" href="${contextPath}/scripts/jquery.ui-uploader/styles/jquery-ui-upload.css" />
            <link rel="stylesheet" type="text/css" href="${contextPath}/scripts/jquery.filetree/jquery.filetree.css" />
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/main.css" />
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/wizard.css" />
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/actions.css" />

            <!-- 3rd party libs: -->
            <!-- jQuery (UI) and plugins -->
            <!--
            WARNING: DO NOT switch to minified versions blindly!
            Bugfixes have been applied to (non-minified) jquery ui and qtip for example.
            Create your own minified versions with the Google Closure Compiler: http://code.google.com/closure/compiler/
            -->
            <script type="text/javascript" src="${contextPath}/scripts/jquery/jquery-latest.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery/jquery-latest.min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery-ui/jquery-ui.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery-ui/jquery-ui-latest.custom.min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery.ui.datepicker-nl/jquery.ui.datepicker-nl.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.form/jquery.form.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.form.wizard/jquery.form.wizard-latest.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery.form.wizard/jquery.form.wizard-latest-min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery.validate/jquery.validate.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery.validate/jquery.validate.min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery.validate/jquery.validate.messages_nl.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.blockUI/jquery.blockUI.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.ui-uploader/jquery-flash.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.ui-uploader/jquery-ui-upload.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.ui-uploader/jquery-ui-upload-messages_nl.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.ui-uploader/functions.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.metadata/jquery.metadata.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.layout/jquery.layout-latest.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.maskedinput/jquery.maskedinput-latest.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery.maskedinput/jquery.maskedinput-latest.min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery.scrollTo/jquery.scrollTo.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery.scrollTo/jquery.scrollTo-min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery.filetree/jquery.filetree-latest.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.easing/jquery.easing-latest.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.qtip/jquery.qtip-latest.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery.qtip/jquery.qtip-latest.min.js"></script-->

            <!-- other 3rd party libs -->
            <script type="text/javascript" src="${contextPath}/scripts/json2.min.js"></script>

            <!-- B3p libs: -->
            <script type="text/javascript" src="${contextPath}/scripts/log.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/init.js.jsp"></script>
            <script type="text/javascript" src="<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.i18nAction"/>"></script>
            <script type="text/javascript" src="${contextPath}/scripts/ajax.js"></script>

            <!-- Dsl includes-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery.config.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/actions.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/database.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/initFunctions.js"></script>

            <stripes:layout-component name="head"/>

            <script type="text/javascript">
                $(document).ready(function() {
                    
                });

                function layoutMain() {
                    var mainTabsLayout = $("body").layout($.extend({}, defaultLayoutOptions, {
                        west__size: 50,
                        east__size: 50,
                        north__size: 50,
                        south__size: 50,
                        spacing_open: 0,
                        spacing_close: 0
                    }));
                    createDefaultVerticalLayout($("#centerWrapper"), {
                        north__size: 5,
                        south__size: 5,
                        spacing_open: 0,
                        spacing_close: 0
                    });
                    return mainTabsLayout;
                }
            </script>

        </head>
        <body>
            <div class="ui-layout-north">
                <stripes:layout-component name="header">
                    <jsp:include page="/WEB-INF/jsp/commons/header.jsp"/>
                </stripes:layout-component>
            </div>

            <div class="ui-layout-west">
                <stripes:layout-component name="west">
                    <jsp:include page="/WEB-INF/jsp/commons/west.jsp"/>
                </stripes:layout-component>
            </div>

            <div class="ui-layout-east">
                <stripes:layout-component name="east">
                    <jsp:include page="/WEB-INF/jsp/commons/east.jsp"/>
                </stripes:layout-component>
            </div>

            <div class="ui-layout-south">
                <stripes:layout-component name="footer">
                    <jsp:include page="/WEB-INF/jsp/commons/footer.jsp"/>
                </stripes:layout-component>
            </div>

            <div id="centerWrapper" class="ui-layout-center" style="height: 100%">
                <div>&nbsp;</div>
                <div id="content">
                    <stripes:layout-component name="content"/>
                </div>
                <div>&nbsp;</div>
            </div>

        </body>
    </html>

</stripes:layout-definition>