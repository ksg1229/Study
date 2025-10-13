// com.study.free.common.PageMeta (공용 페이징 메타)
package com.study.free.common;

public class PageMeta {
    private final int page;      // 현재 페이지(1-base)
    private final int size;      // 페이지 크기
    private final int total;     // 전체 건수
    private final int lastPage;  // 마지막 페이지
    private final boolean hasPrev;
    private final boolean hasNext;
    private final int start;     // 페이지 네비 시작
    private final int end;       // 페이지 네비 끝

    public PageMeta(int page, int size, int total) {
        this.page = Math.max(1, page);
        this.size = Math.max(1, size);
        this.total = Math.max(0, total);
        this.lastPage = Math.max(1, (int)Math.ceil(total / (double)size));
        this.hasPrev = this.page > 1;
        this.hasNext = this.page < this.lastPage;

        // 네비게이션(예: 5개 단위)
        int block = (int)Math.ceil(this.page / 5.0);
        this.start = (block - 1) * 5 + 1;
        this.end = Math.min(this.start + 5 - 1, this.lastPage);
    }

    public int getPage() { return page; }
    public int getSize() { return size; }
    public int getTotal() { return total; }
    public int getLastPage() { return lastPage; }
    public boolean isHasPrev() { return hasPrev; }
    public boolean isHasNext() { return hasNext; }
    public int getStart() { return start; }
    public int getEnd() { return end; }
}