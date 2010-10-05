/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.io.FileFilter;
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
import nl.b3p.datastorelinker.entity.Inout;
import nl.b3p.datastorelinker.json.ArraySuccessMessage;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.json.UploaderStatus;
import nl.b3p.datastorelinker.util.DefaultErrorResolution;
import nl.b3p.datastorelinker.util.Dir;
import nl.b3p.datastorelinker.util.DirContent;
import org.apache.commons.lang.StringUtils;
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
    protected final static String PRETTY_DIR_SEPARATOR = "/";


    private final static String CREATE_JSP = "/WEB-INF/jsp/main/file/create.jsp";
    private final static String LIST_JSP = "/WEB-INF/jsp/main/file/list.jsp";
    private final static String ADMIN_JSP = "/WEB-INF/jsp/management/fileAdmin.jsp";
    private final static String DIRCONTENTS_JSP = "/WEB-INF/jsp/main/file/filetreeConnector.jsp";

    private DirContent dirContent;

    private FileBean filedata;
    private UploaderStatus uploaderStatus;

    private String dir;
    private String expandToFilePath;
    private String selectedFilePath;
    private String selectedFilePaths;


    public Resolution listDir() {
        log.debug(dir);
        
        java.io.File directory = null;
        if (dir != null) {
            // wordt dit niet gewoon goed geregeld met user privileges?
            // De tomcat user kan in *nix niet naar de root / parent dir?
            // Voorbeelden bekijken / info inwinnen.
            if (dir.contains("..")) {
                log.error("Possible hack attempt; Dir requested: " + dir);
                return null;
            }

            directory = getFileFromPPFileName(dir);
        } else {
            directory = getUploadDirectoryIOFile();
        }
        
        if (expandToFilePath == null) {
            dirContent = getDirContent(directory, null);
        } else {
            selectedFilePath = expandToFilePath; // kan ook class @Wizard maken (alles wordt hidden field in next request)
            //selectedFile = (File)session.get(File.class, expandTo);

            String selectedFileDir = new java.io.File(selectedFilePath).getParent();
            if (!selectedFileDir.startsWith(getUploadDirectory())) {
                log.error("!selectedFileDir.startsWith(getUploadDirectory())");
                return null;
            }

            List<String> subDirList = new LinkedList<String>();

            java.io.File currentDirFile = new java.io.File(selectedFileDir);
            while (!currentDirFile.getAbsolutePath().equals(directory.getAbsolutePath())) {
                subDirList.add(0, currentDirFile.getName());
                currentDirFile = currentDirFile.getParentFile();
            }
            
            dirContent = getDirContent(directory, subDirList);
        }

        //log.debug("dirs: " + directories.size());
        //log.debug("files: " + files.size());

        return new ForwardResolution(DIRCONTENTS_JSP);
    }

    protected DirContent getDirContent(java.io.File directory, List<String> subDirList) {
        DirContent dc = new DirContent();

        java.io.File[] dirs = directory.listFiles(new FileFilter() {
            public boolean accept(java.io.File file) {
                return file.isDirectory();
            }
        });

        java.io.File[] files = directory.listFiles(new FileFilter() {
            public boolean accept(java.io.File file) {
                return !file.isDirectory();
            }
        });
        
        List<Dir> dirsList = new ArrayList<Dir>();
        for (java.io.File dir : dirs) {
            Dir newDir = new Dir();
            newDir.setName(dir.getName());
            newDir.setPath(getFileNameRelativeToUploadDirPP(dir));
            dirsList.add(newDir);
        }

        List<nl.b3p.datastorelinker.util.File> filesStrings = new ArrayList<nl.b3p.datastorelinker.util.File>();
        for (java.io.File file : files) {
            nl.b3p.datastorelinker.util.File newFile = new nl.b3p.datastorelinker.util.File();
            newFile.setName(file.getName());
            newFile.setPath(getFileNameRelativeToUploadDirPP(file));
            filesStrings.add(newFile);
        }

        dc.setDirs(dirsList);
        dc.setFiles(filesStrings);

        filterOutFilesToHide(dc);

        if (subDirList != null && subDirList.size() > 0) {
            String subDirString = subDirList.remove(0);

            for (Dir subDir : dc.getDirs()) {
                if (subDir.getName().equals(subDirString)) {
                    java.io.File followSubDir = getFileFromPPFileName(subDir.getPath());
                    subDir.setContent(getDirContent(followSubDir, subDirList));
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
        for (nl.b3p.datastorelinker.util.File file : dc.getFiles()) {
            if (file.getName().endsWith(SHAPE_EXT)) {
                shapeNames.add(file.getName().substring(0, file.getName().length() - SHAPE_EXT.length()));
            }
        }

        for (String shapeName : shapeNames) {
            List<nl.b3p.datastorelinker.util.File> toBeIgnoredFiles = new ArrayList<nl.b3p.datastorelinker.util.File>();
            for (nl.b3p.datastorelinker.util.File file : dc.getFiles()) {
                if (file.getName().startsWith(shapeName) && !file.getName().endsWith(SHAPE_EXT)) {
                    toBeIgnoredFiles.add(file);
                }
            }
           for (nl.b3p.datastorelinker.util.File file : toBeIgnoredFiles) {
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
        log.debug(selectedFilePaths);

        List<LocalizableMessage> messages = new ArrayList<LocalizableMessage>();

        try {
            JSONArray selectedFilePathsJSON = JSONArray.fromObject(selectedFilePaths);
            for (Object filePathObj : selectedFilePathsJSON) {
                String pathToDelete = (String)filePathObj;
                String relativePathToDelete = pathToDelete.replace(PRETTY_DIR_SEPARATOR, java.io.File.separator);
                java.io.File fileToDelete = new java.io.File(getUploadDirectoryIOFile(), relativePathToDelete);
                
                List<LocalizableMessage> deleteMessages = deleteCheckImpl(fileToDelete);
                
                messages.addAll(deleteMessages);
            }
        } catch(IOException ioex) {
            log.error(ioex);
            // Still needed?
            // if anything goes wrong here something is wrong with the uploadDir.
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

    private List<LocalizableMessage> deleteCheckImpl(java.io.File fileToDelete) throws IOException {
        List<LocalizableMessage> messages = new ArrayList<LocalizableMessage>();

        if (fileToDelete.isDirectory()) {
            for (java.io.File fileInDir : fileToDelete.listFiles()) {
                messages.addAll(deleteCheckImpl(fileInDir));
            }
        } else {
            String ppFileName = getFileNameRelativeToUploadDirPP(fileToDelete);

            List<Inout> inouts = getDependingInouts(fileToDelete);

            if (inouts != null && !inouts.isEmpty()) {
                for (Inout inout : inouts) {
                    if (inout.getType() == Inout.Type.INPUT) {
                        messages.add(new LocalizableMessage("file.inuseInput", ppFileName, inout.getName()));

                        if (inout.getInputProcessList() != null) {
                            for (nl.b3p.datastorelinker.entity.Process process : inout.getInputProcessList()) {
                                messages.add(new LocalizableMessage("input.inuse", inout.getName(), process.getName()));
                            }
                        }
                    } else { // output
                        messages.add(new LocalizableMessage("file.inuseOutput", ppFileName, inout.getName()));

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

    private List<Inout> getDependingInouts(java.io.File file) throws IOException {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session)em.getDelegate();

        List<Inout> inouts = session.createQuery("from Inout where file = :file")
                .setParameter("file", getFileNameRelativeToUploadDirPP(file))
                .list();

        return inouts;
    }

    private java.io.File getFileFromPPFileName(String fileName) {
        String subPath = fileName.replace(PRETTY_DIR_SEPARATOR, java.io.File.separator);
        return new java.io.File(getUploadDirectoryIOFile(), subPath);
    }

    // Pretty printed version of getFileNameRelativeToUploadDir(File file).
    // This name is uniform on all systems where the server runs (*nix or Windows).
    private String getFileNameRelativeToUploadDirPP(java.io.File file) {
        return getFileNameRelativeToUploadDir(file).replace(java.io.File.separator, PRETTY_DIR_SEPARATOR);
    }

    private String getFileNameRelativeToUploadDir(java.io.File file) {
        String absName = file.getAbsolutePath();
        if (!absName.startsWith(getUploadDirectory())) {
            return null;
        } else {
            return absName.substring(getUploadDirectory().length());
        }
    }

    public Resolution delete() {
        log.debug(selectedFilePaths);

        JSONArray selectedFilePathsJSON = JSONArray.fromObject(selectedFilePaths);
        for (Object filePathObj : selectedFilePathsJSON) {
            String filePath = (String)filePathObj;
            
            deleteImpl(getFileFromPPFileName(filePath));
        }
        return list();
    }

    protected void deleteImpl(java.io.File file) {
        if (file != null) {
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            Session session = (Session)em.getDelegate();

            // file could already be deleted if an ancestor directory was also deleted in the same request.
            if (!file.isDirectory() && file.exists()) {
                boolean deleteSuccess = file.delete();
                if (!deleteSuccess)
                    log.error("Failed to delete file: " + file.getAbsolutePath());
            }
            
            try {
                List<Inout> inouts = getDependingInouts(file);
                for (Inout inout : inouts) {
                    session.delete(inout);
                }
            } catch(IOException ioex) {
                log.error(ioex);
            }
            
            deleteExtraShapeFilesInSameDir(file);
            deleteDirIfDir(file);
        }
    }

    private void deleteExtraShapeFilesInSameDir(final java.io.File file) {
        if (!file.isDirectory() && file.exists() && file.getName().endsWith(SHAPE_EXT)) {
            final String fileBaseName = file.getName().substring(0, file.getName().length() - SHAPE_EXT.length());

            java.io.File currentDir = file.getParentFile();
            log.debug("currentDir == " + currentDir);
            if (currentDir != null) {
                java.io.File[] extraShapeFilesInDir = currentDir.listFiles(new FileFilter() {
                    public boolean accept(java.io.File extraFile) {
                        return extraFile.getName().startsWith(fileBaseName) &&
                               extraFile.getName().length() == file.getName().length();
                    }
                });

                for (java.io.File extraShapeFile : extraShapeFilesInDir) {
                    if (!extraShapeFile.isDirectory()) {
                        deleteImpl(extraShapeFile);
                    }
                }
            }
        }
    }

    protected void deleteDirIfDir(java.io.File dir) {
        // Does this still apply?
        // can be null if we tried to delete a directory first and then
        // one or more (recursively) deleted files within it.
        if (dir != null && dir.isDirectory()) {
            for (java.io.File fileInDir : dir.listFiles()) {
                deleteImpl(fileInDir);
            }

            // dir must be empty when deleting it
            boolean deleteDirSuccess = dir.delete();
            if (!deleteDirSuccess)
                log.error("Failed to delete dir: " + dir.getAbsolutePath() + "; This could happen if the dir was not empty at the time of deletion. This should not happen.");
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

                    selectedFilePath = getFileNameRelativeToUploadDirPP(destinationFile);
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

    public DirContent getDirContent() {
        return dirContent;
    }

    public void setDirContent(DirContent dirContent) {
        this.dirContent = dirContent;
    }

    public String getExpandToFilePath() {
        return expandToFilePath;
    }

    public void setExpandToFilePath(String expandToFilePath) {
        this.expandToFilePath = expandToFilePath;
    }

    public String getSelectedFilePaths() {
        return selectedFilePaths;
    }

    public void setSelectedFilePaths(String selectedFilePaths) {
        this.selectedFilePaths = selectedFilePaths;
    }

    public String getDir() {
        return dir;
    }

    public void setDir(String dir) {
        this.dir = dir;
    }

    public String getSelectedFilePath() {
        return selectedFilePath;
    }

    public void setSelectedFilePath(String selectedFilePath) {
        this.selectedFilePath = selectedFilePath;
    }

}
