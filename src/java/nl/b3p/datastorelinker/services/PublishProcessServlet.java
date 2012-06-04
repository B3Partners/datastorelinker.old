package nl.b3p.datastorelinker.services;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;
import javax.persistence.EntityManager;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.sf.json.JSON;
import net.sf.json.JSONArray;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.entity.Mail;
import nl.b3p.datastorelinker.entity.ProcessStatus;
import nl.b3p.datastorelinker.gui.stripes.ActionsAction;
import nl.b3p.datastorelinker.util.ZipUtil;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Session;

/**
 *
 * @author Boy de Wit
 */
public class PublishProcessServlet extends HttpServlet {

    private static final String PARAM_SHAPE = "shape";
    private static final String PARAM_SDE = "sde";
    private static final String PARAM_FGDB = "fgdb";
    
    private static String outputDatabase;
    private static String uploadFolder;    
    
    private final Log log = LogFactory.getLog(this.getClass());    

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        /* TODO:
         * 1) Uitvoer database opvragen bij dsl
         * 2) Config xml doorsturen naar dsl voor aanmaken invoer
        */

        String pathInfo = request.getPathInfo();
        
        /* /method/value */
        if (pathInfo != null) {
            String method = pathInfo.split("/")[1];
            
            if (method != null && method.equals(PARAM_SHAPE)) {   
                String afkorting = pathInfo.split("/")[2];
                
                processShape(request, afkorting);
            }
        }
        
        PrintWriter out = response.getWriter();
        out.println("Proces aangemaakt!");
        
    }
    
    private void processShape(HttpServletRequest request, String afk) {
        
        /* Shape neerzetten */
        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        if (isMultipart) {
            FileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);

            /* TODO: Upload constraints inbouwen */            

            List items = null;
            try {
                items = upload.parseRequest(request);
            } catch (FileUploadException ex) {
                log.error("Fout tijdens inlezen shape bestand: ", ex);
            }

            if (items != null && items.size() > 0) {
                
                if (uploadFolder != null) {
                    File folder = new File(uploadFolder);
                    if (!folder.exists()) {
                        folder.mkdirs();
                    }                    
                }                
                
                Iterator iter = items.iterator();
                while (iter.hasNext()) {
                    FileItem item = (FileItem) iter.next();

                    if (!item.isFormField()) {
                        String fileName = item.getName();
                        String filePath = uploadFolder + fileName;
                        
                        File uploadedFile = new File(filePath);
                        try {
                            item.write(uploadedFile);
                            
                            /* Zip uitpakken in subfolder en dan verwijderen */
                            ZipUtil util = new ZipUtil();
                            File zipFolder = new File(uploadFolder + afk);
                            
                            util.extractZip(uploadedFile, zipFolder);
                            
                            createNewProcess(fileName, afk);
                            
                        } catch (Exception ex) {
                            log.error("Fout tijdens schrijven shape bestand: ", ex);
                        }
                    }
                }
            }
        } // einde inlezen meerdere bestanden        
        
                
    }
    
    private void createNewProcess(String fileName, String afk) {
        String shapeName = fileName.replaceAll(".zip", ".shp");
        String tableName = afk + "_" + fileName.replaceAll(".zip", "");
        
        /* Invoer aanmaken */
        Inout input = new Inout();        
        input.setDatatype(Inout.Datatype.FILE);
        input.setFile(uploadFolder + afk + File.separator + shapeName);
        input.setName("webservice/" + afk + "/" + shapeName); // TODO: Pad naar shp dynamisch instellen
        input.setType(Inout.Type.INPUT);
        input.setOrganizationId(1);
        input.setUserId(1);
        
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        em.getTransaction().begin();
        
        Long inputId = (Long)session.save(input);
        log.debug("Created input with id: " + inputId);
        
        /* Uitvoer aanmaken */        
        Inout output = new Inout();        
        output.setDatatype(Inout.Datatype.DATABASE);
        output.setTableName(tableName);
        output.setType(Inout.Type.OUTPUT);
        output.setDatabase(new Database(494L)); // TODO: Aanpassen of ergens op kunnen vragen!
        output.setOrganizationId(1);
        output.setUserId(1);
        output.setTemplateOutput(Inout.TEMPLATE_OUTPUT_NO_TABLE);
        
        Long outputId = (Long)session.save(output);
        log.debug("Created output with id: " + outputId);
               
        /* Proces aanmaken */
        Mail mail = new Mail();
        mail.setFromEmailAddress("dsl@b3partners.nl");
        mail.setSmtpHost("kmail.b3partners.nl");
        mail.setSubject("Webservice proces " + tableName);
        mail.setToEmailAddress("boy@b3p.nl");
        
        session.save(mail);
        
        nl.b3p.datastorelinker.entity.Process p = new nl.b3p.datastorelinker.entity.Process();
        
        /* Actieblok klaarzetten */
        p.setActionsString(createActieBlokString(tableName));
        
        p.setDrop(Boolean.TRUE);
        p.setName("Webservice proces " + tableName);
        p.setWriterType("ActionCombo_GeometrySplitter_Writer");
        p.setInput(input);
        p.setMail(mail); // TODO: Aanpassen of ergens op kunnen vragen!
        p.setOutput(output);
        
        ProcessStatus processStatus = ProcessStatus.getDefault();
        session.save(processStatus);
        
        p.setProcessStatus(processStatus);            
        p.setAppend(Boolean.FALSE);
        p.setOrganizationId(1);
        p.setUserId(1);
        
        Long processId = (Long)session.save(p);
        log.debug("Created process with id: " + processId);
        
        em.getTransaction().commit();
        
        /* Process uitvoeren */
    }
    
    private String createActieBlokString(String tableName) {
        String actionsList = new JSONArray().toString();                

        JSONArray actionsListJSONArray = JSONArray.fromObject(actionsList);
        
        ActionsAction.removeViewData(actionsListJSONArray);
        ActionsAction.addExpandableProperty(actionsListJSONArray);

        JSON actionsListJSON = JSONSerializer.toJSON(actionsListJSONArray);
        
        XMLSerializer xmlSerializer = new XMLSerializer();
        xmlSerializer.setArrayName("actions");
        xmlSerializer.setElementName("action");
        xmlSerializer.setExpandableProperties(new String[] {"parameter"});
        xmlSerializer.setTypeHintsEnabled(false);

        String actionsListXml = xmlSerializer.write(actionsListJSON);

        return actionsListXml;
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        processRequest(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        processRequest(request, response);
    }
    
    @Override
    public String getServletInfo() {
        return "Short description";
    }

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        try {

            if (config.getInitParameter("outputDatabase") != null) {
                outputDatabase = config.getInitParameter("outputDatabase");
            }
            
            if (config.getInitParameter("uploadFolder") != null) {
                uploadFolder = config.getInitParameter("uploadFolder");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    public static String getOutputDatabase() {
        return outputDatabase;
    }

    public static void setOutputDatabase(String outputDatabase) {
        PublishProcessServlet.outputDatabase = outputDatabase;
    }

    public static String getUploadFolder() {
        return uploadFolder;
    }

    public static void setUploadFolder(String uploadFolder) {
        PublishProcessServlet.uploadFolder = uploadFolder;
    }
}

