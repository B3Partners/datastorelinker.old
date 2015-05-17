package nl.b3p.datastorelinker.util;

import java.io.IOException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 *
 * @author Boy de Wit
 */
public class ZipUtil {

    private final Log log = LogFactory.getLog(this.getClass());
    protected final static String ZIP_EXT = ".zip";

    public void extractZip(File tempFile, File zipDir) throws IOException {
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

    private boolean isZipFile(String fileName) {
        return fileName.toLowerCase().endsWith(ZIP_EXT);
    }

    private String getZipName(String zipFileName) {
        return zipFileName.substring(0, zipFileName.length() - ZIP_EXT.length());
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
}
