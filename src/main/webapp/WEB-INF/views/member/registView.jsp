<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>회원가입</title>
  <jsp:include page="/WEB-INF/inc/top.jsp" />
</head>
<body class="auth-page">

  <div class="container">
    <main>
      <div class="form-box">
        <h2>회원가입</h2>
        <form action="${pageContext.request.contextPath}/registDo" method="post" id="signupForm">
		  <label for="memId">아이디</label>
		  <input type="text" id="memId" name="memId" required />
		
		  <label for="memNm">이름</label>
		  <input type="text" id="memNm" name="memNm" required />
		
		  <label for="email">이메일</label>
		  <input type="email" id="email" name="email" required />
		  <p id="emailMsg" style="margin:6px 0 12px; font-size:0.9rem;"></p>
		
		  <label for="memPw">비밀번호</label>
		  <input type="password" id="memPw" name="memPw"
		         required minlength="8" autocomplete="new-password" />
		
		  <label for="memPw2">비밀번호 확인</label>
		  <input type="password" id="memPw2" name="memPw2"
		         required minlength="8" autocomplete="new-password" />
		
		  <!-- 메시지 -->
		  <p id="pwMsg" style="margin:6px 0 12px; font-size:0.9rem;"></p>
		
		  <button type="submit" class="btn-submit" disabled>회원가입</button>
		
		  <p class="switch-text">
		    이미 계정이 있으신가요?
		    <a href="${pageContext.request.contextPath}/loginView">로그인</a>
		  </p>
		</form>
		
		<script>
		(function(){
		  const form = document.getElementById('signupForm');
		  const pw = document.getElementById('memPw');
		  const pw2 = document.getElementById('memPw2');
		  const btn = form.querySelector('.btn-submit');
		  const msg = document.getElementById('pwMsg');
		
		  function validate(){
		    const p1 = pw.value.trim();
		    const p2 = pw2.value.trim();
		
		    if (p1.length < 8) {
		      msg.textContent = '비밀번호는 최소 8자 이상이어야 합니다.';
		      msg.style.color = '#d33';
		      btn.disabled = true;
		      return;
		    }
		    if (p1 !== p2) {
		      msg.textContent = '비밀번호가 일치하지 않습니다.';
		      msg.style.color = '#d33';
		      btn.disabled = true;
		      return;
		    }
		    msg.textContent = '비밀번호가 일치합니다.';
		    msg.style.color = '#2a7';
		    btn.disabled = false;
		  }
		
		  pw.addEventListener('input', validate);
		  pw2.addEventListener('input', validate);
		
		  form.addEventListener('submit', function(e){
		    // 혹시나 브라우저/사용자 조작으로 disabled가 풀렸을 경우 대비
		    if (btn.disabled) e.preventDefault();
		  });
		})();
		</script>
      </div>
    </main>
  </div>
</body>
</html>
