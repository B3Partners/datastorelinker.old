<%-- 
    Document   : executePeriodically
    Created on : 6-jul-2010, 17:24:54
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<stripes:url var="cronInfoUrl" value="/html/cron.htm"/>

<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        $("#cronEachAccordion").accordion();
        $("#cronAccordion").accordion();
        $("#cronAccordion form").each(function(index, value) {
            $(value).validate($.extend({}, defaultValidateOptions, {
                rules: {
                    onDayOfTheMonth: {
                        min: 0,
                        max: 31
                    },
                    onTime: {
                        time: true // custom method gemaakt in jquery.config.js
                    }
                }
            }));
        });
        $("#cronInfo").button({
            icons: { primary: "ui-icon-help" },
            text: false
        });

        // cron defaults:
        var minuteDefault = "00";
        var timeDefault = "01:00";
        var dayOfTheWeekDefault = 1;
        var dayOfTheMonthDefault = "";//"01";
        var monthDefault = 1;

        $("#hourToday, #dayToday, #weekToday, #monthToday, #yearToday").click(function() {
            $(this).siblings(":text").removeClass("required " + defaultValidateOptions.errorClass).val("");
            $(this).siblings(":text").next("label").remove(); // remove possible validation errormessage
        });
        $("#hourDate, #dayDate, #weekDate, #monthDate, #yearDate").click(function() {
            $(this).siblings(":text").addClass("required").datepicker("show");
        });
        $("#hourFrom, #dayFrom, #weekFrom, #monthFrom, #yearFrom").datepicker({
            beforeShow: function(input, inst) {
                $(input).prevAll(":radio").first().prop("checked", true);
                $(input).addClass("required");
            }
        });

        $("#dayOnTime, #weekOnTime, #monthOnTime, #yearOnTime").mask("29:59").val(timeDefault);

        $("#hourOnMinute").mask("59").val(minuteDefault); // values: 0-59

        $.each(I18N.daysOfTheWeek, function(index, value) {
            var option = $("<option></option>").val(index).text(value);
            $("#weekOnDayOfTheWeek").append(option);
        });
        $("#weekOnDayOfTheWeek").val(dayOfTheWeekDefault);

        $("#monthRadioLastDayOfTheMonth, #yearRadioLastDayOfTheMonth").click(function() {
            $(this).siblings(":text").removeClass("required " + defaultValidateOptions.errorClass).val("");
            $(this).siblings(":text").next("label").remove(); // remove possible validation errormessage
        });
        $("#monthRadioDayOfTheMonth, #yearRadioDayOfTheMonth").click(function() {
            $(this).siblings(":text").addClass("required").focus();
        });
        // Enige wat daadwerkelijk "fout" kan gaan is dat de job niet wordt uitgevoerd (bij niet bestaande 29, 30, 31e van de maand).
        // -> Verantwoordelijkheid van de gebruiker! -> Gebruik anders "last day of the month""
        // values: 0-31; 32-39 wordt afgevangen door de validation plugin bij submit poging.
        $("#monthOnDayOfTheMonth, #yearOnDayOfTheMonth").mask("39").val(dayOfTheMonthDefault).click(function() {
            $(this).prevAll(":radio").first().prop("checked", true);
            $(this).addClass("required");
        });

        $.each(I18N.monthsOfTheYear, function(index, value) {
            var option = $("<option></option>").val(index).text(value);
            $("#yearOnMonth").append(option);
        });
        $("#yearOnMonth").val(monthDefault);


        // Fill with existing cron job data
        <c:if test="${not empty actionBean.fromDate}">
            $("#yearFromDate, #monthFromDate, #weekFromDate, #dayFromDate, #hourFromDate").val("${actionBean.fromDate}");
            $("#yearDate, #monthDate, #weekDate, #dayDate, #hourDate").prop("checked", true);
        </c:if>
        <c:if test="${not empty actionBean.onMinute}">
            $("#hourOnMinute").val("${actionBean.onMinute}");
        </c:if>
        <c:if test="${not empty actionBean.onTime}">
            $("#yearOnTime, #monthOnTime, #weekOnTime, #dayOnTime").val("${actionBean.onTime}");
        </c:if>
        <c:if test="${not empty actionBean.onDayOfTheWeek}">
            $("#weekOnDayOfTheWeek").val("${actionBean.onDayOfTheWeek}");
        </c:if>
        <c:if test="${not empty actionBean.onDayOfTheMonth}">
            $("#yearOnDayOfTheMonth, #monthOnDayOfTheMonth").val("${actionBean.onDayOfTheMonth}");
            $("#yearRadioDayOfTheMonth, #monthRadioDayOfTheMonth").prop("checked", true);
        </c:if>
        <c:if test="${not empty actionBean.onMonth}">
            $("#yearOnMonth").val("${actionBean.onMonth}");
        </c:if>
        <c:if test="${not empty actionBean.cronExpression}">
            $("#cronExpression").val("${actionBean.cronExpression}");
        </c:if>

        // klap juiste accordion tabbladen uit:
        <c:if test="${not empty actionBean.cronType}">
            <c:choose>
                <c:when test="${actionBean.cronType == 'ADVANCED'}">
                    $("#cronAccordion").accordion("activate", "#advancedCron");
                </c:when>
                <c:otherwise>
                    $("#cronEachAccordion").accordion("activate",
                        $("#cronEachAccordion :hidden[name='cronType'][value='${actionBean.cronType}']").parent().parent().prev());
                </c:otherwise>
            </c:choose>
        </c:if>
    });

    function submitExecutePeriodicallyForm() {
        var cronDiv = $("#cronAccordion > .ui-state-active");
        var form = null;
        if (cronDiv.attr("id") === "simpleCron") {
            form = cronDiv.next("div").find(".ui-accordion-content-active form")[0];
        } else {
            form = cronDiv.next("div").find("form")[0];
        }
        
        ajaxOpen({
            formSelector: form,
            event: "executePeriodicallyComplete",
            containerSelector: "#processesListContainer",
            successAfterContainerFill: function(data, textStatus, xhr) {
                $("#processContainer").dialog("close");
            }
        });
    }
</script>

<div id="cronAccordion">
    <h3 id="simpleCron"><a href="#"><fmt:message key="simple"/></a></h3>
    <div>
        <div id="cronEachAccordion">
            <h3><a href="#"><fmt:message key="everyHour"/></a></h3>
            <div>
                <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.PeriodicalProcessAction">
                    <!-- wizard-fields nodig voor bewerken voor een periode van een proces: selectedProcessId wordt dan meegenomen -->
                    <stripes:wizard-fields/>
                    <input type="hidden" name="cronType" value="HOUR"/>
                    <table>
                        <stripes:layout-render name="/WEB-INF/jsp/main/cron/executeFromDateRow.jsp" cronType="hour" />
                        <tr>
                            <td><stripes:label name="onMinute" for="hourOnMinute"/></td>
                            <td><stripes:text id="hourOnMinute" name="onMinute" class="required"/></td>
                        </tr>
                    </table>
                </stripes:form>
            </div>
            <h3><a href="#"><fmt:message key="everyDay"/></a></h3>
            <div>
                <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.PeriodicalProcessAction">
                    <!-- wizard-fields nodig voor bewerken voor een periode van een proces: selectedProcessId wordt dan meegenomen -->
                    <stripes:wizard-fields/>
                    <input type="hidden" name="cronType" value="DAY"/>
                    <table>
                        <stripes:layout-render name="/WEB-INF/jsp/main/cron/executeFromDateRow.jsp" cronType="day" />
                        <tr>
                            <td><stripes:label name="onTime" for="dayOnTime"/></td>
                            <td><stripes:text id="dayOnTime" name="onTime" class="required"/></td>
                        </tr>
                    </table>
                </stripes:form>
            </div>
            <h3><a href="#"><fmt:message key="everyWeek"/></a></h3>
            <div>
                <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.PeriodicalProcessAction">
                    <!-- wizard-fields nodig voor bewerken voor een periode van een proces: selectedProcessId wordt dan meegenomen -->
                    <stripes:wizard-fields/>
                    <input type="hidden" name="cronType" value="WEEK"/>
                    <table>
                        <stripes:layout-render name="/WEB-INF/jsp/main/cron/executeFromDateRow.jsp" cronType="week" />
                        <tr>
                            <td><stripes:label name="onDayOfTheWeek" for="weekOnDayOfTheWeek"/></td>
                            <td><stripes:select id="weekOnDayOfTheWeek" name="onDayOfTheWeek" class="required"/></td>
                        </tr>
                        <tr>
                            <td><stripes:label name="onTime" for="weekOnTime"/></td>
                            <td><stripes:text id="weekOnTime" name="onTime" class="required"/></td>
                        </tr>
                    </table>
                </stripes:form>
            </div>
            <h3><a href="#"><fmt:message key="everyMonth"/></a></h3>
            <div>
                <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.PeriodicalProcessAction">
                    <!-- wizard-fields nodig voor bewerken voor een periode van een proces: selectedProcessId wordt dan meegenomen -->
                    <stripes:wizard-fields/>
                    <input type="hidden" name="cronType" value="MONTH"/>
                    <table>
                        <stripes:layout-render name="/WEB-INF/jsp/main/cron/executeFromDateRow.jsp" cronType="month" />
                        <stripes:layout-render name="/WEB-INF/jsp/main/cron/executeDayOfTheMonthRow.jsp" cronType="month" />
                        <tr>
                            <td><stripes:label name="onTime" for="monthOnTime"/></td>
                            <td><stripes:text id="monthOnTime" name="onTime" class="required"/></td>
                        </tr>
                    </table>
                </stripes:form>
            </div>
            <h3><a href="#"><fmt:message key="everyYear"/></a></h3>
            <div>
                <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.PeriodicalProcessAction">
                    <!-- wizard-fields nodig voor bewerken voor een periode van een proces: selectedProcessId wordt dan meegenomen -->
                    <stripes:wizard-fields/>
                    <input type="hidden" name="cronType" value="YEAR"/>
                    <table>
                        <stripes:layout-render name="/WEB-INF/jsp/main/cron/executeFromDateRow.jsp" cronType="year" />
                        <stripes:layout-render name="/WEB-INF/jsp/main/cron/executeDayOfTheMonthRow.jsp" cronType="year" />
                        <tr>
                            <td><stripes:label name="onMonth" for="yearOnMonth"/></td>
                            <td><stripes:select id="yearOnMonth" name="onMonth" class="required"/></td>
                        </tr>
                        <tr>
                            <td><stripes:label name="onTime" for="yearOnTime"/></td>
                            <td><stripes:text id="yearOnTime" name="onTime" class="required"/></td>
                        </tr>
                    </table>
                </stripes:form>
            </div>
        </div>
    </div>
    <h3 id="advancedCron"><a href="#"><fmt:message key="advanced"/></a></h3>
    <div>
        <stripes:form beanclass="nl.b3p.datastorelinker.gui.stripes.PeriodicalProcessAction">
            <!-- wizard-fields nodig voor bewerken voor een periode van een proces: selectedProcessId wordt dan meegenomen -->
            <stripes:wizard-fields/>
            <input type="hidden" name="cronType" value="ADVANCED"/>
            <fmt:message key="cronExpression"/> <stripes:text name="cronExpression"/>
            <a id="cronInfo" href="${cronInfoUrl}" target="_blank"><span>help</span></a>
        </stripes:form>
    </div>
</div>