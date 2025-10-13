package com.study.free.community.vo;

import java.util.Date;
import java.math.BigDecimal;

public class CommunityPostVO {
	private BigDecimal postId;   // NUMBER(19)
	private String authorId;
	private String category;
	private String title;
	private String content;
	private int viewCnt;
	private String delYn;
	private Date createdAt;
	private Date updatedAt;
	private String authorProfileImg;

	public CommunityPostVO() {
	}
	
	public BigDecimal getPostId() { return postId; }
	public void setPostId(BigDecimal postId) { this.postId = postId; }
	public String getAuthorId() { return authorId; }
	public void setAuthorId(String authorId) { this.authorId = authorId; }
	public String getCategory() { return category; }
	public void setCategory(String category) { this.category = category; }
	public String getTitle() { return title; }
	public void setTitle(String title) { this.title = title; }
	public String getContent() { return content; }
	public void setContent(String content) { this.content = content; }
	public int getViewCnt() { return viewCnt; }
	public void setViewCnt(int viewCnt) { this.viewCnt = viewCnt; }
	public String getDelYn() { return delYn; }
	public void setDelYn(String delYn) { this.delYn = delYn; }
	public Date getCreatedAt() { return createdAt; }
	public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
	public Date getUpdatedAt() { return updatedAt; }
	public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
	public String getAuthorProfileImg() {
		return authorProfileImg;
	}

	public void setAuthorProfileImg(String authorProfileImg) {
		this.authorProfileImg = authorProfileImg;
	}

	@Override
	public String toString() {
		return "CommunityPostVO [postId=" + postId + ", authorId=" + authorId + ", category=" + category + ", title="
				+ title + ", content=" + content + ", viewCnt=" + viewCnt + ", delYn=" + delYn + ", createdAt="
				+ createdAt + ", updatedAt=" + updatedAt + ", authorProfileImg=" + authorProfileImg + "]";
	}

	
}
