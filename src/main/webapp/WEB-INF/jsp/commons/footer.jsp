<%-- 
    Document   : footer
    Created on : 16-sep-2010, 17:32:32
    Author     : Erik van de Pol
--%>

<%@include file="/WEB-INF/jsp/commons/taglibs.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<div id="footer">
    <div id="footer_content">
        <div id="footer_tekst_links" class="footer_tekst">This program is distributed under the terms of the <a class="gpl_link" href="http://www.gnu.org/licenses/gpl.html">GNU General Public License</a></div>
        <div id="footer_tekst_rechts" class="footer_tekst">B3P DataStoreLinker ${project.version} ${builddetails.commit.id.abbrev}</div>
    </div>
</div>