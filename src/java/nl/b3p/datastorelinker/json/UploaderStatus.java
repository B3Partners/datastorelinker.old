/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.b3p.datastorelinker.json;

/**
 *
 * @author Erik van de Pol
 */
public class UploaderStatus {
    private String ID;
    private String fpath;
    private String fname;
    private Long fsize;
    private String ftype;
    private String ftime;
    private String ftypes;
    private String renum;
    private String fclass;
    private String errtype;
    private Long msize;

    public UploaderStatus() {
        errtype = "none";
    }

    public String getID() {
        return ID;
    }

    public void setID(String ID) {
        this.ID = ID;
    }

    public String getFpath() {
        return fpath;
    }

    public void setFpath(String fpath) {
        this.fpath = fpath;
    }

    public String getFname() {
        return fname;
    }

    public void setFname(String fname) {
        this.fname = fname;
    }

    public Long getFsize() {
        return fsize;
    }

    public void setFsize(Long fsize) {
        this.fsize = fsize;
    }

    public String getFtype() {
        return ftype;
    }

    public void setFtype(String ftype) {
        this.ftype = ftype;
    }

    public String getFtime() {
        return ftime;
    }

    public void setFtime(String ftime) {
        this.ftime = ftime;
    }

    public String getFtypes() {
        return ftypes;
    }

    public void setFtypes(String ftypes) {
        this.ftypes = ftypes;
    }

    public String getRenum() {
        return renum;
    }

    public void setRenum(String renum) {
        this.renum = renum;
    }

    public String getFclass() {
        return fclass;
    }

    public void setFclass(String fclass) {
        this.fclass = fclass;
    }

    public String getErrtype() {
        return errtype;
    }

    public void setErrtype(String errtype) {
        this.errtype = errtype;
    }

    public Long getMsize() {
        return msize;
    }

    public void setMsize(Long msize) {
        this.msize = msize;
    }
    

}