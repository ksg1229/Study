package com.study.free.message.vo;

import java.sql.Timestamp;

public class MessageVO {
    private Integer msgId;       // PK (IDENTITY)
    private Integer roomId;      // FK
    private String  senderId;    // FK → MEMBERS.MEM_ID
    private String  msgType;     // 'TEXT' | 'IMAGE' | 'MEMO' | 'SYSTEM'
    private String  content;     // CLOB
    private Integer atSec;       // MEMO 위치
    private String  metaJson;    // 이미지 메타 등
    private Timestamp createdAt; // SYSTIMESTAMP
    private String  delYn;

    public Integer getMsgId() { return msgId; }
    public void setMsgId(Integer msgId) { this.msgId = msgId; }
    public Integer getRoomId() { return roomId; }
    public void setRoomId(Integer roomId) { this.roomId = roomId; }
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    public String getMsgType() { return msgType; }
    public void setMsgType(String msgType) { this.msgType = msgType; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Integer getAtSec() { return atSec; }
    public void setAtSec(Integer atSec) { this.atSec = atSec; }
    public String getMetaJson() { return metaJson; }
    public void setMetaJson(String metaJson) { this.metaJson = metaJson; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getDelYn() { return delYn; }
    public void setDelYn(String delYn) { this.delYn = delYn; }
}