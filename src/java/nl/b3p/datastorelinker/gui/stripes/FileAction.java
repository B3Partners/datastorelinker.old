/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import javax.persistence.EntityManager;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import net.sourceforge.stripes.action.Before;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.DontValidate;
import net.sourceforge.stripes.action.FileBean;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.LocalizableMessage;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.controller.LifecycleStage;
import net.sourceforge.stripes.controller.StripesRequestWrapper;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import nl.b3p.commons.stripes.Transactional;
import nl.b3p.datastorelinker.entity.File;
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.json.ArraySuccessMessage;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.json.UploaderStatus;
import nl.b3p.datastorelinker.util.DefaultErrorResolution;
import nl.b3p.datastorelinker.util.DirContent;
import org.hibernate.Session;

/**
 *
 * @author Erik van de Pol
 */
@Transactional
public class FileAction extends DefaultAction {

    private final static Log log = Log.getInstance(FileAction.class);

    protected final static String SHAPE_EXT = ".shp";
    protected final static String ZIP_EXT = ".zip";


    private final static String CREATE_JSP = "/pages/main/file/create.jsp";
    private final static String LIST_JSP = "/pages/main/file/list.jsp";
    private final static String ADMIN_JSP = "/pages/management/fileAdmin.jsp";
    private final static String DIRCONTENTS_JSP = "/pages/main/file/filetreeConnector.jsp";

    private DirContent dirContent;

    private File selectedFile;
    private Long selectedFileId;
    private String selectedFileIds;

    private FileBean filedata;
    //private Map<Integer, UploaderStatus> uploaderStatuses;
    private UploaderStatus uploaderStatus;
    private Long dir;
    private Long expandTo;

    public Resolution listDir() {
        log.debug(dir);
        
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        String directory = null;
        if (dir != null) {
            File directoryObject = (File)session.get(File.class, dir);
            log.debug(directoryObject.getDirectory());
            java.io.File directoryFile = new java.io.File(directoryObject.getDirectory(), directoryObject.getName());
            directory = directoryFile.getAbsolutePath();
        } else {
            directory = getUploadDirectory();
        }
        
        if (expandTo == null) {
            dirContent = getDirContent(directory, null);
        } else {
            selectedFile = (File)session.get(File.class, expandTo);

            String selectedFileDir = selectedFile.getDirectory();
            if (!selectedFileDir.startsWith(getUploadDirectory())) {
                log.error("!selectedFileDir.startsWith(getUploadDirectory())");
                return null;
            }

            List<String> subDirList = new LinkedList<String>();

            java.io.File uploadDirectory = new java.io.File(directory);
            java.io.File currentDirFile = new java.io.File(selectedFileDir);
            while (!currentDirFile.getAbsolutePath().equals(uploadDirectory.getAbsolutePath())) {
                subDirList.add(0, currentDirFile.getName());
                currentDirFile = currentDirFile.getParentFile();
            }
            
            dirContent = getDirContent(directory, subDirList);
        }

        //log.debug("dirs: " + directories.size());
        //log.debug("files: " + files.size());

        return new ForwardResolution(DIRCONTENTS_JSP);
    }

    protected DirContent getDirContent(String directory, List<String> subDirList) {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        DirContent dc = new DirContent();

        dc.setDirs(session.createQuery("from File where directory = (:directory) and isDirectory = true order by name")
                .setParameter("directory", directory)
                .list());
        dc.setFiles(session.createQuery("from File where directory = (:directory) and isDirectory = false order by name")
                .setParameter("directory", directory)
                .list());

        filterOutFilesToHide(dc);

        if (subDirList != null && subDirList.size() > 0) {
            String subDirString = subDirList.remove(0);

            for (File subDir : dc.getDirs()) {
                if (subDir.getName().equals(subDirString)) {
                    subDir.setDirContent(getDirContent(
                            new java.io.File(subDir.getDirectory(), subDir.getName()).getAbsolutePath(),
                            subDirList));
                    break;
                }
            }
        }

        return dc;
    }

    protected void filterOutFilesToHide(DirContent dc) {
        filterOutShapeExtraFiles(dc);
    }

    protected void filterOutShapeExtraFiles(DirContent dc) {
        List<String> shapeNames = new ArrayList<String>();
        for (File file : dc.getFiles()) {
            if (file.getName().endsWith(SHAPE_EXT)) {
                shapeNames.add(file.getName().substring(0, file.getName().length() - SHAPE_EXT.length()));
            }
        }

        for (String shapeName : shapeNames) {
            List<File> toBeIgnoredFiles = new ArrayList<File>();
            for (File file : dc.getFiles()) {
                if (file.getName().startsWith(shapeName) && !file.getName().endsWith(SHAPE_EXT)) {
                    toBeIgnoredFiles.add(file);
                }
            }
            for (File file : toBeIgnoredFiles) {
                dc.getFiles().remove(file);
            }
        }
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

    public Resolution deleteCheck() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        log.debug(selectedFileIds);

        List<LocalizableMessage> messages = new ArrayList<LocalizableMessage>();

        try {
            JSONArray selectedFileIdsJSON = JSONArray.fromObject(selectedFileIds);
            for (Object fileIdObj : selectedFileIdsJSON) {
                Long fileId = Long.valueOf((String)fileIdObj);

                File file = (File)session.get(File.class, fileId);

                messages.addAll(deleteCheckImpl(file));
            }
        } catch(IOException ioex) {
            log.error(ioex);
            // if anything goes wrong here something is wrong with the uploadDir.
            // db cascades still work though.
        }

        if (messages.isEmpty()) {
            return new JSONResolution(new ArraySuccessMessage(true));
        } else {
            JSONArray jsonArray = new JSONArray();
            for (LocalizableMessage m : messages) {
                jsonArray.element(m.getMessage(Locale.getDefault()));
            }
            return new JSONResolution(new ArraySuccessMessage(false, jsonArray));
        }
    }

    private List<LocalizableMessage> deleteCheckImpl(File file) throws IOException {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        List<LocalizableMessage> messages = new ArrayList<LocalizableMessage>();
        
        if (file.getIsDirectory()) {
            java.io.File fsFile = new java.io.File(file.getDirectory(), file.getName());

            List<File> filesInDir = session.createQuery("from File where directory = :directory")
                    .setParameter("directory", fsFile.getAbsolutePath())
                    .list();

            for (File fileInDir : filesInDir) {
                messages.addAll(deleteCheckImpl(fileInDir));
            }
        } else {
            String relativeFileName = getFileNameRelativeToUploadDirPP(file);

            if (file.getInoutList() != null) {
                for (Inout inout : file.getInoutList()) {
                    if (inout.getType() == Inout.Type.INPUT) {
                        messages.add(new LocalizableMessage("file.inuseInput", relativeFileName, inout.getName()));

                        if (inout.getInputProcessList() != null) {
                            for (nl.b3p.datastorelinker.entity.Process process : inout.getInputProcessList()) {
                                messages.add(new LocalizableMessage("input.inuse", inout.getName(), process.getName()));
                            }
                        }
                    } else { // output
                        messages.add(new LocalizableMessage("file.inuseOutput", relativeFileName, inout.getName()));

                        if (inout.getOutputProcessList() != null) {
                            for (nl.b3p.datastorelinker.entity.Process process : inout.getOutputProcessList()) {
                                messages.add(new LocalizableMessage("output.inuse", inout.getName(), process.getName()));
                            }
                        }
                    }

                }
            }
        }

        return messages;
    }

    // Pretty printed version of getFileNameRelativeToUploadDir(File file).
    // This name is uniform on all systems where the server runs (*nix or Windows).
    public String getFileNameRelativeToUploadDirPP(File file) throws IOException {
        return getFileNameRelativeToUploadDir(file).replace('\\', '/');
    }

    public String getFileNameRelativeToUploadDir(File file) throws IOException {
        java.io.File ioFile = new java.io.File(file.getDirectory(), file.getName());
        String absName = ioFile.getAbsolutePath();
        if (!absName.startsWith(getUploadDirectory())) {
            throw new IOException("Wrong file path. Should start with uploadDir: " + absName + "; uploadDir: " + getUploadDirectory());
        } else {
            return absName.substring(getUploadDirectory().length());
        }
    }

    public Resolution delete() {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        log.debug(selectedFileIds);

        JSONArray selectedFileIdsJSON = JSONArray.fromObject(selectedFileIds);
        for (Object fileIdObj : selectedFileIdsJSON) {
            Long fileId = Long.valueOf((String)fileIdObj);
            
            File file = (File)session.get(File.class, fileId);

            deleteImpl(file);
        }
        return list();
    }

    protected void deleteImpl(File file) {
        if (file != null) {
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            Session session = (Session)em.getDelegate();

            java.io.File fsFile = new java.io.File(file.getDirectory(), file.getName());
            boolean deleteSuccess = fsFile.delete();
            if (!deleteSuccess)
                log.error("Failed to delete file: " + fsFile.getAbsolutePath());
            session.delete(file);

            deleteExtraShapeFilesInDir(file);
            deleteDirIfDir(file);
        }
    }

    private void deleteExtraShapeFilesInDir(File file) {
        if (file.getName().endsWith(SHAPE_EXT)) {
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            Session session = (Session)em.getDelegate();

            List<File> extraShapeFilesInDir = session.createQuery(
                    "from File where directory = :directory and name like :shapename")
                    .setParameter("directory", file.getDirectory())
                    .setParameter("shapename",
                        file.getName().substring(0, file.getName().length() - SHAPE_EXT.length())
                        + ".___")
                    .list();

            for (File extraShapeFile : extraShapeFilesInDir) {
                if (!extraShapeFile.getIsDirectory()) {
                    deleteImpl(extraShapeFile);
                }
            }
        }
    }

    protected void deleteDirIfDir(File dir) {
        // can be null if we tried to delete a directory first and then
        // one or more (recursively) deleted files within it.
        if (dir != null && dir.getIsDirectory() == true) {
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            Session session = (Session)em.getDelegate();

            // TODO: eigenlijk moet file/dir verwijderen van de server en file/dir uit de db verwijderen een atomaire operatie zijn.
            java.io.File fsFile = new java.io.File(dir.getDirectory(), dir.getName());

            List<File> filesInDir = session.createQuery("from File where directory = :directory")
                    .setParameter("directory", fsFile.getAbsolutePath())
                    .list();

            log.debug(filesInDir);
            for (File fileInDir : filesInDir) {
                deleteImpl(fileInDir);
            }

            // dir must be empty when deleting it
            boolean deleteDirSuccess = fsFile.delete();
            if (!deleteDirSuccess)
                log.error("Failed to delete dir: " + fsFile.getAbsolutePath() + "; This could happen if the dir was not empty at the time of deletion. This should not happen.");
        }
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
                //log.debug("qwe: " + req.getParameter("status"));
                JSONObject jsonObject = JSONObject.fromObject(req.getParameter("status"));
                uploaderStatus = (UploaderStatus)JSONObject.toBean(jsonObject, UploaderStatus.class);
            }
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }

    @DefaultHandler
    public Resolution upload() {
        // TODO: geüploadede file blijft nu in geheugen staan tot nader order.
        // misschien in de temp dir zetten. kost wel weer tijd.

        //TODO URL Encode the messages
        String errorMsg = null;

        if (filedata != null) {

            log.debug("Filedata: " + filedata.getFileName());
            try {
                java.io.File dirFile = new java.io.File(getUploadDirectory());
                if (!dirFile.exists())
                    dirFile.mkdir();
                
                java.io.File tempFile = java.io.File.createTempFile(filedata.getFileName() + ".", null);
                //java.io.File tempFile = new java.io.File(dirFile, filedata.getFileName());
                filedata.save(tempFile);

                if (isZipFile(filedata.getFileName())) {
                    java.io.File zipDir = new java.io.File(getUploadDirectory(), getZipName(filedata.getFileName()));
                    extractZip(tempFile, zipDir);
                } else {

                    java.io.File destinationFile = new java.io.File(dirFile, filedata.getFileName());
                    tempFile.renameTo(destinationFile);

                    log.info("Saved file " + destinationFile.getAbsolutePath() + ", Successfully!");

                    File file = saveFile(destinationFile);
                    selectedFileId = file.getId();
                }

            } catch (IOException e) {
                errorMsg = e.getMessage();
                log.error("Error while writing file: " + filedata.getFileName() + " :: " + errorMsg);
                return new DefaultErrorResolution(errorMsg);
            }
            return createComplete();
        }
        return new DefaultErrorResolution("An unknown error has occurred!");
    }

    /**
     * Extract a zip tempfile to a directory. The tempfile will be deleted by this method.
     * @param tempFile The zip file to extract. This tempfile will be deleted by this method.
     * @param zipDir Directory to extract files into
     * @throws IOException
     */
    private void extractZip(java.io.File tempFile, java.io.File zipDir) throws IOException {
        if (!tempFile.exists()) {
            return;
        }

        if (!zipDir.exists()) {
            zipDir.mkdirs();
            saveDir(zipDir);
        }

        byte[] buffer = new byte[1024];
        ZipInputStream zipinputstream = null;
        
        ZipEntry zipentry = null;
        try {
            zipinputstream = new ZipInputStream(new FileInputStream(tempFile));

            while ((zipentry = zipinputstream.getNextEntry()) != null) {
                log.debug("extractZip zipentry name: " + zipentry.getName());
                
                java.io.File newFile = new java.io.File(zipDir, zipentry.getName());

                if (zipentry.isDirectory()) {
                    // ZipInputStream does not work recursively
                    // files within this directory will be encountered as a later zipEntry
                    newFile.mkdirs();
                    saveDir(newFile);
                } else if (isZipFile(zipentry.getName())) {
                    // If the zipfile is in a subdir of the zip,
                    // we have to extract the filename without the dir.
                    // It seems the zip-implementation of java always uses "/"
                    // as file separator in a zip. Even on a windows system.
                    int lastIndexOfFileSeparator = zipentry.getName().lastIndexOf("/");
                    String zipName = null;
                    if (lastIndexOfFileSeparator < 0)
                        zipName = zipentry.getName().substring(0);
                    else
                        zipName = zipentry.getName().substring(lastIndexOfFileSeparator + 1);

                    java.io.File tempZipFile = java.io.File.createTempFile(zipName + ".", null);
                    java.io.File newZipDir = new java.io.File(zipDir, getZipName(zipentry.getName()));

                    copyZipEntryTo(zipinputstream, tempZipFile, buffer);

                    extractZip(tempZipFile, newZipDir);
                } else {
                    // TODO: is valid file in zip (delete newFile if necessary)
                    copyZipEntryTo(zipinputstream, newFile, buffer);
                    saveFile(newFile);
                }
                
                zipinputstream.closeEntry();
            }
        } catch(IOException ioex) {
            if (zipentry == null) {
                throw ioex;
            } else {
                throw new IOException(ioex.getMessage() +
                        "\nProcessing zip entry: " + zipentry.getName());
            }
        } finally {
            if (zipinputstream != null) {
                zipinputstream.close();
            }

            boolean deleteSuccess = tempFile.delete();
            /*if (!deleteSuccess)
                log.warn("Could not delete: " + tempFile.getAbsolutePath());*/
        }
    }

    private void copyZipEntryTo(ZipInputStream zipinputstream, java.io.File newFile, byte[] buffer) throws IOException {
        FileOutputStream fileoutputstream = null;
        try {
            fileoutputstream = new FileOutputStream(newFile);
            int n;
            while ((n = zipinputstream.read(buffer)) > -1) {
                fileoutputstream.write(buffer, 0, n);
            }
        } finally {
            if (fileoutputstream != null) {
                fileoutputstream.close();
            }
        }
    }

    private File saveFile(java.io.File tempFile) throws IOException {
        return saveFileOrDir(tempFile, false);
    }

    private File saveDir(java.io.File tempFile) throws IOException {
        return saveFileOrDir(tempFile, true);
    }

    private File saveFileOrDir(java.io.File ioFile, boolean isDir) throws IOException {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        String fileName = ioFile.getName();
        String dirName = ioFile.getParent();

        log.debug("saveFileOrDir name: " + ioFile.getName());
        log.debug("saveFileOrDir parent: " + ioFile.getParent());

        File file = (File)session.createQuery("from File where name = :name and directory = :directory")
                .setParameter("name", fileName)
                .setParameter("directory", dirName)
                .uniqueResult();

        if (file == null) {
            // file does not exist in DB; we are not overwriting a file
            file = new File();
            file.setName(fileName);
            file.setDirectory(dirName);
            file.setIsDirectory(isDir);

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

            log.debug("check fpath: ");
            if (uploaderStatus.getFpath() != null) {
                log.debug(uploaderStatus.getFpath());
            }

            // TODO: check ook op andere dingen, size enzo. Dit blijft natuurlijk alleen maar een convenience check. Heeft niets met safety te maken.
            Map resultMap = new HashMap();

            // TODO: exists check is niet goed
            if (tempFile.exists()) {
                uploaderStatus.setErrtype("exists");
            } if (isZipFile(tempFile) && zipFileToDirFile(tempFile, new java.io.File(getUploadDirectory())).exists()) {
                uploaderStatus.setErrtype("exists");
            } else {
                uploaderStatus.setErrtype("none");
            }
            resultMap.put("0", uploaderStatus);
            return new JSONResolution(resultMap);
        }
        return new JSONResolution(false);
    }
    
    private boolean isZipFile(String fileName) {
        return fileName.toLowerCase().endsWith(ZIP_EXT);
    }

    private boolean isZipFile(java.io.File file) {
        return isZipFile(file.getName());
    }

    private String getZipName(String zipFileName) {
        return zipFileName.substring(0, zipFileName.length() - ZIP_EXT.length());
    }

    private String getZipName(java.io.File zipFile) {
        return getZipName(zipFile.getName());
    }

    private java.io.File zipFileToDirFile(java.io.File zipFile, java.io.File parent) {
        return new java.io.File(parent, getZipName(zipFile));
    }

    public String getUploadDirectory() {
        return getUploadDirectoryIOFile().getAbsolutePath();
    }

    public java.io.File getUploadDirectoryIOFile() {
        return new java.io.File(getContext().getServletContext().getInitParameter("uploadDirectory"));
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

    public Long getDir() {
        return dir;
    }

    public void setDir(Long dir) {
        this.dir = dir;
    }

    public Long getExpandTo() {
        return expandTo;
    }

    public void setExpandTo(Long expandTo) {
        this.expandTo = expandTo;
    }

    public File getSelectedFile() {
        return selectedFile;
    }

    public void setSelectedFile(File selectedFile) {
        this.selectedFile = selectedFile;
    }

    public DirContent getDirContent() {
        return dirContent;
    }

    public void setDirContent(DirContent dirContent) {
        this.dirContent = dirContent;
    }

}
