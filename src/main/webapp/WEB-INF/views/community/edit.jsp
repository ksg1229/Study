<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>게시글 수정</title>
  <jsp:include page="/WEB-INF/inc/top.jsp" />
</head>
<body>
<div class="app">
  <jsp:include page="/WEB-INF/inc/header.jsp" />
  <jsp:include page="/WEB-INF/inc/sidebar.jsp" />
 <main class="main community-write-page">
  <div class="write-wrap">
    <h1>게시글 수정</h1>

    <form method="post" action="${pageContext.request.contextPath}/community/editDo">
      <input type="hidden" name="postId" value="${post.postId}"/>

      <c:set var="cat" value="${post.category}" />
      <div class="form-row">
        <label>카테고리</label>
        <div>
          <select name="category">
            <option value="" <c:if test="${empty cat}">selected</c:if>>선택 안 함</option>
            <option value="학습팁"  <c:if test="${cat=='학습팁'}">selected</c:if>>학습팁</option>
            <option value="질문"    <c:if test="${cat=='질문'}">selected</c:if>>질문</option>
            <option value="자료공유" <c:if test="${cat=='자료공유'}">selected</c:if>>자료공유</option>
            <option value="자유"    <c:if test="${cat=='자유'}">selected</c:if>>자유</option>
          </select>
        </div>
      </div>

      <div class="form-row">
        <label>제목<span class="req">*</span></label>
        <div><input type="text" name="title" maxlength="300" required value="${post.title}"/></div>
      </div>

      <div class="form-row">
        <label>내용<span class="req">*</span></label>
        <div><textarea name="content" rows="12" required>${post.content}</textarea></div>
      </div>

      <div class="actions">
        <button type="submit" class="btn primary">저장</button>
        <a class="btn ghost" href="${pageContext.request.contextPath}/community/view/${post.postId}">취소</a>
      </div>
    </form>
  </div>
</main>

</div>
</body>
</html>