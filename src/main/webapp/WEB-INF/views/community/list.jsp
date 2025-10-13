<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>커뮤니티 - 목록</title>
 <jsp:include page="/WEB-INF/inc/top.jsp" />
</head>
<body class="community-page">
 <div class="app">
<jsp:include page="/WEB-INF/inc/header.jsp" />
<jsp:include page="/WEB-INF/inc/sidebar.jsp" />
  <main class="feed-wrap">
    <!-- 상단: 제목 + 글쓰기 -->
    <div class="feed-top">
      <h1>커뮤니티 게시판</h1>
      <a class="btn primary" href="${pageContext.request.contextPath}/community/write">✏️ 새 글 작성</a>
    </div>

    <!-- 피드 -->
    <section class="feed">
      <c:forEach var="p" items="${posts}">
        <article class="feed-post card">
          <!-- 헤더(아바타/작성자/시간/카테고리) -->
		<header class="post-head">
		  <c:set var="avatarSrc"
		         value="${empty p.authorProfileImg ? '/assets/img/non.png' : p.authorProfileImg}"/>
		  <img class="avatar lg" src="<c:url value='${avatarSrc}'/>" alt="">
		
		  <div class="who">
		    <div class="nick"><strong>${p.authorId}</strong></div>
		    <div class="meta">
		      <fmt:formatDate value="${p.createdAt}" pattern="yyyy.MM.dd HH:mm"/>
		      <c:if test="${not empty p.category}">
		        · <span class="chip">${p.category}</span>
		      </c:if>
		    </div>
		  </div>
		</header>

          <!-- 본문(제목/요약/썸네일) -->
          <div class="post-body">
            <a href="${pageContext.request.contextPath}/community/view/${p.postId}">
              <h3 class="post-title">${p.title}</h3>
            </a>
            <p class="post-excerpt">
              <c:out value="${fn:length(p.content) > 140
                              ? fn:substring(p.content,0,140).concat('…')
                              : p.content}"/>
            </p>

<!--             썸네일: 이미지 URL 필드가 있을 때만 -->
<%--             <c:if test="${not empty p.imageUrl}"> --%>
<%--               <a href="${pageContext.request.contextPath}/community/view/${p.postId}"> --%>
<%--                 <img class="post-img" src="${p.imageUrl}" alt=""> --%>
<!--               </a> -->
<%--             </c:if> --%>
          </div>

          <!-- 푸터(조회수/댓글/공유) -->
          <footer class="post-foot">
            <span class="views">조회수 ${p.viewCnt}</span>
            <a class="action" href="${pageContext.request.contextPath}/community/view/${p.postId}">댓글</a>
            <button class="action" type="button" onclick="navigator.share ? navigator.share({title:'${p.title}', url: location.origin + '${pageContext.request.contextPath}/community/view/${p.postId}'}) : alert('링크 복사: ' + location.origin + '${pageContext.request.contextPath}/community/view/${p.postId}')">공유</button>
          </footer>
        </article>
      </c:forEach>

      <c:if test="${empty posts}">
        <div class="card" style="padding:18px">등록된 게시글이 없습니다.</div>
      </c:if>
    </section>
  </main>
  </div>
</body>
</html>