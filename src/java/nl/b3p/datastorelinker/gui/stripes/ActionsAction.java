package nl.b3p.datastorelinker.gui.stripes;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import net.sf.json.JSONArray;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.ActionBeanContext;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.json.ActionModel;
import nl.b3p.geotools.data.linker.ActionFactory;

/**
 *
 * @author Boy de Wit
 */
@Transactional
public class ActionsAction extends DefaultAction {

    private final static Log log = Log.getInstance(ActionsAction.class);
    
    public final static List<String> RESERVED_JS_KEYWORDS = Arrays.asList("length");
    public final static String SAFE_PREFIX = "SAFE_JS_";

    private final static String CREATE_JSP = "/WEB-INF/jsp/main/actions/create.jsp";
    private final static String LIST_JSP = "/WEB-INF/jsp/main/actions/list.jsp";

    private static ResourceBundle res = null;

    private String actionsWorkbenchList;
    private String actionsList;
    private Long selectedProcessId;
    
    private static String[] inputColumns;
    private static String[] outputColumns;
    private static String templateOutputType;
    
    private static String outputTablename;
    private static String externalFileName;

    private static void resourceBundleInit(ActionBeanContext context) {
        //DefaultLocalePicker defaultLocalePicker = new DefaultLocalePicker();
        res = ResourceBundle.getBundle(
            "StripesResources",
            context.getLocale());
    }

    @DefaultHandler
    public Resolution list() {
        return new ForwardResolution(LIST_JSP);
    }

    public Resolution create() {
        actionsWorkbenchList = createActionsWorkbenchList();

        return new ForwardResolution(CREATE_JSP);
    }

    private String createActionsWorkbenchList() {
        JSONArray workbenchList = new JSONArray();
        
        /* Ophalen List van invoerkolommen zodat het Mappen naar uitvoer block
         * aangemaakt kan worden. Alleen bij uitvoer template optie 1 en 2. Bij optie 3 moet
         * de gebruiker zelf zijn tabel samenstellen mbv blokken */
        Map<String, List<List<String>>> actionBlocks = ActionFactory.getSupportedActionBlocks(inputColumns, outputColumns, templateOutputType);

        for (Map.Entry<String, List<List<String>>> actionBlock : actionBlocks.entrySet()) {
            ActionModel model = createAction(actionBlock);
            JSONObject action = JSONObject.fromObject(model);
            workbenchList.add(action);
        }
        
        return workbenchList.toString();
    }
    
    public static JSONArray createDefaultActionList(ActionBeanContext context) {
        if (res == null) {
            res = ResourceBundle.getBundle("StripesResources", context.getLocale());
        }
        
        JSONArray workbenchList = new JSONArray();
        
        if (templateOutputType != null && templateOutputType.equals(Inout.TEMPLATE_OUTPUT_USE_TABLE)) {
            workbenchList = getDefaultUseTableActionBlocks(context);
        }
        
        if (templateOutputType != null && templateOutputType.equals(Inout.TEMPLATE_OUTPUT_AS_TEMPLATE)) {
            workbenchList = getDefaultUseAsTemplateActionBlocks(context);
        }
        
        if (templateOutputType != null && templateOutputType.equals(Inout.TEMPLATE_OUTPUT_NO_TABLE)) {
            workbenchList = getDefaultNoTableActionBlocks(context);
        }
        
        return workbenchList;
    }
    
    private static JSONArray getDefaultUseTableActionBlocks(ActionBeanContext context) {
        JSONArray workbenchList = new JSONArray();
        
        Map<String, List<List<String>>> actionBlocks = ActionFactory.createDefaultUseTableActionBlocks(outputColumns);

        for (Map.Entry<String, List<List<String>>> actionBlock : actionBlocks.entrySet()) {
            ActionModel model = createDefaultAction(actionBlock);
            
            JSONObject action = JSONObject.fromObject(model);
            
            /* TODO: Parameters klaarzetten voor blokken */
            JSONArray parameters = action.optJSONArray("parameters");
            for (Object parameterObject : parameters) {
                JSONObject parameter = (JSONObject)parameterObject;
                addParameterViewData(parameter, context);
            }
            
            workbenchList.add(action);
        }  
        
        return workbenchList;
    }
    
    private static JSONArray getDefaultUseAsTemplateActionBlocks(ActionBeanContext context) {
        JSONArray workbenchList = new JSONArray();
        
        Map<String, List<List<String>>> actionBlocks = ActionFactory.createDefaultUseAsTemplateActionBlocks(outputColumns);

        for (Map.Entry<String, List<List<String>>> actionBlock : actionBlocks.entrySet()) {
            ActionModel model = createDefaultAction(actionBlock);
            
            /* TODO: Parameters klaarzetten voor blokken */
            
            JSONObject action = JSONObject.fromObject(model);
            workbenchList.add(action);
        }  
        
        return workbenchList;
    }
    
    private static JSONArray getDefaultNoTableActionBlocks(ActionBeanContext context) {
        JSONArray workbenchList = new JSONArray();
        
        Map<String, List<List<String>>> actionBlocks = ActionFactory.createDefaultNoTableActionBlocks(inputColumns);

        for (Map.Entry<String, List<List<String>>> actionBlock : actionBlocks.entrySet()) {
            ActionModel model = createDefaultAction(actionBlock);
            
            /* TODO: Parameters klaarzetten voor blokken */
            
            JSONObject action = JSONObject.fromObject(model);
            workbenchList.add(action);
        }  
        
        return workbenchList;
    }
    
    private static ActionModel createDefaultAction(Map.Entry<String, List<List<String>>> actionBlock) {      
        JSONArray parameters = new JSONArray();
        List<List<String>> actionBlockValue = actionBlock.getValue();
        if (actionBlockValue != null && !actionBlockValue.isEmpty()) {
            // only use the first constructor type:
            List<String> paramList = actionBlockValue.get(0);
            for (String paramName : paramList) {
                JSONObject paramInterior = new JSONObject();  
                
                if (templateOutputType != null && templateOutputType.equals(Inout.TEMPLATE_OUTPUT_USE_TABLE) &&
                    outputTablename != null && paramName.equals("new_typename")) { 
                    
                    paramInterior.element("value", outputTablename);
                }
                
                if (templateOutputType != null && templateOutputType.equals(Inout.TEMPLATE_OUTPUT_USE_TABLE) &&
                        outputTablename != null && paramName.equals("append")) {  
                    
                    paramInterior.element("value", "false");
                }
                
                if (paramName.contains("srs")) {
                    paramInterior.element("value", "EPSG:28992");
                }
        
                if (paramName.contains("inputmapping.")) {
                    paramInterior.element("paramId", paramName.replaceAll("inputmapping.", ""));
                } else if (paramName.contains("outputmapping.")) {
                    paramInterior.element("paramId", paramName.replaceAll("outputmapping.", ""));
                } else {
                    paramInterior.element("paramId", paramName);
                }
                
                if (paramName.contains("inputmapping.")) {
                    paramName = paramName.replaceAll("inputmapping.", "");
                    
                    paramInterior.element("name", paramName);
                    paramInterior.element("type", paramName + ".type");
                    paramInterior.element("optional", paramName + ".optional");
                    paramInterior.element("inputmapping", "true");
                }
                
                if (paramName.contains("outputmapping.")) {
                    paramName = paramName.replaceAll("outputmapping.", "");
                    
                    paramInterior.element("name", paramName);
                    paramInterior.element("type", paramName + ".type");
                    paramInterior.element("optional", paramName + ".optional");
                    paramInterior.element("outputmapping", "true");
                }               
                        
                /* TODO: Kijken of deze manier van parameters met een resource anders kan? */
                try {
                    if (res != null) {
                        paramInterior.element("name", res.getString("keys." + paramName.toUpperCase()));
                        paramInterior.element("type", res.getString("keys." + paramName.toUpperCase() + ".type"));                   
                        paramInterior.element("optional", res.getString("keys." + paramName.toUpperCase() + ".optional"));                   
                    }
                } catch (MissingResourceException mre) {}                
                
                parameters.add(paramInterior);
            }
        }

        ActionModel model = new ActionModel();
        String type = actionBlock.getKey();
        model.setType(type);
        //model.setCssClass("ActionAttributeName");

        if (res != null) {
            model.setClassName(res.getString(type + ".type"));
            model.setImageFilename(res.getString(type + ".image"));
            model.setName(res.getString(type + ".desc"));
            model.setDescription(res.getString(type + ".longdesc"));
        }        

        model.setParameters(parameters);

        return model;
    }

    private ActionModel createAction(Map.Entry<String, List<List<String>>> actionBlock) {
        resourceBundleInit(getContext());

        JSONArray parameters = new JSONArray();
        List<List<String>> actionBlockValue = actionBlock.getValue();
        if (actionBlockValue != null && !actionBlockValue.isEmpty()) {
            // only use the first constructor type:
            List<String> paramList = actionBlockValue.get(0);
            for (String paramName : paramList) {
                JSONObject paramInterior = new JSONObject(); 
                
                /* Externe bestandsnaam met dezelfde naam als dxf al voor 
                 * invullen */
                if (paramName.equals("attribute_name_other_file_name")) {
                    String param = "";
                    if (externalFileName != null) {                        
                        String fName = externalFileName.substring(0, externalFileName.lastIndexOf('.'));
                        param = fName + ".xls";                      
                    }
                    
                    paramInterior.element("value", param);
                }
                
                if (paramName.contains("inputmapping.")) {
                    paramInterior.element("paramId", paramName.replaceAll("inputmapping.", ""));
                } else if (paramName.contains("outputmapping.")) {
                    paramInterior.element("paramId", paramName.replaceAll("outputmapping.", ""));
                } else {
                    paramInterior.element("paramId", paramName);
                }
                
                if (paramName.contains("inputmapping.")) {
                    paramName = paramName.replaceAll("inputmapping.", "");
                    
                    paramInterior.element("name", paramName);
                    paramInterior.element("type", paramName + ".type");
                    paramInterior.element("optional", paramName + ".optional");
                    paramInterior.element("inputmapping", "true");
                }
                
                if (paramName.contains("outputmapping.")) {
                    paramName = paramName.replaceAll("outputmapping.", "");
                    
                    paramInterior.element("name", paramName);
                    paramInterior.element("type", paramName + ".type");
                    paramInterior.element("optional", paramName + ".optional");
                    paramInterior.element("outputmapping", "true");
                }
                
                /* TODO: Kijken of deze manier van parameters met een resource anders kan? */
                try {
                    paramInterior.element("name", res.getString("keys." + paramName.toUpperCase()));
                    paramInterior.element("type", res.getString("keys." + paramName.toUpperCase() + ".type"));                   
                    paramInterior.element("optional", res.getString("keys." + paramName.toUpperCase() + ".optional"));                   
                } catch (MissingResourceException mre) {}                
                
                parameters.add(paramInterior);
            }
        }

        ActionModel model = new ActionModel();
        String type = actionBlock.getKey();
        model.setType(type);
        //model.setCssClass("ActionAttributeName");

        model.setClassName(res.getString(type + ".type"));
        model.setImageFilename(res.getString(type + ".image"));
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
            action.remove("imageFilename");
            action.remove("name");
            action.remove("description");

            JSONArray parameters = action.optJSONArray("parameters");
            if (parameters != null) {
                for (Object parameterObject : parameters) {
                    JSONObject parameter = (JSONObject)parameterObject;
                    parameter.remove("name");
                    parameter.remove("type");// old: type needed by dsl backend (Geotools)
                    parameter.remove("optional");
                }
            }
        }
    }

    /**
     * Also puts parameters in an array instead of an object if we dealing with a single parameter.
     * This is caused by the JSON to XML serialization and back.
     * @param actionsListJSONArray
     */
    public static void addViewData(JSONArray actionsListJSONArray, ActionBeanContext context) {
        resourceBundleInit(context);

        for (Object actionObject : actionsListJSONArray) {
            JSONObject action = (JSONObject)actionObject;
            
            String type = action.getString("type");

            action.put("className", res.getString(type + ".type"));
            action.put("imageFilename", res.getString(type + ".image"));
            action.put("name", res.getString(type + ".desc"));
            action.put("description", res.getString(type + ".longdesc"));
            
            log.debug("action image filename" + res.getString(type + ".image"));

            JSONArray parameters = action.optJSONArray("parameters");
            if (parameters == null) {
                JSONObject singleParameter = action.optJSONObject("parameters");
                if (singleParameter != null && singleParameter.containsKey("parameter")) {
                    singleParameter = singleParameter.getJSONObject("parameter");
                    addParameterViewData(singleParameter, context);
                    parameters = new JSONArray();
                    parameters.add(singleParameter);
                    action.put("parameters", parameters);
                }
            } else {
                for (Object parameterObject : parameters) {
                    JSONObject parameter = (JSONObject)parameterObject;
                    addParameterViewData(parameter, context);
                }
            }
        }
    }

    /* TODO: Eventueel hier logica inbouwen om alvast wat parameter values
     * te zetten. parameter.put("value", "");
     */
    private static void addParameterViewData(JSONObject parameter, ActionBeanContext context) {
        resourceBundleInit(context);
        
        String nameResourceKey = "keys." + parameter.getString("paramId").toUpperCase();
        
        String inputMapped = null;
        try {
            inputMapped = parameter.getString("inputmapping");
        } catch(JSONException jsonEx) {}
        
        String outputMapped = null;
        try {
            outputMapped = parameter.getString("outputmapping");
        } catch(JSONException jsonEx) {}
        
        /* TODO: Kijken of deze manier van parameters met een resource anders kan? */
        if (nameResourceKey.contains("inputmapping.") || inputMapped != null) {
            nameResourceKey = nameResourceKey.replaceAll("keys.", "");
            
            parameter.put("name", nameResourceKey);
            parameter.put("type", nameResourceKey + ".type");
            parameter.put("optional", nameResourceKey + ".optional");
            parameter.put("inputmapping", "true");
        }
        
        if (nameResourceKey.contains("outputmapping.") || outputMapped != null) {
            nameResourceKey = nameResourceKey.replaceAll("keys.", "");
            
            parameter.put("name", nameResourceKey);
            parameter.put("type", nameResourceKey + ".type");
            parameter.put("optional", nameResourceKey + ".optional");
            parameter.put("outputmapping", "true");
        }  
        
        try {
            parameter.put("name", res.getString(nameResourceKey));
            parameter.put("type", res.getString(nameResourceKey + ".type"));
            parameter.put("optional", res.getString(nameResourceKey + ".optional"));
        } catch (MissingResourceException mre) {}                
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

    public static String[] getInputColumns() {
        return inputColumns;
    }

    public static void setInputColumns(String[] inputColumns) {
        ActionsAction.inputColumns = inputColumns;
    }

    public static String[] getOutputColumns() {
        return outputColumns;
    }

    public static void setOutputColumns(String[] outputColumns) {
        ActionsAction.outputColumns = outputColumns;
    }

    public static String getTemplateOutputType() {
        return templateOutputType;
    }

    public static void setTemplateOutputType(String templateOutputType) {
        ActionsAction.templateOutputType = templateOutputType;
    }

    public static String getOutputTablename() {
        return outputTablename;
    }

    public static void setOutputTablename(String outputTablename) {
        ActionsAction.outputTablename = outputTablename;
    }

    public static String getExternalFileName() {
        return externalFileName;
    }

    public static void setExternalFileName(String externalFileName) {
        ActionsAction.externalFileName = externalFileName;
    }
}
