<%-- 
    Document   : processOverview
    Created on : 22-apr-2010, 19:31:42
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<style type="text/css">
    #processesList { width: 50%; margin-top: 10px; margin-bottom: 10px }
    #processesList .ui-button { margin: 3px; display: block; text-align: left; background: #eeeeee; color: black }
    #processesList .ui-state-hover { background: #FECA40; }
    #processesList .ui-state-active { background: #f2d81c; }
</style>

<script type="text/javascript">
    $(function() {
        $("#processesList").buttonset();

        $("#createProcess").button();
        $("#updateProcess").button();
        $("#deleteProcess").button();
        $("#executeProcess").button();

        $("#createProcess").click(function() {
            $("<div id='createProcessContainer'/>").appendTo(document.body);

            createProcessDialog = $("#createProcessContainer").dialog({
                title: "Nieuw Proces...", // TODO: localization
                width: 900,
                height: 600,
                modal: true,
                close: function() {
                    log("createProcessDialog closing");
                    if ($("#createProcessWizardForm")) {
                        $("#createProcessWizardForm").formwizard("destroy");
                    }
                    createProcessDialog.dialog("destroy");
                    // volgende regel heel belangrijk!!
                    createProcessDialog.remove();
                }
            });
            
            $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.InOutAction"/>", "create", function(data) {
                $("#createProcessContainer").html(data);
            });
            
            return false;
        });

        $("#executeProcess").click(function() {
            $("<div id='executeContainer'/>").appendTo($(document.body));

            executeProcessDialog = $("#executeContainer").dialog({
                title: "Proces uitvoeren...", // TODO: localization
                width: 900,
                height: 600,
                modal: true,
                buttons: {
                    "Annuleren": function() { // TODO: localize
                        $(this).dialog("close");
                    }
                },
                close: function() {
                    executeProcessDialog.dialog("destroy");
                    // volgende regel heel belangrijk!!
                    executeProcessDialog.remove();
                }
            });
            
            ajaxFormEventInto("#processForm", "execute", "#executeContainer");

            return false;
        });
    });

</script>

<stripes:form id="processForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessAction">
    <stripes:label for="main.process.overview.text.overview"/>:

    <div id="processesList">
        <c:forEach var="process" items="${actionBean.processes}" varStatus="status">
            <stripes:radio id="process${status.index}" name="processId" value="${process.id}"/>
            <stripes:label for="process${status.index}"><c:out value="${process.name}"/></stripes:label>
        </c:forEach>
    </div>

    <div id="buttonPanel">
        <stripes:button id="createProcess" name="create"/>
        <stripes:button id="updateProcess" name="update"/>
        <stripes:button id="deleteProcess" name="delete"/>
        <stripes:button id="executeProcess" name="execute"/>
    </div>
        
</stripes:form>