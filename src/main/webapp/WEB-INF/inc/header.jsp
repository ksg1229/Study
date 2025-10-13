<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="https://code.jquery.com/jquery-3.7.1.js" ></script>

<header class="topbar">
  <!-- 좌: 로고 -->
  <div class="logo">
    <a href="/" style="text-decoration:none;color:inherit">StudySync</a>
  </div>

  <!-- 우: 인증/유저 영역 -->
  <div class="actions" style="display:flex;align-items:center;gap:10px;position:relative">
<button id="themeToggle" type="button" class="btn ghost theme-toggle" aria-pressed="false" title="테마 전환">
  <span class="icon" aria-hidden="true">🌙</span>
</button>
      <!-- 비로그인: 로그인 / 회원가입 버튼 -->
      <!-- 로그인 전 -->
		<c:if test= "${sessionScope.login.memId == null}">
        	<a href="${pageContext.request.contextPath}/loginView" class="btn ghost">로그인</a>
        	<a href="${pageContext.request.contextPath}/registView"  class="btn primary">회원가입</a>
		</c:if>

      <!-- 로그인 상태: 마이페이지 + 아바타 드롭다운 -->
      	<c:if test= "${sessionScope.login.memId != null}">	
        <!-- 유저 버튼 -->
        <button type="button" id="userBtn" class="btn" style="display:flex;align-items:center;gap:8px">
          <img class="avatar"
               src="<c:url value='${sessionScope.login.profileImg != null ? sessionScope.login.profileImg : "/assets/img/non.png"}'/>"
               alt="me"/>
          <span style="font-weight:600"><c:url value="${sessionScope.login.memNm}"/></span>
        </button>

        <!-- 드롭다운 메뉴 -->
        <div id="userMenu" class="card shadow"
             style="position:absolute; right:0; top:56px; min-width:220px; display:none; z-index:100">
          <div class="inner" style="padding:6px 0">
            <a href="${pageContext.request.contextPath}/mypageView" class="menu-item" style="display:block;padding:10px 14px">마이페이지</a>
            <a href="${pageContext.request.contextPath}/rooms"  class="menu-item" style="display:block;padding:10px 14px">스터디 목록</a>
            <a href="${pageContext.request.contextPath}/community/list" class="menu-item" style="display:block;padding:10px 14px">커뮤니티</a>
            <a href="${pageContext.request.contextPath}/logoutDo" class="menu-item" style="display:block;padding:10px 14px;color:#b91c1c">로그아웃</a>
          </div>
        </div>
        </c:if>
  </div>
</header>

<!-- 드롭다운 토글 스크립트 -->
<script>
// 이미 있는 변수들 아래에 추가
var meId = '<c:out value="${loginMemberId}"/>'; // MEMBERS.MEM_ID

(function(){
  const btn = document.getElementById('userBtn');
  const menu = document.getElementById('userMenu');
  if(!btn || !menu) return;

  btn.addEventListener('click', function(e){
    e.stopPropagation();
    menu.style.display = (menu.style.display === 'block') ? 'none' : 'block';
  });

  document.addEventListener('click', function(){
    if(menu.style.display === 'block') menu.style.display = 'none';
  });

  // 접근성: ESC로 닫기
  document.addEventListener('keydown', function(e){
    if(e.key === 'Escape' && menu.style.display === 'block') menu.style.display = 'none';
  });
})();

(function() {
  const KEY = 'studyssong-theme'; // 'dark' or 'light'
  const $btn = document.getElementById('themeToggle');

  function apply(theme){
    const dark = theme === 'dark';
    document.body.classList.toggle('theme-dark', dark);
    // 버튼 상태/라벨 업데이트
    if ($btn){
      $btn.setAttribute('aria-pressed', String(dark));
      $btn.querySelector('.icon').textContent = dark ? '🌞' : '🌙';
    }
  }

  // 최초 로드: 저장된 값 적용 (없으면 시스템 설정 따름)
  const saved = localStorage.getItem(KEY);
  const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  apply(saved ? saved : (prefersDark ? 'dark' : 'light'));

  // 클릭 토글
  $btn && $btn.addEventListener('click', function(){
    const isDark = document.body.classList.contains('theme-dark');
    const next = isDark ? 'light' : 'dark';
    localStorage.setItem(KEY, next);
    apply(next);
  });
})();
</script>
