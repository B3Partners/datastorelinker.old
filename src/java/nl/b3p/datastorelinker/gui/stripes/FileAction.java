/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.io.IOException;
import java.util.List;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.Before;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.DontValidate;
import net.sourceforge.stripes.action.FileBean;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.StreamingResolution;
import net.sourceforge.stripes.controller.LifecycleStage;
import net.sourceforge.stripes.controller.StripesRequestWrapper;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.datastorelinker.entity.File;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
public class FileAction extends DefaultAction {

    private final static Log log = Log.getInstance(FileAction.class);
    private final static String CREATE_JSP = "/pages/main/file/create.jsp";
    private final static String LIST_JSP = "/pages/main/file/list.jsp";
    private List<File> files;
    private File selectedFile;
    //private String uploadDirectory;

    private FileBean filedata;

    @DontValidate
    public Resolution create() {
        return new ForwardResolution(CREATE_JSP);
    }

    public Resolution createComplete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();


        return new ForwardResolution(LIST_JSP);
    }

    @SuppressWarnings("unused")
    @Before(stages = LifecycleStage.BindingAndValidation)
    private void rehydrate() {
        StripesRequestWrapper req = (StripesRequestWrapper) getContext().getRequest();

        try {
            if (ServletFileUpload.isMultipartContent(req)) {
                filedata = req.getFileParameterValue("Filedata");
            }
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }

    @DefaultHandler
    public Resolution upload() {

        //TODO URL Encode the messages
        String errorMsg = null;

        if (filedata != null) {

            log.debug("Filedata: " + filedata.getFileName());
            try {
                java.io.File dirFile = new java.io.File(getUploadDirectory());
                if (!dirFile.exists())
                    dirFile.mkdir();
                java.io.File tempFile = java.io.File.createTempFile(filedata.getFileName() + ".", null, dirFile);

                filedata.save(tempFile);
                log.info("Saved file " + tempFile.getAbsolutePath() + ", Successfully!");
            } catch (IOException e) {
                errorMsg = e.getMessage();
                log.error("Error while writing file :" + filedata.getFileName() + " / " + errorMsg);
                return new StreamingResolution("text/xml", errorMsg);
            }
            return new StreamingResolution("text/xml", "success");
        }
        return new StreamingResolution("text/xml", "An unknown error has occurred!");
    }

    public List<File> getFiles() {
        return files;
    }

    public void setFiles(List<File> files) {
        this.files = files;
    }

    public File getSelectedFile() {
        return selectedFile;
    }

    public void setSelectedFile(File selectedFile) {
        this.selectedFile = selectedFile;
    }

    public String getUploadDirectory() {
        return getContext().getServletContext().getInitParameter("uploadDirectory");
    }

    /*public void setUploadDirectory(String uploadDirectory) {
        this.uploadDirectory = uploadDirectory;
    }*/
}
