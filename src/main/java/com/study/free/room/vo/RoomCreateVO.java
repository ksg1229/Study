package com.study.free.room.vo;

public class RoomCreateVO {
	
	 private String title;
	 private String youtubeUrl;
	 private Integer maxMember;
	 
	public RoomCreateVO() {
	}
	
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getYoutubeUrl() {
		return youtubeUrl;
	}
	public void setYoutubeUrl(String youtubeUrl) {
		this.youtubeUrl = youtubeUrl;
	}
	public Integer getMaxMember() {
		return maxMember;
	}
	public void setMaxMember(Integer maxMember) {
		this.maxMember = maxMember;
	}
	@Override
	public String toString() {
		return "RoomCreateVO [title=" + title + ", youtubeUrl=" + youtubeUrl + ", maxMember=" + maxMember + "]";
	}
	 
	 

}
