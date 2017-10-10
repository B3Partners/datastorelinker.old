/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.datastorelinker.gui.stripes;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.SQLException;
import java.util.List;
import javax.persistence.EntityManager;

import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.ActionBeanContext;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.StreamingResolution;
import net.sourceforge.stripes.util.Log;
import nl.b3p.commons.jpa.JpaUtilServlet;
import org.apache.commons.io.IOUtils;
import org.hibernate.Session;
import org.postgresql.largeobject.LargeObject;
import org.postgresql.largeobject.LargeObjectManager;
import nl.b3p.datastorelinker.entity.Process;
import nl.b3p.datastorelinker.entity.ProcessStatus;
import org.json.JSONArray;
import org.json.JSONException;
import org.postgresql.PGConnection;
import org.postgresql.jdbc.PgDatabaseMetaData;

/**
 *
 * @author meine
 * @author mprins
 */
public class ConvertLargeObjectsAction implements ActionBean {

    private ActionBeanContext context;
    private LargeObjectManager lom;
    private JSONArray statusArray = new JSONArray();

    private final static Log log = Log.getInstance(ConvertLargeObjectsAction.class);
    
    public void setContext(ActionBeanContext abc) {
        this.context = abc;
    }

    public ActionBeanContext getContext() {
        return context;
    }

    public Resolution convertDatabase() throws JSONException {

        try {
            convertLOBS();

        } catch (SQLException ex) {
             log.error(ex);
        } catch (NoSuchFieldException ex) {
             log.error(ex);
        } catch (IllegalArgumentException ex) {
             log.error(ex);
        } catch (IllegalAccessException ex) {
             log.error(ex);
        } catch (IOException ex) {
             log.error(ex);
        }
        
        return new StreamingResolution("application/json", new StringReader(statusArray.toString(4)));
    }

    public void convertLOBS() throws SQLException, NoSuchFieldException, IllegalArgumentException, IllegalAccessException, IOException {

        statusArray.put("Opening connection..");
        EntityManager em = JpaUtilServlet.getThreadEntityManager();
        Session session = (Session) em.getDelegate();
        Connection conn = session.connection();
        conn.setAutoCommit(false);
        DatabaseMetaData metadata = conn.getMetaData();
        statusArray.put("Digging deep to retrieve implementation");
        
        Field f = metadata.getClass().getDeclaredField("inner");

        f.setAccessible(true);
        Object pgconnMetadata = f.get(metadata);
        statusArray.put("Retrieving postgres connection..");
        //PGConnection connection = (org.postgresql.PGConnection) ((org.postgresql.jdbc4.Jdbc4DatabaseMetaData) pgconnMetadata).getConnection();
        PGConnection connection = (org.postgresql.PGConnection) ((PgDatabaseMetaData) pgconnMetadata).getConnection();
        statusArray.put("Connection established");
        lom = connection.getLargeObjectAPI();
        statusArray.put("Create LargeObjectManager");
        em.getTransaction().begin();
        statusArray.put("Begin converting LOBs");
        processProcesses(em);
        processProcessesStatusses(em);
        
        statusArray.put("Converting finished");
        em.getTransaction().commit();
        statusArray.put("Changes saved");
    }
    
    private void processProcesses(EntityManager em) throws SQLException, IOException{
        statusArray.put("Convert actions");
        List<Process> processes = em.createQuery("from Process p").getResultList();
        for (Process process : processes) {
            updateProcess(process);
        }
    }
    
    private void processProcessesStatusses(EntityManager em) throws SQLException, IOException{
        statusArray.put("Convert statusses");
        List<ProcessStatus> processStatussen = em.createQuery("from ProcessStatus s").getResultList();
        for (ProcessStatus status : processStatussen) {
            updateStatus(status);
        }
    }
    
    private void updateProcess(Process process) throws SQLException, IOException{
        try{
            statusArray.put("    Convert process: " + process.getName());
            String oidString = process.getActionsString();
            Long oid = Long.parseLong(oidString);
            LargeObject lob = lom.open(oid);
            String lobText = getTextFromLOB(lob);
            process.setActionsString(lobText);
            statusArray.put("        -> LOB converted");
        }catch (NumberFormatException ex){
            statusArray.put("        -> No LOB to convert");
            // no need to update, apparently it isn't an oid
        }
    }
    
    private void updateStatus(ProcessStatus status) throws SQLException, IOException{
        try{
            statusArray.put("    Convert status");
            String oidString = status.getMessage();
            Long oid = Long.parseLong(oidString);
            LargeObject lob = lom.open(oid);
            String lobText = getTextFromLOB(lob);
            status.setMessage(lobText);
            statusArray.put("        -> LOB converted");
        }catch (NumberFormatException ex){
            statusArray.put("        -> No LOB to convert");
            // no need to update, apparently it isn't an oid
        }
    }

    private String getTextFromLOB(LargeObject lob) throws SQLException, IOException {
        StringWriter writer = new StringWriter();
        IOUtils.copy(lob.getInputStream(), writer, "UTF-8");
        String theString = writer.toString();
        return theString;
    }

}
