<%--
    Document   : create
    Created on : 3-mei-2010, 18:03:12
    Author     : Erik van de Pol
--%>
<%@include file="/pages/commons/taglibs.jsp" %>

<script type="text/javascript">
    $(function() {
        $("#createDB").button();
        $("#updateDB").button();
        $("#deleteDB").button();

        $("#databasesList").buttonset();

        $("#createInputBackButton").button();
        $("#createInputNextButton").button();

        // originele config wordt hier gecloned zodat we extra config kunnen toevoegen (bv afterNext)
        // die we niet in andere form wizards willen hebben
        formWizardConfigInputForm = eval(formWizardConfig.toSource());
        formWizardConfigInputForm.afterNext = function(wizardData) {
            log(wizardData.currentStep);
            if (wizardData.currentStep === "SelecteerTabel") {
                log("createTablesList&selectedDatabaseId=" + $("#createInputForm .ui-state-active").prev()[0].value);
                $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction"/>",
                    "createTablesList&selectedDatabaseId=" + $("#createInputForm .ui-state-active").prev()[0].value,
                    function(data) {
                        log("table success!");
                        $("#tablesList").html(data);
                        $("#tablesList").buttonset();
                });
            }
        };

        $("#createInputForm").formwizard(
            formWizardConfigInputForm, {
                //validation settings
            }, {
                // form plugin settings
                beforeSend: function() {
                    // beetje een lelijke hack, maar werkt wel mooi:
                    ajaxFormEventInto("#createInputForm", "createDatabaseInputComplete", "#inputList", function() {
                        log("success!");
                        if ($("#createInputDBContainer"))
                            $("#createInputDBContainer").dialog("close");
                        $("#inputList").buttonset();
                    });
                    return false;
                }
            }
        );

        $("#createDB").click(function() {
            $("<div id='dbContainer'/>").appendTo(document.body);

            $("#dbContainer").dialog({
                title: "Nieuwe Database...", // TODO: localization
                width: 700,
                height: 600,
                modal: true,
                buttons: { // TODO: localize button name:
                    "Voltooien" : function() {
                        // is deze button wel disabled totdat dialog alles ready is
                        ajaxFormEventInto(".form-container .ui-accordion-content-active form", "createComplete", "#databasesList", function() {
                            $("#dbContainer").dialog("close");
                            $("#databasesList").buttonset();
                        });
                    }
                },
                close: function() {
                    log("dbContainer closing");
                    $("#dbContainer").dialog("destroy");
                    // volgende regel heel belangrijk!!
                    $("#dbContainer").remove();
                },
                beforeclose: function(event, ui) {
                    // TODO: check connection. if bad return false
                    return true;
                }
            });

            $.get("<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction"/>", "create", function(data) {
                $("#dbContainer").html(data);
            });
        })

        $("#updateDB").click(function() {
            $("<div id='dbContainer'/>").appendTo(document.body);

            $("#dbContainer").dialog({
                title: "Bewerk Database...", // TODO: localization
                width: 700,
                height: 600,
                modal: true,
                buttons: { // TODO: localize button name:
                    "Voltooien" : function() {
                        // is deze button wel disabled totdat dialog alles ready is
                        ajaxFormEventInto(".form-container .ui-accordion-content-active form", "createComplete", "#databasesList", function() {
                            $("#dbContainer").dialog("close");
                            $("#databasesList").buttonset();
                        });
                    }
                },
                close: function() {
                    log("dbContainer closing");
                    $("#dbContainer").dialog("destroy");
                    // volgende regel heel belangrijk!!
                    $("#dbContainer").remove();
                },
                beforeclose: function(event, ui) {
                    // TODO: check connection. if bad return false
                    return true;
                }
            });

            ajaxFormEventInto("#createInputForm", "update", "#dbContainer", null,
                "<stripes:url beanclass="nl.b3p.datastorelinker.gui.stripes.DatabaseAction"/>");
        })

    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <stripes:wizard-fields/>
    <div id="SelecteerDatabaseconnectie" class="step">
        <h1>Selecteer databaseconnectie:</h1>
        <div id="databasesList" class="radioList">
            <%@include file="/pages/main/database/list.jsp" %>
        </div>
        <div>
            <stripes:button id="createDB" name="create"/>
            <stripes:button id="updateDB" name="update"/>
            <stripes:button id="deleteDB" name="delete"/>
        </div>
    </div>
    <div id="SelecteerTabel" class="step submitstep">
        <h1>Selecteer tabel:</h1>
        <div id="tablesList" class="radioList">
            Bezig met laden...
        </div>
    </div>

    <div class="wizardButtonsArea">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createDatabaseInputComplete"/>
    </div>
</stripes:form>