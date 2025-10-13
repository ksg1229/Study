package com.study.free.community.vo;

import java.math.BigDecimal;

public class CreateCommentVO {
    private BigDecimal postId;
    private String authorId;
    private BigDecimal parentId; // 선택
    private String content;

    
    public CreateCommentVO() {
	}
    
	public BigDecimal getPostId() { return postId; }
    public void setPostId(BigDecimal postId) { this.postId = postId; }
    public String getAuthorId() { return authorId; }
    public void setAuthorId(String authorId) { this.authorId = authorId; }
    public BigDecimal getParentId() { return parentId; }
    public void setParentId(BigDecimal parentId) { this.parentId = parentId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}