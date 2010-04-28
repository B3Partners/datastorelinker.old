<%-- 
    Document   : newProcess
    Created on : 23-apr-2010, 19:25:55
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<style type="text/css">
    #inputList { width: 50%; margin-top: 10px; margin-bottom: 10px }
    #inputList .ui-button { margin: 3px; display: block; text-align: left; background: #eeeeee; color: black }
    #inputList .ui-state-hover { background: #FECA40; }
    #inputList .ui-state-active { background: #f2d81c; }

    #outputList { width: 50%; margin-top: 10px; margin-bottom: 10px }
    #outputList .ui-button { margin: 3px; display: block; text-align: left; background: #eeeeee; color: black }
    #outputList .ui-state-hover { background: #FECA40; }
    #outputList .ui-state-active { background: #f2d81c; }

</style>

<script type="text/javascript">
    $(function() {
        $("#inputList").buttonset();
        $("#outputList").buttonset();

        $("#newProcessBackButton").button();
        $("#newProcessNextButton").button();

        $("#newProcessWizardForm").formwizard( {
            //form wizard settings
            historyEnabled : false,
            formPluginEnabled : true,
            validationEnabled : false,
            focusFirstInput : true,
            textNext : "Volgende",
            textBack : "Vorige",
            textSubmit : "Voltooien",
            inAnimation : "slideDown", //"show",
            outAnimation : "slideUp" //"hide"
        }, {
            //validation settings
        }, {
            // form plugin settings
            target: "#ui-tabs-1",
            success: function() {
                log("success!");
                //log($("#newProcessContainer"));
                //$("#newProcessContainer").dialog("destroy");
                //log(newProcessDialog);
                //
                newProcessDialog.dialog("close");
            }
        });
    });

</script>

<stripes:form id="newProcessWizardForm" beanclass="nl.b3p.datastorelinker.gui.stripes.ProcessOverviewAction">
    <div id="SelecteerInvoer" class="step">
        <h1>Selecteer bestand- of database-invoer:</h1>
        <div id="inputList">
            <c:forEach var="input" items="${actionBean.inputs}" varStatus="status">
                <stripes:radio id="input${status.index}" name="inputId" value="${input.id}"/>
                <stripes:label for="input${status.index}">
                    <c:choose>
                        <c:when test="${input.datatypeId.id == 1}">
                            <c:out value="${input.databaseId.name}"/>
                        </c:when>
                        <c:when test="${input.datatypeId.id == 2}">
                            <c:out value="${input.fileId.name}"/>
                        </c:when>
                    </c:choose>
                    <c:if test="${input.tableName != ''}">
                        (<c:out value="${input.tableName}"/>)
                    </c:if>
                </stripes:label>
            </c:forEach>
        </div>
    </div>
    <div id="SelecteerUitvoer" class="step">
        <h1>Selecteer database om naar uit te voeren:</h1>
        <div id="outputList">
            <c:forEach var="output" items="${actionBean.outputs}" varStatus="status">
                <stripes:radio id="output${status.index}" name="outputId" value="${output.id}"/>
                <stripes:label for="output${status.index}">
                    <c:out value="${output.databaseId.name}"/>
                </stripes:label>
            </c:forEach>
        </div>
    </div>
    <!--div id="secondStep" class="step">
        <h1>step 2 - branch step</h1>
        <input  type="text" value="" /><br />
        <input  type="text" value="" /><br />
        <input  type="text" value="" /><br />
        <select  class="link" >
            <option value="" >Choose the step to go to...</option>
            <option value="thirdStep" >Go to Step3</option>
            <option value="fourthStep" >Go to Step4</option>
        </select><br />
    </div>
    <div id="thirdStep" class="step submit_step">
        <h1>step 3 - submit step</h1>
        <input  type="text" value="" /><br />
        <input  type="text" value="" class="required"/><br />
    </div>
    <div id="fourthStep" class="step">
        <h1>step 4</h1>
        <input  type="text" value="" /><br />
        <input  type="text" name="email" class="required email" /><br />
    </div>
    <div id="lastStep" class="step">
        <h1>step 5 - last step</h1>
        <input  type="text" value="" /><br />
        <input  type="text" value="" /><br />
    </div-->
    <stripes:reset id="newProcessBackButton" name="resetDummyName"/>
    <stripes:submit id="newProcessNextButton" name="newComplete"/>
</stripes:form>