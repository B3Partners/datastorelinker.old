/*
 * <p>Title: ProView</p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2007</p>
 * <p>Company: Institut de recherches cliniques de Montr�al (IRCM)</p>
 */
package nl.b3p.datastorelinker.uploadprogress;

import org.apache.commons.fileupload.ProgressListener;

/**
 * Keep progress of file uploading.
 * 
 * @author poitrac
 */
public class UploadProgressListener implements ProgressListener {
    
    /**
     * Number of bytes read.
     */
    private long bytesRead;
    /**
     * Total length to read.
     */
    private long contentLength;
    /**
     * The number of the field, which is currently being read.
     */
    private long items;
    
    /*
     * (non-Javadoc)
     * @see org.apache.commons.fileupload.ProgressListener#update(long, long, int)
     */
    public void update(long pBytesRead, long pContentLength, int pItems) {
        bytesRead = pBytesRead;
        contentLength = pContentLength;
        items = pItems;
    }
    
    /**
     * Return progress
     * @return progress going from 0 to 1.
     */
    public double getProgress() {
        if (contentLength != -1) {
            return (double)bytesRead / contentLength;
        }
        else {
            return -1;
        }
    }
    
    
    public long getBytesRead() {
        return bytesRead;
    }
    public long getContentLength() {
        return contentLength;
    }
    public long getItems() {
        return items;
    }
}
