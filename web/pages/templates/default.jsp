<%-- 
    Document   : template
    Created on : 22-apr-2010, 17:57:44
    Author     : Erik van de Pol
--%>

<%@include file="/pages/commons/taglibs.jsp" %>
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
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/main.css" />
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/wizard.css" />
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/actions.css" />

            <script type="text/javascript" src="${contextPath}/scripts/jquery/jquery-latest.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery/jquery-latest.min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery-ui/jquery-ui.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery-ui/jquery-ui-latest.custom.min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery-ui/jquery.ui.datepicker-nl.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.form/jquery.form.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.form.wizard/jquery.form.wizard-latest.js"></script>
            <!--script type="text/javascript" src="${contextPath}/scripts/jquery.form.wizard/jquery.form.wizard-latest-min.js"></script-->
            <script type="text/javascript" src="${contextPath}/scripts/jquery.history/jquery.history.js"></script>
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
            <script type="text/javascript" src="${contextPath}/scripts/jquery.maxzindex.js"></script>
            
            <script type="text/javascript" src="${contextPath}/scripts/json2.min.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/ajax.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/actions.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/database.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.config.js.jsp"></script>

            <stripes:layout-component name="head"/>

            <script type="text/javascript">
                $(document).ready(function() {
                    $("body").layout(defaultLayoutOptions);
                    $("#contenttext").layout(defaultLayoutOptions);
                });
            </script>

        </head>
        <body>
            <div id="contenttext" class="ui-layout-center" style="height: 100%">
                <stripes:layout-component name="content"/>
            </div>
        </body>
    </html>

</stripes:layout-definition>