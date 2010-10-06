<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<stripes:layout-render name="/WEB-INF/jsp/templates/default.jsp" pageTitle="DataStoreLinker login">
    <stripes:layout-component name="content">
        <script type="text/javascript">
            $(document).ready(function() {
                $(".login-info-block").remove();
            });
        </script>

        <div class="login">
            <%@include file="/loginForm.jsp" %>
        </div>

    </stripes:layout-component>
</stripes:layout-render>