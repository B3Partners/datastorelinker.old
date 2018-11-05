package nl.b3p.datastorelinker.services;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import javax.persistence.EntityManager;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.datastorelinker.entity.Database;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.entity.Mail;
import nl.b3p.datastorelinker.entity.ProcessStatus;
import nl.b3p.datastorelinker.gui.stripes.ActionsAction;
import nl.b3p.datastorelinker.util.DataStoreLinkJob;
import nl.b3p.datastorelinker.util.SchedulerUtils;
import nl.b3p.datastorelinker.util.ZipUtil;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Session;
import org.json.JSONArray;
import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.quartz.TriggerUtils;
import org.quartz.impl.JobDetailImpl;

/**
 *
 * @author Boy de Wit
 */
public class PublishProcessServlet extends HttpServlet {

    private static final String PARAM_METHOD_ADD = "add";
    
    private static final String PARAM_SOURCE_SHAPE = "shape";
    private static final String PARAM_SOURCE_SDE = "sde";
    private static final String PARAM_SOURCE_FGDB = "fgdb";
    
    private static String outputDatabase;
    private static String uploadFolder;    
    
    private final Log log = LogFactory.getLog(this.getClass());    

    /* Voorbeeld: publish/add/shape/prefix/naam */
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
            
            if (method != null && method.equals(PARAM_METHOD_ADD)) {  
                String type = pathInfo.split("/")[2];
                
                if (type != null && type.equals(PARAM_SOURCE_SHAPE)) {  
                    String prefix = pathInfo.split("/")[3];
                    String naam = pathInfo.split("/")[4];
                    
                    String tabelNaam = prefix + "_" + naam;
                    
                    processShape(request, tabelNaam);
                }
            }
        }
        
        PrintWriter out = response.getWriter();
        out.println("Webservice proces aangemaakt.");       
    }
    
    private void processShape(HttpServletRequest request, String tabelNaam) {
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
                            File zipFolder = new File(uploadFolder + tabelNaam);
                            
                            util.extractZip(uploadedFile, zipFolder);
                            
                            createNewProcess(fileName, tabelNaam);
                            
                        } catch (Exception ex) {
                            log.error("Fout tijdens schrijven shape bestand: ", ex);
                        }
                    }
                }
            }
        } // einde inlezen meerdere bestanden        
        
                
    }
    
    private void createNewProcess(String fileName, String identifier) {
        String shapeName = fileName.replaceAll(".zip", ".shp");
        
        /* TODO: Als zelfde invoer al bestaat dan niet aanmaken maar dat id gebruiken */
        Inout input = new Inout();        
        input.setDatatype(Inout.Datatype.FILE);
        input.setFile(uploadFolder + identifier + File.separator + shapeName);
        input.setName("/webservice/" + identifier + "/" + shapeName); // TODO: Pad naar shp dynamisch instellen
        input.setType(Inout.Type.INPUT);
        input.setOrganizationId(1);
        input.setUserId(1);
        
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        em.getTransaction().begin();
        
        Long inputId = (Long)session.save(input);
        log.debug("Created input with id: " + inputId);
        
        /* TODO: Als zelfde uitvoer al bestaat dan niet aanmaken maar dat id gebruiken */
        Inout output = new Inout();      
        output.setDatatype(Inout.Datatype.DATABASE);
        output.setTableName(identifier);
        output.setType(Inout.Type.OUTPUT);
        
        
        /* TODO: Via beheer ergens kunnen instellen en via service naam
         * kunnen opvragen */
        
        /* Ophalen webservice uitvoer db */
        Database db = null;
        db = (Database) session.createQuery("from Database where webservice_db = :web")
                .setParameter("web", true).uniqueResult();
        
        if (db != null && db.getId() != null) {
            output.setDatabase(db);
        } else {
            log.error("Fout tijdens verbinden naar webservice uitvoer database.");
        }
        
        output.setOrganizationId(1);
        output.setUserId(1);
        output.setTemplateOutput(Inout.TEMPLATE_OUTPUT_NO_TABLE);
        
        Long outputId = (Long)session.save(output);
        log.debug("Created output with id: " + outputId);
               
        /* TODO: Eenmalig Mail aanmaken obv web xml instellingen */
        
        Mail mail = new Mail();
        //mail.setFromEmailAddress("dsl@b3partners.nl");
        //mail.setSmtpHost("kmail.b3partners.nl");
        mail.setSubject("Webservice proces " + identifier);
        mail.setToEmailAddress("support@b3partners.nl");
        
        session.save(mail);
        
        nl.b3p.datastorelinker.entity.Process p = new nl.b3p.datastorelinker.entity.Process();
        
        /* Actieblok klaarzetten */
        // p.setActionsString(createActieBlokString(identifier));
        p.setActionsString("");
        
        p.setDrop(Boolean.TRUE);
        p.setName("Webservice proces " + identifier);
        p.setWriterType("ActionCombo_GeometrySplitter_Writer");
        p.setInput(input);
        p.setMail(mail); // TODO: Aanpassen of ergens op kunnen vragen!
        p.setOutput(output);
        
        ProcessStatus processStatus = ProcessStatus.getDefault();
        session.save(processStatus);
        
        p.setProcessStatus(processStatus);            
        p.setAppend(Boolean.FALSE);
        p.setModify(Boolean.FALSE);
        p.setOrganizationId(1);
        p.setUserId(1);
        
        Long processId = (Long)session.save(p);
        log.debug("Created process with id: " + processId);
        
        em.getTransaction().commit();
        
        /* Process uitvoeren */
        execute(processId);
    }
    
    private void execute(Long processId) {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();
        
        nl.b3p.datastorelinker.entity.Process process = (nl.b3p.datastorelinker.entity.Process)
                session.get(nl.b3p.datastorelinker.entity.Process.class, processId);

        try {
            String generatedJobUUID = "job" + UUID.randomUUID().toString();
            JobDetail jobDetail = JobBuilder.newJob(DataStoreLinkJob.class)
                    .withIdentity(generatedJobUUID)
                    .build();
            jobDetail.getJobDataMap().put("processId", process.getId());
            //jobDetail.getJobDataMap().put("locale", getContext().getLocale());
            
            // Trigger trigger = TriggerUtils.makeImmediateTrigger(generatedJobUUID, 0, 0);
            Trigger trigger = TriggerBuilder.newTrigger()
                    .forJob(jobDetail)
                    .startNow()
                    .build();
            //Trigger trigger = new SimpleTrigger("nowTrigger", new Date());
            Scheduler scheduler = SchedulerUtils.getScheduler(getServletContext());
            process.getProcessStatus().setProcessStatusType(ProcessStatus.Type.RUNNING);
            process.getProcessStatus().setExecutingJobUUID(generatedJobUUID);
            scheduler.scheduleJob(jobDetail, trigger);
            
        } catch(Exception e) {
            log.error("Fout tijdens uitvoeren webservice process: ", e);
        }
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

