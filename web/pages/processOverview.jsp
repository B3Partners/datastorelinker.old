<%-- 
    Document   : processOverview
    Created on : 22-apr-2010, 19:31:42
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<style type="text/css">
    /*#feedback { font-size: 1.4em; }*/
    #processList .ui-selecting { background: #FECA40; }
    #processList .ui-selected { background: #f2d81c; /*color: white;*/ }
    #processList { list-style-type: none; margin: 0; padding: 0; width: 60%; }
    #processList li { margin: 3px; padding: 0.4em; /*font-size: 1.4em;*/ height: 18px; background:#eeeeee}
</style>

<script type="text/javascript">
$(function() {
    $("#processList").selectable();
    $("button, input:submit, a", "#buttonPanel").button();

    $('#newProcess').button()
    $('#editProcess').button()
    $('#deleteProcess').button()

    $('#newProcess').click(function() {
        $("#newProcessWizardForm").formwizard( {
                //form wizard settings
                historyEnabled : true,
                formPluginEnabled: true,
                validationEnabled : true,
                focusFirstInput : true
            },
            {
                //validation settings
            },
            {
                // form plugin settings
            }
        );
        $('#newProcessWizard').dialog('open');
    });

});
</script>


<stripes:label for="processOverview.text.overview"/>:

<ol id="processList">
    <li class="ui-widget-content">Item 1</li>
    <li class="ui-widget-content">Item 2</li>
    <li class="ui-widget-content">Item 3</li>
    <li class="ui-widget-content">Item 4</li>
    <li class="ui-widget-content">Item 5</li>
    <li class="ui-widget-content">Item 6</li>
    <li class="ui-widget-content">Item 7</li>
</ol>

<div id="buttonPanel">
    <stripes:form partial="true" action="#">
        <stripes:button id="newProcess" name="processOverview.buttons.new"/>
        <stripes:button id="editProcess" name="processOverview.buttons.edit"/>
        <stripes:button id="deleteProcess" name="processOverview.buttons.delete"/>
    </stripes:form>
</div>

<c:import url="/pages/newProcess.jsp"/>

