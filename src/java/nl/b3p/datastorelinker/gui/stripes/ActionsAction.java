/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.gui.stripes;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.json.ActionModel;
import nl.b3p.geotools.data.linker.ActionFactory;

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

    private final static ResourceBundle res = ResourceBundle.getBundle("StripesResources");


    private String actionsWorkbenchList;
    private String actionsList;
    private Long selectedProcessId;

    @DefaultHandler
    public Resolution list() {
        return new ForwardResolution(LIST_JSP);
    }

    public Resolution create() {
        actionsWorkbenchList = createActionsWorkbenchList();
        //log.debug(actionsWorkbenchList);

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
        JSONArray parameters = new JSONArray();
        if (actionBlock.getValue() != null) {
            for (List<String> paramList : actionBlock.getValue()) {
                for (String paramName : paramList) {
                    JSONObject paramInterior = new JSONObject();
                    paramInterior.element("paramId", paramName);
                    paramInterior.element("name", res.getString("keys." + paramName.toUpperCase()));
                    paramInterior.element("type", res.getString("keys." + paramName.toUpperCase() + ".type"));
                    parameters.add(paramInterior);
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

        model.setParameters(parameters);
        //log.debug(parameters.toString());

        return model;
    }

    public static void removeViewData(JSONArray actionsListJSONArray) {
        for (Object actionObject : actionsListJSONArray) {
            JSONObject action = (JSONObject)actionObject;

            action.remove("className");
            action.remove("name");
            action.remove("description");

            JSONArray parameters = action.optJSONArray("parameters");
            if (parameters != null) {
                for (Object parameterObject : parameters) {
                    JSONObject parameter = (JSONObject)parameterObject;
                    parameter.remove("name");
                    parameter.remove("type");
                }
            }
        }
    }

    public static void addViewData(JSONArray actionsListJSONArray) {
        for (Object actionObject : actionsListJSONArray) {
            JSONObject action = (JSONObject)actionObject;
            
            String type = action.getString("type");

            action.put("className", res.getString(type + ".type"));
            action.put("name", res.getString(type + ".desc"));
            action.put("description", res.getString(type + ".longdesc"));

            JSONArray parameters = action.optJSONArray("parameters");
            if (parameters != null) {
                for (Object parameterObject : parameters) {
                    JSONObject parameter = (JSONObject)parameterObject;

                    String nameResourceKey = "keys." + parameter.getString("paramId").toUpperCase();
                    parameter.put("name", res.getString(nameResourceKey));
                    parameter.put("type", res.getString(nameResourceKey + ".type"));
                }
            }
        }
    }

    public static void addExpandableProperty(JSONArray actionsListJSONArray) {
        for (Object actionObject : actionsListJSONArray) {
            JSONObject action = (JSONObject)actionObject;

            JSONArray parameters = action.optJSONArray("parameters");
            if (parameters != null) {
                JSONObject parameter = new JSONObject();
                parameter.put("parameter", parameters);
                action.put("parameters", parameter);
            }
        }
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
