package com.study.free.community.vo;

import java.math.BigDecimal;

public class CommentPageQueryVO {
    private BigDecimal postId;
    private int page;   // 1-base
    private int size;   // page size

    public BigDecimal getPostId() { return postId; }
    public void setPostId(BigDecimal postId) { this.postId = postId; }
    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }
    public int getSize() { return size; }
    public void setSize(int size) { this.size = size; }

    // 11g ROWNUM용
    public int getStartRow() { // inclusive
        return (Math.max(1, page) - 1) * Math.max(1, size) + 1;
    }
    public int getEndRow() {   // inclusive
        return Math.max(1, page) * Math.max(1, size);
    }
}