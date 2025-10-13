<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<nav id="sidebar" class="side" aria-label="사이드바">
  <!-- 아이콘 스프라이트 (페이지 어디든 1번만 선언) -->
  <svg style="display:none;">
    <symbol id="ic-group" viewBox="0 0 24 24"><path d="M16 11a4 4 0 1 0-4-4 4 4 0 0 0 4 4Zm-8 2a4 4 0 1 0-4-4 4 4 0 0 0 4 4Zm8 2c-3.33 0-10 1.67-10 5v2h20v-2c0-3.33-6.67-5-10-5Zm-8 0C4.67 15 0 16.67 0 20v2h8"/></symbol>
    <symbol id="ic-log" viewBox="0 0 24 24"><path d="M3 4h18v4H3zm0 6h18v10H3zM7 2h10v2H7z"/></symbol>
    <symbol id="ic-board" viewBox="0 0 24 24"><path d="M5 3h14a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H8l-5 4V5a2 2 0 0 1 2-2z"/></symbol>
    <symbol id="ic-cal" viewBox="0 0 24 24"><path d="M7 2v2H5a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2h-2V2h-2v2H9V2zM5 8h14v11H5z"/></symbol>
    <symbol id="ic-settings" viewBox="0 0 24 24">
  <!-- 톱니(기어) 아이콘: 선/면 모두 currentColor 사용 -->
  <path fill="currentColor" d="M12 8.5a3.5 3.5 0 1 0 0 7a3.5 3.5 0 0 0 0-7Z"/>
  <path fill="currentColor" d="M20.9 13.5c.07-.5.1-1 .1-1.5s-.03-1-.1-1.5l2-1.55a.7.7 0 0 0 .17-.9l-1.9-3.3a.72.72 0 0 0-.85-.33l-2.35.95a7.8 7.8 0 0 0-2.6-1.5L15.1 1.6a.72.72 0 0 0-.7-.6h-3.8a.72.72 0 0 0-.7.6l-.27 2.37a7.8 7.8 0 0 0-2.6 1.5l-2.35-.95a.72.72 0 0 0-.85.33L1.93 8.2a.7.7 0 0 0 .17.9L4.1 10.6l-.1 1.4l.1 1.5l-2 1.55a.7.7 0 0 0-.17.9l1.9 3.3c.17.3.53.43.85.33l2.35-.95c.8.64 1.67 1.15 2.6 1.5l.27 2.37c.05.33.35.6.7.6h3.8c.35 0 .65-.27.7-.6l.27-2.37c.93-.35 1.8-.86 2.6-1.5l2.35.95c.32.1.68-.03.85-.33l1.9-3.3a.7.7 0 0 0-.17-.9l-2-1.55Z"/>
</symbol>
  </svg>

  <div class="side-head">
    <span id="sideToggle" role="button" tabindex="0" class="side-logo" title="사이드바 접기/펼치기">★</span>
  </div>

  <ul class="side-menu">
    <li><a href="${ctx}/mypageView" title="학습 기록">
      <svg class="ic" aria-hidden="true"><use href="#ic-log"/></svg>
      <span class="text">학습 기록</span>
    </a></li>
    <li><a href="${ctx}/rooms" title="스터디 그룹">
      <svg class="ic" aria-hidden="true"><use href="#ic-group"/></svg>
      <span class="text">스터디 그룹</span>
    </a></li>
    <li><a href="${ctx}/community/list" title="커뮤니티">
      <svg class="ic" aria-hidden="true"><use href="#ic-board"/></svg>
      <span class="text">커뮤니티</span>
    </a></li>
    <li><a href="${ctx}/mypageView" title="캘린더" >
      <svg class="ic" aria-hidden="true"><use href="#ic-cal"/></svg>
      <span class="text">캘린더(미구현)</span>
    </a></li>
    <li>
    <a href="${ctx}/mypageView" title="설정" >
      <svg class="ic" aria-hidden="true"><use href="#ic-settings"/></svg>
      <span class="text">설정(미구현)</span>
    </a>
    </li>
  </ul>
</nav>
<script>
  window.addEventListener('DOMContentLoaded', function () {
    const app = document.querySelector('.app');
    const btn = document.getElementById('sideToggle');
    if (!app || !btn) {
      console.warn('sideToggle 또는 .app을 찾지 못했습니다.');
      return;
    }

    // 저장된 상태 복원
    if (localStorage.getItem('side-collapsed') === '1') {
      app.classList.add('side-collapsed');
    }

    // 클릭/키보드 토글
    const toggle = () => {
      app.classList.toggle('side-collapsed');
      localStorage.setItem('side-collapsed', app.classList.contains('side-collapsed') ? '1' : '0');
    };
    btn.addEventListener('click', toggle);
    btn.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); toggle(); }
    });
  });
  
  (function(){
	  const ctx='${pageContext.request.contextPath}';
	  const path = location.pathname.startsWith(ctx) ? location.pathname.slice(ctx.length) : location.pathname;

	  // 어떤 경로에 어떤 메뉴를 활성화할지 간단 매핑
	  const map = [
	    { when:p=> p==='/mypageView'||p.startsWith('/mypage')||p.startsWith('/study/record'), href:'/mypageView' },
	    { when:p=> p.startsWith('/rooms')||p.startsWith('/study/group'), href:'/rooms' },
	    { when:p=> p.startsWith('/community'), href:'/community/list' },
	    { when:p=> p.startsWith('/calendar'), href:'/calendar' },
	    { when:p=> p.startsWith('/settings'), href:'/settings' },
	  ];

	  const picked = map.find(m=>m.when(path));
	  if (picked){
	    const a = document.querySelector(`.side-menu a[href^="${ctx}${picked.href}"]`);
	    if (a){ a.parentElement.classList.add('active'); a.setAttribute('aria-current','page'); }
	  }
	})();
</script>
