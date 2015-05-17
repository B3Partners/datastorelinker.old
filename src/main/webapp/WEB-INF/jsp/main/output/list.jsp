<%-- 
    Document   : outputList
    Created on : 6-mei-2010, 14:58:48
    Author     : Erik van de Pol
--%>
<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<script type="text/javascript" class="ui-layout-ignore">
    $(document).ready(function() {
        initGuiOutput();        
        
        checkIdForAppend();
    });
    
    /* 
    * Voor een gekozen uitvoer ophalen of dit een USE_TABLE template heeft.
    * Zo ja dan vinkje aanzetten voor append. Wordt voor process al wel
    * hardcoded gedaan zodat iemand niet per ongeluk appeend kan vergeten
    * als uitvoer tabel al vaststaat.
    */
    function checkIdForAppend() {            
        var selectedId = $("#outputListContainer :radio:checked").val();
        
        var params = {checkOutputIsUseTableTemplate: "", checkOutputId: selectedId};      
        blokken = $.ajax({
            url: "${outputUrl}",
            data: params,
            dataType: "json",
            global: false
        }).done(function(type) {
            if (type.type == "USE_TABLE") {
                $("#drop").prop("disabled", true);
                //$("#append").prop("checked", true);
                $("#drop").prop("checked", false);
            } else {
                //$("#append").prop("checked", false);
                $("#drop").prop("disabled", false);
            }  
        });
    }
</script>

<div id="outputList">
    <stripes:form partial="true" action="/">
        <c:forEach var="output" items="${actionBean.outputs}" varStatus="status">
            <c:choose>
                <c:when test="${not empty actionBean.selectedOutputId and output.id == actionBean.selectedOutputId}">
                    <input type="radio" id="output${status.index}" name="selectedOutputId" value="${output.id}" class="required" checked="checked" onclick="return checkIdForAppend()" />
                    <script type="text/javascript" class="ui-layout-ignore">
                        $(document).ready(function() {
                            $("#outputList").parent().scrollTo(
                                $("#output${status.index}"),
                                defaultScrollToDuration,
                                defaultScrollToOptions
                            );
                        });
                    </script>
                </c:when>
                <c:otherwise>
                    <input type="radio" id="output${status.index}" name="selectedOutputId" value="${output.id}" class="required" onclick="return checkIdForAppend()"/>
                </c:otherwise>
            </c:choose>
            <stripes:label for="output${status.index}">
                <c:out value="${output.name}"/>
            </stripes:label>
        </c:forEach>
    </stripes:form>
</div>