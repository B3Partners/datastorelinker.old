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
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.datastorelinker.json.ActionModel;
import nl.b3p.geotools.data.linker.ActionFactory;

/**
 *
 * @author Erik van de Pol
 */
public class ActionsAction extends DefaultAction {
    private Log log = Log.getInstance(ActionsAction.class);
    
    private final static List<String> RESERVED_JS_KEYWORDS = Arrays.asList("length");
    private final static String SAFE_PREFIX = "SAFE_JS_";

    private final static String VIEW_JSP = "/pages/main/actions/view.jsp";

    private JSONArray actionsWorkbenchList;

    @DefaultHandler
    public Resolution view() {
        actionsWorkbenchList = createActionsWorkbenchList();
        
        return new ForwardResolution(VIEW_JSP);
    }

    private JSONArray createActionsWorkbenchList() {
        JSONArray workbenchList = new JSONArray();

        Map<String, List<List<String>>> actionBlocks = ActionFactory.getSupportedActionBlocks();

        for (Map.Entry<String, List<List<String>>> actionBlock : actionBlocks.entrySet()) {
            ActionModel model = createAction(actionBlock);
            JSONObject action = JSONObject.fromObject(model);
            workbenchList.add(action);
        }
        
        return workbenchList;
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
                        parameters.put(SAFE_PREFIX + paramName, paramInterior);
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

    public JSONArray getActionsWorkbenchList() {
        return actionsWorkbenchList;
    }

    public void setActionsWorkbenchList(JSONArray actionsWorkbenchList) {
        this.actionsWorkbenchList = actionsWorkbenchList;
    }

}
