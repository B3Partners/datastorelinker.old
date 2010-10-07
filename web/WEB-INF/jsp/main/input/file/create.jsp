<%-- 
    Document   : newFile
    Created on : 3-mei-2010, 18:08:37
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>
<%@include file="/WEB-INF/jsp/commons/urls.jsp" %>

<script type="text/javascript">
    $(document).ready(function() {
        $("#createInputBackButton, #createInputNextButton").button();

        $("#createInputForm").formwizard(
            $.extend({}, formWizardConfig, {
                formOptions: {
                    global: false,
                    beforeSend: function() {
                        if ($("#createInputForm input:radio:checked").length == 0) {
                            $("<div></div").html(I18N.finishFileFail).dialog($.extend({}, defaultDialogOptions, {
                                title: I18N.error,
                                buttons: {
                                    "<fmt:message key="ok"/>": function() {
                                        $(this).dialog("close");
                                    }
                                }
                            }));
                            return false;
                        }

                        //$.blockUI(blockUIOptions);
                        ajaxOpen({
                            formSelector: "#createInputForm",
                            event: "createFileInputComplete",
                            containerSelector: "#inputListContainer",
                            successAfterContainerFill: function() {
                                //$.unblockUI(unblockUIOptions);
                                $("#inputContainer").dialog("close");
                            }
                        });
                        return false;
                    }
                }
            })
        );

        $("#inputContainer").layout(defaultDialogLayoutOptions);

        // layout plugin messes up z-indices; sets them to 1
        $("#inputContainer, #SelecteerBestand, #inputContainer .wizardButtonsArea").css({ "z-index": "auto" });
    });

</script>

<stripes:form id="createInputForm" beanclass="nl.b3p.datastorelinker.gui.stripes.InputAction">
    <stripes:wizard-fields/>
    <div id="<fmt:message key="inputFile.selectFile.short"/>" class="step submitstep ui-layout-center">
        <%@include file="/WEB-INF/jsp/main/file/main.jsp" %>
    </div>

    <div class="wizardButtonsArea ui-layout-south">
        <stripes:reset id="createInputBackButton" name="resetDummyName"/>
        <stripes:submit id="createInputNextButton" name="createFileInputComplete"/>
    </div>
</stripes:form>