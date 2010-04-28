<%-- 
    Document   : template
    Created on : 22-apr-2010, 17:57:44
    Author     : Erik van de Pol
--%>

<%@include file="/pages/commons/taglibs.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<stripes:layout-definition>

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <meta http-equiv="Expires" content="-1" />
            <meta http-equiv="Cache-Control" content="max-age=0, no-store" />

            <title>${pageTitle}</title>

            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/jquery-ui-1.8.custom.css">

            <!--link rel="stylesheet" type="text/css" href="${contextPath}/styles/main.css">
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/b3p.css">
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/gui.css"-->
            <!--[if lte IE 6]>
            <link rel="stylesheet" type="text/css" href="${contextPath}/styles/main-ie.css">
            <![endif]-->

            <!--script type="text/javascript" src="${contextPath}/scripts/utils.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/simple_treeview.js"></script-->

            <script type="text/javascript" src="${contextPath}/scripts/jquery/jquery-latest.min.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery-ui/jquery-ui-latest.custom.min.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.form/jquery.form.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.form.wizard/jquery.form.wizard-latest-min.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.history/jquery.history.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/jquery.validate/jquery.validate.min.js"></script>
            <script type="text/javascript" src="${contextPath}/scripts/ajaxformutils.js"></script>

            <stripes:layout-component name="head"/>
        </head>
        <body>
            <div id="contenttext">
                <stripes:layout-component name="content"/>
            </div>
        </body>
    </html>

</stripes:layout-definition>