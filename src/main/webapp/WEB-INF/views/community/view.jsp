<!-- /WEB-INF/views/community/view.jsp (발췌/차이점만) -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>${post.title}</title>
<jsp:include page="/WEB-INF/inc/top.jsp" />
  <script>
    function setReplyParent(parentId, nick){
      const box = document.getElementById('reply-box-' + parentId);
      const shown = box.style.display === 'block';
      box.style.display = shown ? 'none' : 'block';
      if (!shown) {
        const ta = box.querySelector('textarea');
        if (ta) {
          ta.placeholder = nick ? ('@' + nick + ' 에게 답글…') : '답글을 입력하세요';
          setTimeout(()=>ta.focus(), 0);
        }
      }
    }
  </script>
</head>

<body>
<div class="app">
<jsp:include page="/WEB-INF/inc/header.jsp" />
<jsp:include page="/WEB-INF/inc/sidebar.jsp" />
  <main class="main">
    <!-- 본문 영역 동일 -->
      <!-- ✅ 게시글 카드 -->
  <article class="post-view card">
    <header class="pv-head">
      <div class="pv-title-row">
        <h1 class="pv-title">${post.title}</h1>
        <c:if test="${not empty post.category}">
          <span class="chip">${post.category}</span>
        </c:if>
      </div>

      <div class="pv-meta">
        <span class="who"><strong>${post.authorId}</strong></span>
        <span class="dot">·</span>
        <span class="when">
          <fmt:formatDate value="${post.createdAt}" pattern="yyyy.MM.dd HH:mm"/>
        </span>
        <span class="dot">·</span>
        <span class="views">조회수 ${post.viewCnt}</span>

        <!-- 글 소유자/관리자 액션(선택) -->
        <span class="spacer"></span>
        <c:if test="${(not empty loginMemberId and loginMemberId == post.authorId) or (isAdmin == true)}">
          <a class="pv-action" href="${pageContext.request.contextPath}/community/edit/${post.postId}">수정</a>
          <form method="post" action="${pageContext.request.contextPath}/community/delete/${post.postId}" style="display:inline">
            <button type="submit" class="pv-action danger">삭제</button>
          </form>
        </c:if>
      </div>
    </header>

    <section class="pv-body">
      <!-- 본문: 줄바꿈 보존. (HTML 허용이라면 c:out 대신 그대로 출력하도록 바꿔도 됨) -->
      <pre class="pv-text">${post.content}</pre>
      <!-- 첨부/이미지 섹션이 있다면 여기에 추가 -->
    </section>
  </article>

    <section class="comments">
      <h3 class="comments-title">댓글</h3>

      <c:forEach var="cmt" items="${comments}">
        <div class="comment ${cmt.parentId != null ? 'reply' : ''}">
          <div class="meta">
            <strong>${cmt.authorId}</strong>
            <span class="dot">·</span>
            <fmt:formatDate value="${cmt.createdAt}" pattern="yyyy.MM.dd HH:mm"/>
          </div>

          <div class="body">
            <pre class="text">${cmt.content}</pre>
          </div>

          <div class="comment-actions">
            <button type="button" class="link" onclick="setReplyParent('${cmt.commentId}','${cmt.authorId}')">답글</button>

            <c:if test="${(not empty loginMemberId and loginMemberId == cmt.authorId) or (isAdmin == true)}">
              <form method="post" action="${pageContext.request.contextPath}/community/comments/${cmt.commentId}/delete">
                <input type="hidden" name="postId" value="${post.postId}"/>
                <input type="hidden" name="page" value="${pageMeta.page}"/>
                <button type="submit" class="link danger">삭제</button>
              </form>
            </c:if>
          </div>

          <!-- 답글 입력 -->
          <div id="reply-box-${cmt.commentId}" class="reply-form" style="display:none">
            <form method="post" action="${pageContext.request.contextPath}/community/comments" class="comment-form">
              <input type="hidden" name="postId" value="${post.postId}"/>
              <input type="hidden" name="parentId" value="${cmt.commentId}"/>
              <textarea name="content" placeholder="답글을 입력하세요"></textarea>
              <div class="row">
                <button type="submit" class="btn primary sm">등록</button>
              </div>
            </form>
          </div>
        </div>
      </c:forEach>

      <c:if test="${empty comments}">
        <p class="muted">첫 댓글을 작성해보세요 ✨</p>
      </c:if>

      <!-- 페이징 -->
      <c:if test="${pageMeta.total > pageMeta.size}">
        <nav class="pagination">
          <c:choose>
            <c:when test="${pageMeta.hasPrev}">
              <a class="page" href="${pageContext.request.contextPath}/community/view/${post.postId}?page=${pageMeta.page - 1}&size=${pageMeta.size}">이전</a>
            </c:when>
            <c:otherwise><span class="page disabled">이전</span></c:otherwise>
          </c:choose>

          <c:forEach var="p" begin="${pageMeta.start}" end="${pageMeta.end}">
            <c:choose>
              <c:when test="${p == pageMeta.page}"><span class="page active">${p}</span></c:when>
              <c:otherwise><a class="page" href="${pageContext.request.contextPath}/community/view/${post.postId}?page=${p}&size=${pageMeta.size}">${p}</a></c:otherwise>
            </c:choose>
          </c:forEach>

          <c:choose>
            <c:when test="${pageMeta.hasNext}">
              <a class="page" href="${pageContext.request.contextPath}/community/view/${post.postId}?page=${pageMeta.page + 1}&size=${pageMeta.size}">다음</a>
            </c:when>
            <c:otherwise><span class="page disabled">다음</span></c:otherwise>
          </c:choose>
        </nav>
      </c:if>

      <!-- 새 댓글 -->
      <h4 class="comments-subtitle">댓글 작성</h4>
      <form method="post" action="${pageContext.request.contextPath}/community/comments" class="comment-form">
        <input type="hidden" name="postId" value="${post.postId}"/>
        <input type="hidden" name="page" value="${pageMeta.page}"/>
        <textarea name="content" placeholder="댓글을 입력하세요 (Shift+Enter 줄바꿈)"></textarea>
        <div class="row">
          <button type="submit" class="btn primary sm">등록</button>
        </div>
      </form>
    </section>
  </main>
  </div>
  <script>
  document.addEventListener('keydown', function(e){
    const t = e.target;
    if (t && t.matches('.comment-form textarea') && e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      t.closest('form').submit();
    }
  });
</script>
</body>
</html>
