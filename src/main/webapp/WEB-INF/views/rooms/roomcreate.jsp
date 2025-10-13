<!-- /WEB-INF/views/rooms/create.jsp -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>새 스터디 방 만들기</title>
  <jsp:include page="/WEB-INF/inc/top.jsp" />

</head>
<body class="study-create-page">
<div class="app">
  <jsp:include page="/WEB-INF/inc/header.jsp" />
  <jsp:include page="/WEB-INF/inc/sidebar.jsp" />

  <main class="main">
    <div class="create-wrap">
      <div class="form-card">
        <h2>새 스터디 방 만들기</h2>
        <p class="subtitle">유튜브 링크는 다양한 형태를 넣어도 자동으로 영상 ID를 추출합니다.</p>

        <c:if test="${not empty error}">
          <div class="error" style="color:#ef4444">${error}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/rooms/create" autocomplete="off">
  <!-- ytId는 VO에 없으므로 EL로 접근하지 말고, JS가 채우도록만 둔다 -->
<input type="hidden" name="ytId" id="videoId"/>

  <!-- 방 제목 -->
  <div class="form-row">
    <label for="title">방 제목 <span class="req">*</span></label>
    <div style="flex:1">
      <input id="title" type="text" name="title" value="${form.title}" maxlength="200" required />
      <!-- 제목 필드 아래에 표시될 에러 영역 추가 -->
		<div id="titleErr" class="error-text" style="display:none">이미 존재하는 방 제목입니다.</div>
      <div class="muted">예: 문제풀이 스터디 (매주 화/목)</div>
    </div>
  </div>

  <!-- 유튜브 링크 -->
  <div class="form-row">
    <label for="videoInput">유튜브 링크 <span class="req">*</span></label>
    <div style="flex:1">
      <input id="videoInput" type="url" name="ytUrl" value="${form.ytUrl}" placeholder="https://www.youtube.com/watch?v=..." required />
      <div class="muted">youtu.be / shorts / watch 등 대부분 링크 지원</div>

      <!-- 썸네일 미리보기 -->
      <div id="thumbCard" class="thumb-card">
        <img id="thumbImg" alt="영상 썸네일 미리보기"/>
        <div class="thumb-meta">추출된 영상 ID: <span id="thumbIdText"></span></div>
      </div>
    </div>
  </div>

  <div class="actions">
    <button type="submit" class="btn primary">방 생성</button>
    <a href="${pageContext.request.contextPath}/rooms" class="btn ghost">취소</a>
  </div>
</form>
      </div>
    </div>
  </main>
</div>

<script>
  // --- 유튜브 링크 → 영상 ID 추출 + 썸네일 미리보기 ---
  (function(){
    const videoInput = document.getElementById('videoInput');
    const videoId = document.getElementById('videoId');
    const card = document.getElementById('thumbCard');
    const img  = document.getElementById('thumbImg');
    const idTxt= document.getElementById('thumbIdText');

    function extractYouTubeId(input){
      if(!input) return "";
      // 이미 ID만 들어온 경우
      if(/^[a-zA-Z0-9_-]{11}$/.test(input)) return input;
      try{
        const u = new URL(input);
        // youtu.be/<id>
        if(u.hostname.includes('youtu.be')) {
          const id = u.pathname.split('/').filter(Boolean)[0] || '';
          if(/^[a-zA-Z0-9_-]{11}$/.test(id)) return id;
        }
        // youtube.com/watch?v= / shorts/<id> / live/<id>
        if(u.hostname.includes('youtube.com')){
          const v = u.searchParams.get('v');
          if(v && /^[a-zA-Z0-9_-]{11}$/.test(v)) return v;
          const parts = u.pathname.split('/').filter(Boolean);
          const maybe = parts[1] || parts[0] || '';
          if(/^[a-zA-Z0-9_-]{11}$/.test(maybe)) return maybe;
        }
      }catch(e){}
      return "";
    }

    function renderThumb(id){
      if(id){
        videoId.value = id;
        img.src = "https://i.ytimg.com/vi/" + id + "/hqdefault.jpg";
        idTxt.textContent = id;
        card.style.display = "block";
        videoInput.style.borderColor = "";
      }else{
        videoId.value = "";
        img.removeAttribute('src');
        idTxt.textContent = "";
        card.style.display = "none";
        // 유효하지 않은 링크일 때 테두리로 피드백
        videoInput.style.borderColor = (videoInput.value) ? '#ef4444' : '';
      }
    }

    function sync(){
      const id = extractYouTubeId(videoInput.value.trim());
      renderThumb(id);
    }

    if(videoInput){ videoInput.addEventListener('input', sync); sync(); }
  })();
  
  (function(){
	  const base = '${pageContext.request.contextPath}';
	  const titleInput = document.getElementById('title');
	  const errBox = document.getElementById('titleErr');
	  const form = document.querySelector('form');

	  let lastChecked = '', lastResult = true;
	  let typingTimer;

	  async function checkTitle(force=false){
	    const t = titleInput.value.trim();
	    if(!t){ showOK(); return true; }
	    if(!force && t === lastChecked){ return lastResult; }

	    try{
	      const res = await fetch(base + '/rooms/check-title?title=' + encodeURIComponent(t), {cache:'no-store'});
	      const data = await res.json();
	      lastChecked = t;
	      lastResult = !!data.ok;
	      if(lastResult){ showOK(); } else { showDup(); }
	      return lastResult;
	    }catch(e){
	      // 네트워크 에러 시에는 막지 않음(서버 단에서 또 걸림)
	      showOK();
	      return true;
	    }
	  }

	  function showDup(){
	    titleInput.classList.add('error');
	    titleInput.style.borderColor = '#ef4444';
	    errBox.style.display = 'block';
	    errBox.textContent = '이미 존재하는 방 제목입니다. 다른 이름을 사용해 주세요.';
	  }
	  function showOK(){
	    titleInput.classList.remove('error');
	    titleInput.style.borderColor = '';
	    errBox.style.display = 'none';
	  }

	  // 타이핑 후 300ms 디바운스
	  titleInput.addEventListener('input', () => {
	    clearTimeout(typingTimer);
	    typingTimer = setTimeout(()=>checkTitle(false), 300);
	  });
	  titleInput.addEventListener('blur', () => checkTitle(true));

	  // 제출 가로채서 최종 검증
	  form.addEventListener('submit', async (e)=>{
	    const ok = await checkTitle(true);
	    if(!ok){
	      e.preventDefault();
	      alert('이미 있는 방 제목입니다. 다른 제목을 입력해 주세요.');
	      titleInput.focus();
	      return false;
	    }
	  });
	})();
</script>
</body>
</html>
