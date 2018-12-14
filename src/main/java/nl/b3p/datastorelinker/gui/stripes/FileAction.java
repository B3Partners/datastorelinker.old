/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import javax.persistence.EntityManager;
import net.sf.json.JSONArray;
import net.sourceforge.stripes.action.ActionBeanContext;
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
import nl.b3p.datastorelinker.entity.Organization;
import nl.b3p.datastorelinker.json.ArraySuccessMessage;
import nl.b3p.datastorelinker.json.JSONResolution;
import nl.b3p.datastorelinker.json.ProgressMessage;
import nl.b3p.datastorelinker.json.UploaderStatus;
import nl.b3p.datastorelinker.uploadprogress.UploadProgressListener;
import nl.b3p.datastorelinker.util.DefaultErrorResolution;
import nl.b3p.datastorelinker.util.Dir;
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
    protected final static String PRETTY_DIR_SEPARATOR = "/";
    protected final static String[] ALLOWED_CONTENT_TYPES = {
        ""
    };
    private final static String CREATE_JSP = "/WEB-INF/jsp/main/file/create.jsp";
    private final static String LIST_JSP = "/WEB-INF/jsp/main/file/list.jsp";
    private final static String WRAPPER_JSP = "/WEB-INF/jsp/main/file/filetreeWrapper.jsp";
    private final static String ADMIN_JSP = "/WEB-INF/jsp/management/fileAdmin.jsp";
    private final static String DIRCONTENTS_JSP = "/WEB-INF/jsp/main/file/filetreeConnector.jsp";
    private DirContent dirContent;
    private FileBean filedata;
    private UploaderStatus uploaderStatus;
    private String dir;
    private String expandTo;
    private String selectedFilePath;
    private String selectedFilePaths;
    private boolean adminPage = false;

    public Resolution listDir() {
        log.debug("Directory requested: " + dir);
        log.debug("expandTo: " + expandTo);
        Boolean expandDir  = Boolean.valueOf(getContext().getServletContext().getInitParameter("expandAllDirsDirectly"));
        File directory = null;
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
            directory = getOrganizationUploadDir();
        }

        if (expandDir) {
            dirContent = getDirContent(directory, null,expandDir);
        } else if (expandTo == null) {
            dirContent = getDirContent(directory, null,expandDir);
        } else {
            selectedFilePath = expandTo.trim().replace("\n", "").replace("\r", "");
            log.debug("selectedFilePath/expandTo: " + selectedFilePath);

            List<String> subDirList = new LinkedList<String>();

            File currentDirFile = getFileFromPPFileName(selectedFilePath);
            while (!currentDirFile.getAbsolutePath().equals(directory.getAbsolutePath())) {
                subDirList.add(0, currentDirFile.getName());
                currentDirFile = currentDirFile.getParentFile();
            }

            dirContent = getDirContent(directory, subDirList,expandDir);
        }

        //log.debug("dirs: " + directories.size());
        //log.debug("files: " + files.size());
        return new ForwardResolution(DIRCONTENTS_JSP);
    }

    protected DirContent getDirContent(File directory, List<String> subDirList, Boolean expandDirs) {
        DirContent dc = new DirContent();

        File[] dirs = directory.listFiles(new FileFilter() {
            public boolean accept(File file) {
                return file.isDirectory();
            }
        });

        File[] files = directory.listFiles(new FileFilter() {
            public boolean accept(File file) {
                return !file.isDirectory();
            }
        });

        List<Dir> dirsList = new ArrayList<Dir>();

        if (dirs != null) {
            for (File dir : dirs) {
                Dir newDir = new Dir();
                newDir.setName(dir.getName());
                newDir.setPath(getFileNameRelativeToUploadDirPP(dir));
                dirsList.add(newDir);
            }
        }

        List<nl.b3p.datastorelinker.util.File> filesList = new ArrayList<nl.b3p.datastorelinker.util.File>();

        if (files != null) {
            for (File file : files) {
                nl.b3p.datastorelinker.util.File newFile = new nl.b3p.datastorelinker.util.File();
                newFile.setName(file.getName());
                newFile.setPath(getFileNameRelativeToUploadDirPP(file));
                filesList.add(newFile);
            }
        }

        Collections.sort(dirsList, new DirExtensionComparator());
        Collections.sort(filesList, new FileExtensionComparator());

        dc.setDirs(dirsList);
        dc.setFiles(filesList);

        filterOutFilesToHide(dc);

        if (expandDirs) {
            for (Dir subDir : dc.getDirs()) {
                File followSubDir = getFileFromPPFileName(subDir.getPath());
                subDir.setContent(getDirContent(followSubDir, null,expandDirs));
            }
        } else if (subDirList != null && subDirList.size() > 0) {
            String subDirString = subDirList.remove(0);

            for (Dir subDir : dc.getDirs()) {
                if (subDir.getName().equals(subDirString)) {
                    File followSubDir = getFileFromPPFileName(subDir.getPath());
                    subDir.setContent(getDirContent(followSubDir, subDirList,expandDirs));
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
        return new ForwardResolution(LIST_JSP);
    }

    public Resolution deleteCheck() {
        log.debug(selectedFilePaths);

        List<LocalizableMessage> messages = new ArrayList<LocalizableMessage>();

        try {
            JSONArray selectedFilePathsJSON = JSONArray.fromObject(selectedFilePaths);
            for (Object filePathObj : selectedFilePathsJSON) {
                String pathToDelete = (String) filePathObj;
                String relativePathToDelete = pathToDelete.replace(PRETTY_DIR_SEPARATOR, File.separator);
                File fileToDelete = new File(getUploadDirectoryIOFile(), relativePathToDelete);

                List<LocalizableMessage> deleteMessages = deleteCheckImpl(fileToDelete);

                messages.addAll(deleteMessages);
            }
        } catch (IOException ioex) {
            log.error(ioex);
            // Still needed?
            // if anything goes wrong here something is wrong with the uploadDir.
        }

        if (messages.isEmpty()) {
            return new JSONResolution(new ArraySuccessMessage(true));
        } else {
            JSONArray jsonArray = new JSONArray();
            for (LocalizableMessage m : messages) {
                jsonArray.element(m.getMessage(getContext().getLocale()));
            }
            return new JSONResolution(new ArraySuccessMessage(false, jsonArray));
        }
    }

    private List<LocalizableMessage> deleteCheckImpl(File fileToDelete) throws IOException {
        List<LocalizableMessage> messages = new ArrayList<LocalizableMessage>();

        if (fileToDelete.isDirectory()) {
            for (File fileInDir : fileToDelete.listFiles()) {
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

    private List<Inout> getDependingInouts(File file) throws IOException {
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        List<Inout> inouts = session.createQuery("from Inout where file = :file").setParameter("file", file.getAbsolutePath()).list();

        return inouts;
    }

    private File getFileFromPPFileName(String fileName) {
        return getFileFromPPFileName(fileName, getContext());
    }

    private String getFileNameFromPPFileName(String fileName) {
        File file = getFileFromPPFileName(fileName);
        if (file == null) {
            return null;
        } else {
            return file.getAbsolutePath();
        }
    }

    private static File getFileFromPPFileName(String fileName, ActionBeanContext context) {
        String subPath = fileName.replace(PRETTY_DIR_SEPARATOR, File.separator);
        return new File(getUploadDirectoryIOFile(context), subPath);
    }

    public static String getFileNameFromPPFileName(String fileName, ActionBeanContext context) {
        File file = getFileFromPPFileName(fileName, context);
        if (file == null) {
            return null;
        } else {
            return file.getAbsolutePath();
        }
    }

    // Pretty printed version of getFileNameRelativeToUploadDir(File file).
    // This name is uniform on all systems where the server runs (*nix or Windows).
    public static String getFileNameRelativeToUploadDirPP(String file, ActionBeanContext context) {
        return getFileNameRelativeToUploadDirPP(new File(file), context);
    }

    private String getFileNameRelativeToUploadDirPP(File file) {
        return getFileNameRelativeToUploadDirPP(file, getContext());
    }

    private static String getFileNameRelativeToUploadDirPP(File file, ActionBeanContext context) {
        String name = getFileNameRelativeToUploadDir(file, context);
        if (name == null) {
            return null;
        } else {
            return name.replace(File.separator, PRETTY_DIR_SEPARATOR);
        }
    }

    private String getFileNameRelativeToUploadDir(File file) {
        return getFileNameRelativeToUploadDir(file, getContext());
    }

    private static String getFileNameRelativeToUploadDir(File file, ActionBeanContext context) {
        String absName = file.getAbsolutePath();
        String uploadDir = getUploadDirectory(context);
        if (uploadDir == null || !absName.startsWith(uploadDir)) {
            return null;
        } else {
            return absName.substring(getUploadDirectory(context).length());
        }
    }

    public Resolution delete() {
        log.debug(selectedFilePaths);

        JSONArray selectedFilePathsJSON = JSONArray.fromObject(selectedFilePaths);
        for (Object filePathObj : selectedFilePathsJSON) {
            String filePath = (String) filePathObj;

            deleteImpl(getFileFromPPFileName(filePath));
        }
        return list();
    }

    protected void deleteImpl(File file) {
        if (file != null) {
            EntityManager em = JpaUtilServlet.getThreadEntityManager();
            Session session = (Session) em.getDelegate();

            // file could already be deleted if an ancestor directory was also deleted in the same request.
            if (!file.isDirectory() && file.exists()) {
                boolean deleteSuccess = file.delete();
                if (!deleteSuccess) {
                    log.error("Failed to delete file: " + file.getAbsolutePath());
                }
            }

            try {
                List<Inout> inouts = getDependingInouts(file);
                for (Inout inout : inouts) {
                    session.delete(inout);
                }
            } catch (IOException ioex) {
                log.error(ioex);
            }

            deleteExtraShapeFilesInSameDir(file);
            deleteDirIfDir(file);
        }
    }

    private void deleteExtraShapeFilesInSameDir(final File file) {
        if (!file.isDirectory() && file.getName().endsWith(SHAPE_EXT)) {
            final String fileBaseName = file.getName().substring(0, file.getName().length() - SHAPE_EXT.length());

            File currentDir = file.getParentFile();
            log.debug("currentDir == " + currentDir);
            if (currentDir != null && currentDir.exists()) {
                File[] extraShapeFilesInDir = currentDir.listFiles(new FileFilter() {

                    public boolean accept(File extraFile) {
                        return extraFile.getName().startsWith(fileBaseName)
                                && extraFile.getName().length() == file.getName().length();
                    }
                });

                for (File extraShapeFile : extraShapeFilesInDir) {
                    if (!extraShapeFile.isDirectory()) {
                        deleteImpl(extraShapeFile);
                    }
                }
            }
        }
    }

    protected void deleteDirIfDir(File dir) {
        // Does this still apply?
        // can be null if we tried to delete a directory first and then
        // one or more (recursively) deleted files within it.
        if (dir != null && dir.isDirectory() && dir.exists()) {
            for (File fileInDir : dir.listFiles()) {
                deleteImpl(fileInDir);
            }

            // dir must be empty when deleting it
            boolean deleteDirSuccess = dir.delete();
            if (!deleteDirSuccess) {
                log.error("Failed to delete dir: " + dir.getAbsolutePath() + "; This could happen if the dir was not empty at the time of deletion. This should not happen.");
            }
        }
    }

    @DontValidate
    public Resolution create() {
        return new ForwardResolution(CREATE_JSP);
    }

    public Resolution createComplete() {
        //return list();
        return new ForwardResolution(WRAPPER_JSP);
    }

    @SuppressWarnings("unused")
    @Before(stages = LifecycleStage.BindingAndValidation)
    private void rehydrate() {
        StripesRequestWrapper req = StripesRequestWrapper.findStripesWrapper(getContext().getRequest());
        try {
            if (req.isMultipart()) {
                filedata = req.getFileParameterValue("uploader");
            } /*else if (req.getParameter("status") != null) {
             log.debug("req.getParameter('status'): " + req.getParameter("status"));
             JSONObject jsonObject = JSONObject.fromObject(req.getParameter("status"));
             uploaderStatus = (UploaderStatus) JSONObject.toBean(jsonObject, UploaderStatus.class);
             }*/

        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }

    @DefaultHandler
    public Resolution upload() {
        if (filedata != null) {
            log.debug("Filedata: " + filedata.getFileName());

            try {
                File dirFile = getOrganizationUploadDir();
                if (!dirFile.exists()) {
                    dirFile.mkdirs();
                }

                if (isZipFile(filedata.getFileName())) {
                    File tempFile = File.createTempFile(filedata.getFileName() + ".", null);
                    filedata.save(tempFile);
                    File zipDir = new File(getOrganizationUploadString(), getZipName(filedata.getFileName()));

                    extractZip(tempFile, zipDir);
                } else {
                    File destinationFile = new File(dirFile, filedata.getFileName());
                    filedata.save(destinationFile);

                    log.info("Saved file " + destinationFile.getAbsolutePath() + ", Successfully!");

                    selectedFilePath = getFileNameRelativeToUploadDirPP(destinationFile);
                    log.debug("selectedFilePath: " + selectedFilePath);
                }
            } catch (IOException e) {
                String errorMsg = e.getMessage();
                log.error("Error while writing file: " + filedata.getFileName() + " :: " + errorMsg);
                return new DefaultErrorResolution(errorMsg);
            }
            return createComplete();
        }
        return new DefaultErrorResolution("An unknown error has occurred!");
    }

    public Resolution uploadProgress() {
        int progress;
        UploadProgressListener listener = (UploadProgressListener) getContext().getRequest().getSession().getAttribute(UploadProgressListener.class.toString());

        if (listener != null) {
            progress = (int) (listener.getProgress() * 100);
        } else {
            progress = 100;
        }
        return new JSONResolution(new ProgressMessage(progress));
    }

    /**
     * Extract a zip tempfile to a directory. The tempfile will be deleted by
     * this method.
     *
     * @param tempFile The zip file to extract. This tempfile will be deleted by
     * this method.
     * @param zipDir Directory to extract files into
     * @throws IOException
     */
    private void extractZip(File tempFile, File zipDir) throws IOException {
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

                File newFile = new File(zipDir, zipentry.getName());

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
                    if (lastIndexOfFileSeparator < 0) {
                        zipName = zipentry.getName().substring(0);
                    } else {
                        zipName = zipentry.getName().substring(lastIndexOfFileSeparator + 1);
                    }

                    File tempZipFile = File.createTempFile(zipName + ".", null);
                    File newZipDir = new File(zipDir, getZipName(zipentry.getName()));

                    copyZipEntryTo(zipinputstream, tempZipFile, buffer);

                    extractZip(tempZipFile, newZipDir);
                } else {
                    // TODO: is valid file in zip (delete newFile if necessary)
                    copyZipEntryTo(zipinputstream, newFile, buffer);
                }

                zipinputstream.closeEntry();
            }
        } catch (IOException ioex) {
            if (zipentry == null) {
                throw ioex;
            } else {
                throw new IOException(ioex.getMessage()
                        + "\nProcessing zip entry: " + zipentry.getName());
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

    private void copyZipEntryTo(ZipInputStream zipinputstream, File newFile, byte[] buffer) throws IOException {
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
            File dirFile = getOrganizationUploadDir();
            if (!dirFile.exists()) {
                dirFile.mkdir();
            }

            File tempFile = new File(dirFile, uploaderStatus.getFname());
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
            }
            if (isZipFile(tempFile) && zipFileToDirFile(tempFile, new File(getOrganizationUploadString())).exists()) {
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

    private boolean isZipFile(File file) {
        return isZipFile(file.getName());
    }

    private String getZipName(String zipFileName) {
        return zipFileName.substring(0, zipFileName.length() - ZIP_EXT.length());
    }

    private String getZipName(File zipFile) {
        return getZipName(zipFile.getName());
    }

    private File zipFileToDirFile(File zipFile, File parent) {
        return new File(parent, getZipName(zipFile));
    }

    private String getUploadDirectory() {
        return getUploadDirectory(getContext());
    }

    public static String getUploadDirectory(ActionBeanContext context) {
        return getUploadDirectoryIOFile(context).getAbsolutePath();
    }

    private File getUploadDirectoryIOFile() {
        return getUploadDirectoryIOFile(getContext());
    }

    public static File getUploadDirectoryIOFile(ActionBeanContext context) {
        return new File(context.getServletContext().getInitParameter("uploadDirectory"));
    }

    public DirContent getDirContent() {
        return dirContent;
    }

    public void setDirContent(DirContent dirContent) {
        this.dirContent = dirContent;
    }

    public String getExpandTo() {
        return expandTo;
    }

    public void setExpandTo(String expandTo) {
        this.expandTo = expandTo;
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

    public boolean getAdminPage() {
        return adminPage;
    }

    public void setAdminPage(boolean adminPage) {
        this.adminPage = adminPage;
    }

    public File getOrganizationUploadDir() {
        if (isUserAdmin()) {
            return new File(getContext().getServletContext().getInitParameter("uploadDirectory"));
        }

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        Organization org = (Organization) session.createQuery("from Organization where id = :id")
                .setParameter("id", getUserOrganiztionId())
                .uniqueResult();

        if (org != null) {
            return new File(getContext().getServletContext().getInitParameter("uploadDirectory") + File.separator + org.getUploadPath());
        }

        return null;
    }

    public String getOrganizationUploadString() {
        String uploadPath = null;
        if (isUserAdmin()) {
            return getContext().getServletContext().getInitParameter("uploadDirectory");
        }

        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();

        Organization org = (Organization) session.createQuery("from Organization where id = :id")
                .setParameter("id", getUserOrganiztionId())
                .uniqueResult();

        if (org != null) {
            uploadPath = getContext().getServletContext().getInitParameter("uploadDirectory") + File.separator + org.getUploadPath();
        }

        return uploadPath;
    }

    // <editor-fold defaultstate="collapsed" desc="Comparison methods for file/dir sorting">
    private int compareExtensions(String s1, String s2) {
        // the +1 is to avoid including the '.' in the extension and to avoid exceptions
        // EDIT:
        // We first need to make sure that either both files or neither file
        // has an extension (otherwise we'll end up comparing the extension of one
        // to the start of the other, or else throwing an exception)
        final int s1Dot = s1.lastIndexOf('.');
        final int s2Dot = s2.lastIndexOf('.');
        if ((s1Dot == -1) == (s2Dot == -1)) { // both or neither
            s1 = s1.substring(s1Dot + 1);
            s2 = s2.substring(s2Dot + 1);
            return s1.compareTo(s2);
        } else if (s1Dot == -1) { // only s2 has an extension, so s1 goes first
            return -1;
        } else { // only s1 has an extension, so s1 goes second
            return 1;
        }
    }

    private class DirExtensionComparator implements Comparator<Dir> {

        @Override
        public int compare(Dir d1, Dir d2) {
            String s1 = d1.getName();
            String s2 = d2.getName();
            return compareExtensions(s1, s2);
        }
    }

    private class FileExtensionComparator implements Comparator<nl.b3p.datastorelinker.util.File> {

        @Override
        public int compare(nl.b3p.datastorelinker.util.File f1, nl.b3p.datastorelinker.util.File f2) {
            String s1 = f1.getName();
            String s2 = f2.getName();
            return compareExtensions(s1, s2);
        }
    }
    // </editor-fold>
}
