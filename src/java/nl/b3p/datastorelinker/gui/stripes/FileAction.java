/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.io.IOException;
import java.util.Enumeration;
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
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.File;
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

    private Long selectedFileId;

    private FileBean filedata;

    public Resolution list() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        files = session.createQuery("from File").list();

        return new ForwardResolution(LIST_JSP);
    }

    @Transactional
    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        File file = (File)session.get(File.class, selectedFileId);

        // TODO: eigenlijk moet file verwijderen van de server en file uit de db verwijderen een atomaire operatie zijn. Lijkt er zo een beetje op.
        java.io.File fsFile = new java.io.File(file.getName());
        boolean deleteSuccess = fsFile.delete();

        session.delete(file);
        return list();

        /*if (deleteSuccess) {
            session.delete(file);
            return list();
        } else {
            log.error("File could not be deleted from the filesystem: " + fsFile.getAbsolutePath());
            // silent fail?
            //throw new Exception();
            return list();
        }*/
    }

    @DontValidate
    public Resolution create() {
        return new ForwardResolution(CREATE_JSP);
    }

    public Resolution createComplete() {
        return list();
    }

    @SuppressWarnings("unused")
    @Before(stages = LifecycleStage.BindingAndValidation)
    private void rehydrate() {
        StripesRequestWrapper req = StripesRequestWrapper.findStripesWrapper(getContext().getRequest());

        try {
            if (req.isMultipart()) {
                filedata = req.getFileParameterValue("Filedata");
                /*for (Enumeration<String> e = req.getFileParameterNames(); e.hasMoreElements(); ) {
                    String name = e.nextElement();
                    log.debug("fn: " + name);
                }*/
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
                //java.io.File tempFile = java.io.File.createTempFile(filedata.getFileName() + ".", null, dirFile);
                java.io.File tempFile = new java.io.File(dirFile, filedata.getFileName());

                filedata.save(tempFile);
                String absolutePath = tempFile.getAbsolutePath();
                log.info("Saved file " + absolutePath + ", Successfully!");

                File file = saveFile(absolutePath);
                selectedFileId = file.getId();
                
            } catch (IOException e) {
                errorMsg = e.getMessage();
                log.error("Error while writing file :" + filedata.getFileName() + " / " + errorMsg);
                return new StreamingResolution("text/xml", errorMsg);
            }
            return createComplete();
            //return new StreamingResolution("text/xml", "success");
        }
        return new StreamingResolution("text/xml", "An unknown error has occurred!");
    }

    @Transactional
    private File saveFile(String absolutePath) {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        File file = new File();
        file.setName(absolutePath);

        // TODO: file already exists? we now add an uuid to the filename.
        //session.saveOrUpdate(file);
        session.save(file);
        
        // TODO: dit moet gewoon anders met (doorzichtig) flash achter jquery-button.
        //selectedFileId = file.getId();
        return file;
    }

    public List<File> getFiles() {
        return files;
    }

    public void setFiles(List<File> files) {
        this.files = files;
    }

    public String getUploadDirectory() {
        return getContext().getServletContext().getInitParameter("uploadDirectory");
    }

    public Long getSelectedFileId() {
        return selectedFileId;
    }

    public void setSelectedFileId(Long selectedFileId) {
        this.selectedFileId = selectedFileId;
    }

}
