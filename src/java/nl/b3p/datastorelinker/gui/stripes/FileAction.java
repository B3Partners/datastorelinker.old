/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
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
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.json.UploaderStatus;
import nl.b3p.datastorelinker.util.DefaultErrorResolution;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
@Transactional
public class FileAction extends DefaultAction {

    private final static Log log = Log.getInstance(FileAction.class);
    private final static String CREATE_JSP = "/pages/main/file/create.jsp";
    private final static String LIST_JSP = "/pages/main/file/list.jsp";
    private final static String ADMIN_JSP = "/pages/management/fileAdmin.jsp";
    private final static String DIRCONTENTS_JSP = "/pages/main/file/filetreeConnector.jsp";
    private List<File> files;
    private List<File> directories;

    private Long selectedFileId;
    private String selectedFileIds;

    private FileBean filedata;
    //private Map<Integer, UploaderStatus> uploaderStatuses;
    private UploaderStatus uploaderStatus;
    private String dir;

    public Resolution listDir() {
        log.debug(dir);
        
        if (dir != null && (
                dir.startsWith("/") ||
                dir.startsWith("\\") ||
                dir.contains("..")) ) {
            return new DefaultErrorResolution("Wrong dir type.");
        }

        // TODO: Eigenlijk ook voorkomen dat symlinks in Unix worden geupload.

        String uploadDirectory = getContext().getServletContext().getInitParameter("uploadDirectory");
        java.io.File combinedDir;
        if (dir == null)
            combinedDir = new java.io.File(uploadDirectory);
        else
            combinedDir = new java.io.File(uploadDirectory, dir);
        String directory = combinedDir.getAbsolutePath();

        log.debug(directory);
        
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        directories = session.createQuery("from File where directory = (:directory) and isDirectory = true order by name")
                .setParameter("directory", directory)
                .list();
        files = session.createQuery("from File where directory = (:directory) and isDirectory = false order by name")
                .setParameter("directory", directory)
                .list();

        //log.debug("dirs: " + directories.size());
        //log.debug("files: " + files.size());

        return new ForwardResolution(DIRCONTENTS_JSP);
    }

    public Resolution admin() {
        list();
        return new ForwardResolution(ADMIN_JSP);
    }

    public Resolution list() {
        /*EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        files = session.createQuery("from File order by name").list();*/

        return new ForwardResolution(LIST_JSP);
    }

    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        log.debug(selectedFileIds);

        JSONArray selectedFileIdsJSON = JSONArray.fromObject(selectedFileIds);
        for (Object fileIdObj : selectedFileIdsJSON) {
            Long fileId = Long.valueOf((String)fileIdObj);
            
            File file = (File)session.get(File.class, fileId);

            // TODO: eigenlijk moet file/dir verwijderen van de server en file/dir uit de db verwijderen een atomaire operatie zijn.
            java.io.File fsFile = new java.io.File(file.getDirectory(), file.getName());
            boolean deleteSuccess = fsFile.delete();

            session.delete(file);
            if (file.getIsDirectory() == true) {
                List<File> filesInDir = session.createQuery("from File where directory = (:directory)")
                        .setParameter("directory", fsFile.getAbsolutePath())
                        .list();
                for (File fileInDir : filesInDir) {
                    session.delete(fileInDir);
                }
            }
        }
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
            } else if (req.getParameter("status") != null) {
                log.debug("qwe: " + req.getParameter("status"));
                JSONObject jsonObject = JSONObject.fromObject(req.getParameter("status"));
                uploaderStatus = (UploaderStatus)JSONObject.toBean(jsonObject, UploaderStatus.class);
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

                File file = saveFile(tempFile);
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

    private File saveFile(java.io.File tempFile) throws IOException {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        String fileName = tempFile.getName();
        String dirName = tempFile.getParent();

        log.debug(tempFile.getName());
        log.debug(tempFile.getCanonicalPath());
        log.debug(tempFile.getAbsolutePath());

        File file = (File)session.createQuery("from File where name = :name and directory = :directory")
                .setParameter("name", fileName)
                .setParameter("directory", dirName)
                .uniqueResult();

        if (file == null) {
            // file does not exist in DB; we are not overwriting a file
            file = new File();
            file.setName(fileName);
            file.setDirectory(dirName);
            file.setIsDirectory(Boolean.FALSE);

            session.save(file);
        } // else: file exists in DB and thus on disk; we have chosen to overwrite the file on disk
        
        return file;
    }

    public Resolution check() {
        if (uploaderStatus != null) {
            java.io.File dirFile = new java.io.File(getUploadDirectory());
            if (!dirFile.exists())
                dirFile.mkdir();

            java.io.File tempFile = new java.io.File(dirFile, uploaderStatus.getFname());
            log.debug(tempFile.getAbsolutePath());
            log.debug(tempFile.getPath());

            // TODO: check ook op andere dingen, size enzo. Dit blijft natuurlijk alleen maar een convenience check. Heeft niets met safety te maken.
            Map resultMap = new HashMap();

            // TODO: exists check is niet goed
            if (tempFile.exists()) {
                uploaderStatus.setErrtype("exists");
            } else {
                uploaderStatus.setErrtype("none");
            }
            resultMap.put("0", uploaderStatus);
            return new JSONResolution(resultMap);
        }
        return new JSONResolution(false);
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

    public String getSelectedFileIds() {
        return selectedFileIds;
    }

    public void setSelectedFileIds(String selectedFileIds) {
        this.selectedFileIds = selectedFileIds;
    }

    public String getDir() {
        return dir;
    }

    public void setDir(String dir) {
        this.dir = dir;
    }

    public List<File> getDirectories() {
        return directories;
    }

    public void setDirectories(List<File> directories) {
        this.directories = directories;
    }

}
