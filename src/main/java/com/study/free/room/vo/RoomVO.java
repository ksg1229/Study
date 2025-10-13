package com.study.free.room.vo;


import java.time.LocalDateTime;
import java.util.Date;

public class RoomVO {
    private Integer roomId;
    private String title;
    private String hostMemberId;
    private String memberId;
	private String status;
    private Integer maxMember;
    private String delYn;
    private Date createdAt;

    // 썸네일용 (PLAYBACK_STATE.YT_ID 조인)
    private String ytId;

    public Integer getRoomId() { return roomId; }
    public String getMemberId() {
  		return memberId;
  	}
  	public void setMemberId(String memberId) {
  		this.memberId = memberId;
  	}
    public void setRoomId(Integer roomId) { this.roomId = roomId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getHostMemberId() { return hostMemberId; }
    public void setHostMemberId(String hostMemberId) { this.hostMemberId = hostMemberId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getMaxMember() { return maxMember; }
    public void setMaxMember(Integer maxMember) { this.maxMember = maxMember; }
    public String getDelYn() { return delYn; }
    public void setDelYn(String delYn) { this.delYn = delYn; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public String getYtId() { return ytId; }
    public void setYtId(String ytId) { this.ytId = ytId; }
}