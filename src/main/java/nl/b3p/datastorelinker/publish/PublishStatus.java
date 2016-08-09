/*
 * Copyright (C) 2016 B3Partners B.V.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.b3p.datastorelinker.publish;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Meine Toonen
 */
public class PublishStatus {
    private List<String> layersSucceeded = new ArrayList<String>();
    private List<String> layersFailed = new ArrayList<String>();
    
    private StringBuilder layersFailedMessages = new StringBuilder();
    
    private boolean serviceCreated = false;
    private String serviceMessage;
    
    private boolean storeCreated = false;
    private String storeMessage;
    
    private boolean fatal = false;
    
    public String fatalMessage;
    
    @Override
    public String toString(){
        StringBuilder sb = new StringBuilder();
        if(fatal){
            sb.append("Er is een fatale fout opgetreden: er kon geen verbinding gemaakt worden met de Mapserver/Geoserver");
        }else{
            sb.append("De service/workspace is ");
            sb.append(serviceCreated ? "wel" : "niet");
            sb.append(" aangemaakt.<br/>");
            if (!serviceCreated && serviceMessage.length() > 0) {
                sb.append("Reden: ");
                sb.append(serviceMessage);
                sb.append("<br/>");
            }

            sb.append("<br/>");
            sb.append("Er is ");
            sb.append(storeCreated ? "wel" : "geen");
            sb.append(" databaseverbinding gemaakt. <br/>");

            if (!storeCreated && storeMessage.length() > 0) {
                sb.append("Reden: ");
                sb.append(storeMessage);
                sb.append("<br/>");
            }
            
            sb.append("<br/>");
            if (!layersSucceeded.isEmpty()) {
                sb.append("De volgende lagen zijn wel aangemaakt: <br/>");
                for (String layer : layersSucceeded) {
                    sb.append(layer);
                    sb.append("<br/>");
                }
                sb.append("<br/>");
            }

            if (!layersFailed.isEmpty()) {
                sb.append("De volgende lagen zijn niet aangemaakt: <br/>");
                for (String layer : layersFailed) {
                    sb.append(layer);
                    sb.append("<br/>");
                }
                sb.append("<br/>");
                if(layersFailedMessages.length() > 0){
                    sb.append("De volgende redenen zijn gevonden:<br/> ");
                    sb.append(layersFailedMessages);
                }
            }
        }
        return sb.toString();
    }
    
    // <editor-fold desc="Getters and Setters" defaultstate="collapsed">
    public List<String> getLayersSucceeded() {
        return layersSucceeded;
    }

    public void setLayersSucceeded(List<String> layersSucceeded) {
        this.layersSucceeded = layersSucceeded;
    }

    public List<String> getLayersFailed() {
        return layersFailed;
    }

    public void setLayersFailed(List<String> layersFailed) {
        this.layersFailed = layersFailed;
    }

    public boolean isServiceCreated() {
        return serviceCreated;
    }

    public void setServiceCreated(boolean serviceCreated) {
        this.serviceCreated = serviceCreated;
    }

    public boolean isStoreCreated() {
        return storeCreated;
    }

    public void setStoreCreated(boolean storeCreated) {
        this.storeCreated = storeCreated;
    }

    public boolean isFatal() {
        return fatal;
    }

    public void setFatal(boolean fatal) {
        this.fatal = fatal;
    }
    
    public String getServiceMessage() {
        return serviceMessage;
    }

    public void setServiceMessage(String serviceMessage) {
        this.serviceMessage = serviceMessage;
    }

    public String getStoreMessage() {
        return storeMessage;
    }

    public void setStoreMessage(String storeMessage) {
        this.storeMessage = storeMessage;
    }

    public String getFatalMessage() {
        return fatalMessage;
    }

    public void setFatalMessage(String fatalMessage) {
        this.fatalMessage = fatalMessage;
    }
    
    public StringBuilder getLayersFailedMessages() {
        return layersFailedMessages;
    }

    public void setLayersFailedMessages(StringBuilder layersFailedMessages) {
        this.layersFailedMessages = layersFailedMessages;
    }
    
    // </editor-fold>

}
