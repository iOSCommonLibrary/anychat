package com.bairuitech.anychat;

public class SignResult {
    private int    timestamp;
    private String sigStr;
    private int    errorcode;
    
    public int getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(int timestamp) {
        this.timestamp = timestamp;
    }
    
    public String getSigStr() {
        return sigStr;
    }
    
    public void setSigStr(String sigStr) {
        this.sigStr = sigStr;
    }
    
    public int getErrorcode() {
        return errorcode;
    }
    
    public void setErrorcode(int errorcode) {
        this.errorcode = errorcode;
    }
}
