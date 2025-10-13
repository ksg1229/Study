<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>커뮤니티 - 글쓰기</title>
  <jsp:include page="/WEB-INF/inc/top.jsp" />
</head>
<body class="community-write-page">
<div class="app">
  <jsp:include page="/WEB-INF/inc/header.jsp" />
  <jsp:include page="/WEB-INF/inc/sidebar.jsp" />

  <main class="write-wrap">
    <h1>글쓰기</h1>

    <c:if test="${not empty error}">
      <div class="error">${error}</div>
    </c:if>

    <form action="<c:url value='/community/writeDo'/>" method="post">
      <!-- (선택) Spring Security 사용시 CSRF -->
      <c:if test="${not empty _csrf}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
      </c:if>

      <!-- 카테고리 -->
      <div class="form-row">
        <label for="category">카테고리</label>
        <div>
          <c:set var="cat" value="${empty param.category ? '' : param.category}" />
          <select id="category" name="category">
            <option value=""           <c:if test="${cat==''}">selected</c:if>>선택 안 함</option>
            <option value="학습팁"     <c:if test="${cat=='학습팁'}">selected</c:if>>학습팁</option>
            <option value="질문"       <c:if test="${cat=='질문'}">selected</c:if>>질문</option>
            <option value="자료공유"   <c:if test="${cat=='자료공유'}">selected</c:if>>자료공유</option>
            <option value="자유"       <c:if test="${cat=='자유'}">selected</c:if>>자유</option>
          </select>
        </div>
      </div>

      <!-- 제목 -->
      <div class="form-row">
        <label for="title">제목<span class="req">*</span></label>
        <div>
          <input type="text" id="title" name="title" maxlength="300" required
			       placeholder="제목을 입력하세요."
			       value="<c:out value='${param.title}'/>"
			       autofocus />
        </div>
      </div>

      <!-- 내용 -->
      <div class="form-row">
        <label for="content">내용<span class="req">*</span></label>
        <div>
          <textarea id="content" name="content" rows="14" required
                    placeholder="내용을 입력하세요. (Shift+Enter 줄바꿈, Ctrl/Cmd+Enter 등록)"><c:out value="${param.content}"/></textarea>
        </div>
      </div>

      <div class="actions">
        <a class="btn ghost" href="<c:url value='/community/list'/>">목록</a>
        <button type="submit" class="btn primary" id="submitBtn">등록</button>
      </div>
    </form>
  </main>
</div>

<script>
  // 간단 검증 + Ctrl/Cmd + Enter로 제출
  const form = document.querySelector('form');
  const titleEl = document.getElementById('title');
  const contentEl = document.getElementById('content');
  const submitBtn = document.getElementById('submitBtn');

  form.addEventListener('submit', function(e){
    const title = titleEl.value.trim();
    const content = contentEl.value.trim();
    if (!title || title.length > 300) {
      alert('제목은 1~300자로 입력하세요.');
      e.preventDefault(); return;
    }
    if (!content) {
      alert('내용을 입력하세요.');
      e.preventDefault(); return;
    }
    submitBtn.disabled = true;  // 중복 제출 방지
  });

  // Ctrl/Cmd + Enter로 제출
  contentEl.addEventListener('keydown', function(e){
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
      form.requestSubmit();
    }
  });
</script>
</body>
</html>
