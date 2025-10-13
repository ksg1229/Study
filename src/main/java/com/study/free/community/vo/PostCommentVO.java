package com.study.free.community.vo;

import java.util.Date;
import java.math.BigDecimal;

public class PostCommentVO {
    private BigDecimal commentId;
    private BigDecimal postId;
    private String authorId;
    private BigDecimal parentId;   // null이면 일반 댓글
    private String content;
    private String delYn;
    private Date createdAt;
    private Date updatedAt;

    public PostCommentVO() {
	}
    
	public BigDecimal getCommentId() { return commentId; }
    public void setCommentId(BigDecimal commentId) { this.commentId = commentId; }
    public BigDecimal getPostId() { return postId; }
    public void setPostId(BigDecimal postId) { this.postId = postId; }
    public String getAuthorId() { return authorId; }
    public void setAuthorId(String authorId) { this.authorId = authorId; }
    public BigDecimal getParentId() { return parentId; }
    public void setParentId(BigDecimal parentId) { this.parentId = parentId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getDelYn() { return delYn; }
    public void setDelYn(String delYn) { this.delYn = delYn; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
    
	@Override
	public String toString() {
		return "PostCommentVO [commentId=" + commentId + ", postId=" + postId + ", authorId=" + authorId + ", parentId="
				+ parentId + ", content=" + content + ", delYn=" + delYn + ", createdAt=" + createdAt + ", updatedAt="
				+ updatedAt + "]";
	}
    
    
}