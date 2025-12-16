package com.study.free.sync.vo;

import java.sql.Timestamp;

public class PlaybackStateVO {

    private Integer roomId; // BigDecimal → Integer
    private String ytId;
    private Integer positionSec;
    private String isPaused; // 'Y' or 'N'
    private String updatedBy;
    private Timestamp updatedAt; // Oracle TIMESTAMP ↔ 안전 매핑

    public PlaybackStateVO() {
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public String getYtId() {
        return ytId;
    }

    public void setYtId(String ytId) {
        this.ytId = ytId;
    }

    public Integer getPositionSec() {
        return positionSec;
    }

    public void setPositionSec(Integer positionSec) {
        this.positionSec = positionSec;
    }

    public String getIsPaused() {
        return isPaused;
    }

    public void setIsPaused(String isPaused) {
        this.isPaused = isPaused;
    }

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "PlaybackStateVO{" +
                "roomId=" + roomId +
                ", ytId='" + ytId + '\'' +
                ", positionSec=" + positionSec +
                ", isPaused='" + isPaused + '\'' +
                ", updatedBy='" + updatedBy + '\'' +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
