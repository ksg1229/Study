<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>로그인</title>
  <jsp:include page="/WEB-INF/inc/top.jsp" />
</head>
<body class="auth-page">
  <div class="container">
    <main>
      <div class="form-box">
        <h2>로그인</h2>
        <form action="<c:url value='/loginDo' />" method="post">
			<c:if test="${not empty param.redirect}">
    			<input type="hidden" name="redirect" value="${param.redirect}"/>
  			</c:if>
          <label for="memId">아이디</label>
          <input type="text" value="${cookie.rememberId.value}" id="memId" name="memId" required />

          <label for="memPw">비밀번호</label>
          <input type="password" id="memPw" name="memPw" required />

          <div class="form-floating mb-3">
            <input type="checkbox" ${cookie.rememberId.value == null ? "" : "checked"} class="form-check-input" name="remember">
            아이디 기억하기
          </div>      

          <button type="submit" class="btn-submit">로그인</button>

          <p class="switch-text">
            계정이 없으신가요? 
            <a href="${pageContext.request.contextPath}/registView">회원가입</a>
          </p>
        </form>
      </div>
    </main>
  </div>
</body>
</html>
