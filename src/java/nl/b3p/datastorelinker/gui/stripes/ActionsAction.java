/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import javax.persistence.EntityManager;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.json.ActionModel;
import nl.b3p.geotools.data.linker.ActionFactory;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
@Transactional
public class ActionsAction extends DefaultAction {
    private Log log = Log.getInstance(ActionsAction.class);
    
    public final static List<String> RESERVED_JS_KEYWORDS = Arrays.asList("length");
    public final static String SAFE_PREFIX = "SAFE_JS_";

    private final static String CREATE_JSP = "/pages/main/actions/create.jsp";
    private final static String LIST_JSP = "/pages/main/actions/list.jsp";

    private String actionsWorkbenchList;
    private String actionsList;
    private Long selectedProcessId;

    @DefaultHandler
    public Resolution list() {
        return new ForwardResolution(LIST_JSP);
    }

    public Resolution create() {
        actionsWorkbenchList = createActionsWorkbenchList();
        log.debug(actionsWorkbenchList);

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        if (selectedProcessId == null)
            actionsList = new JSONArray().toString();
        else {
            nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                    session.get(nl.b3p.datastorelinker.entity.Process.class, selectedProcessId);

            actionsList = process.getActions();
        }

        return new ForwardResolution(CREATE_JSP);
    }

    private String createActionsWorkbenchList() {
        JSONArray workbenchList = new JSONArray();

        Map<String, List<List<String>>> actionBlocks = ActionFactory.getSupportedActionBlocks();

        for (Map.Entry<String, List<List<String>>> actionBlock : actionBlocks.entrySet()) {
            ActionModel model = createAction(actionBlock);
            JSONObject action = JSONObject.fromObject(model);
            workbenchList.add(action);
        }
        
        return workbenchList.toString();
    }

    private ActionModel createAction(Map.Entry<String, List<List<String>>> actionBlock) {
        ResourceBundle res = ResourceBundle.getBundle("StripesResources");

        Map parameters = new HashMap();
        if (actionBlock.getValue() != null) {
            for (List<String> paramList : actionBlock.getValue()) {
                for (String paramName : paramList) {
                    Map paramInterior = new HashMap();
                    paramInterior.put("name", res.getString("keys." + paramName.toUpperCase()));
                    paramInterior.put("type", res.getString("keys." + paramName.toUpperCase() + ".type"));
                    if (RESERVED_JS_KEYWORDS.contains(paramName))
                        parameters.put(SAFE_PREFIX + paramName, paramInterior);
                    else
                        parameters.put(paramName, paramInterior);
                }
            }
        }

        ActionModel model = new ActionModel();
        String type = actionBlock.getKey();
        model.setType(type);
        //model.setCssClass("ActionAttributeName");

        model.setClassName(res.getString(type + ".type"));
        model.setName(res.getString(type + ".desc"));
        model.setDescription(res.getString(type + ".longdesc"));

        model.setParameters(JSONObject.fromObject(parameters));
        log.debug(parameters.toString());

        return model;
    }

    public String getActionsWorkbenchList() {
        return actionsWorkbenchList;
    }

    public void setActionsWorkbenchList(String actionsWorkbenchList) {
        this.actionsWorkbenchList = actionsWorkbenchList;
    }

    public String getActionLists() {
        return actionsList;
    }

    public void setActionLists(String actionsList) {
        this.actionsList = actionsList;
    }
    
    public Long getSelectedProcessId() {
        return selectedProcessId;
    }

    public void setSelectedProcessId(Long selectedProcessId) {
        this.selectedProcessId = selectedProcessId;
    }

    public String getActionsList() {
        return actionsList;
    }

    public void setActionsList(String actionsList) {
        this.actionsList = actionsList;
    }

}
