package com.study.free.room.vo;

public class RoomCreateAggVO {
    private Integer roomId;      // OUT
    private String  title;
    private String  hostMemberId; // MEMBERS.mem_id
    private Integer maxMember;    // 1~30
    private String  ytId;         // 파싱된 유튜브 ID

    public Integer getRoomId() { return roomId; }
    public void setRoomId(Integer roomId) { this.roomId = roomId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getHostMemberId() { return hostMemberId; }
    public void setHostMemberId(String hostMemberId) { this.hostMemberId = hostMemberId; }
    public Integer getMaxMember() { return maxMember; }
    public void setMaxMember(Integer maxMember) { this.maxMember = maxMember; }
    public String getYtId() { return ytId; }
    public void setYtId(String ytId) { this.ytId = ytId; }
}
