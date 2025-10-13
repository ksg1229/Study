package com.study.free.sync.vo;

import java.util.Date;

public class RoomState {
    private String roomId;
    private String videoId;
    private int    positionSec;   // DB: POSITION_SEC
    private String playing;     // "Y"/"N" DB: PLAYING
    private Date   updatedAt;     // DB: UPDATED_AT (TIMESTAMP)

    // 메모리/응답용(비저장)
    private String hostName;
    private String hostSessionId;

    public String getRoomId() { return roomId; }
    public void setRoomId(String roomId) { this.roomId = roomId; }

    public String getVideoId() { return videoId; }
    public void setVideoId(String videoId) { this.videoId = videoId; }

    public int getPositionSec() { return positionSec; }
    public void setPositionSec(int positionSec) { this.positionSec = positionSec; }


    public String getPlaying() {
		return playing;
	}
	public void setPlaying(String playing) {
		this.playing = playing;
	}
	public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public String getHostName() { return hostName; }
    public void setHostName(String hostName) { this.hostName = hostName; }

    public String getHostSessionId() { return hostSessionId; }
    public void setHostSessionId(String hostSessionId) { this.hostSessionId = hostSessionId; }
}
