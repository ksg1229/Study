<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>WS Sync (Host↔Member, Audio OK)</title>
<style>
  body{font-family:system-ui;background:#0b1020;color:#eef1f6;margin:0}
  header{padding:12px 14px;background:#11193a;display:flex;justify-content:space-between;align-items:center}
  .row{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
  input,button{padding:8px 10px;border-radius:8px;border:1px solid #3a4bb0;background:#151c3d;color:#eef1f6}
  #wrap{margin:14px}
  #player-wrap{aspect-ratio:16/9;background:#0f1433;border:1px solid #26306a;border-radius:12px;display:grid;place-items:center;position:relative}

  /* 멤버는 조작 UI 숨김 */
  body.member #apply, body.member #play, body.member #pause,
  body.member #b10, body.member #f10, body.member #url { display:none; }

  /* 멤버 클릭 차단 오버레이 */
  body.member #player-wrap::after{
    content:"";
    position:absolute; inset:0;
    background:transparent;
    cursor:not-allowed;
    z-index:5;
    pointer-events:auto;
  }

  /* 동기화 시작 버튼 */
  #startSyncBtn{
    position:absolute; bottom:12px; right:12px;
    padding:8px 12px; border-radius:8px; border:1px solid #3a4bb0;
    background:#182457; color:#eef1f6;
    z-index:10;
  }
</style>
</head>
<!-- 테스트 페이지 -->
<body class="${role}">
<header>
  <div class="row"><strong>🎓 WS Sync</strong>
    <span>room: ${room}</span><span>role: ${role}</span><span id="st">연결중…</span></div>
  <div class="row">
    <input id="url" placeholder="YouTube 링크" style="min-width:280px"/>
    <button id="apply">적용</button>
    <button id="play">재생</button>
    <button id="pause">일시정지</button>
    <button id="b10">⟲10</button>
    <button id="f10">10⟳</button>
  </div>
</header>

<div id="wrap">
  <div id="player-wrap"><div id="player"></div></div>
  <pre id="log" style="font-size:12px;opacity:.9"></pre>
</div>

<script>
  // Load YouTube API
  (function(){var s=document.createElement('script'); s.src='https://www.youtube.com/iframe_api'; document.head.appendChild(s);})();
  var player=null;
  var role='${role}', room='${room}', name='${name}', ctx='${pageContext.request.contextPath}';
  if (role === 'member') document.body.classList.add('member');

  var audioUnlocked = false;
  var applyingRemote = false;

  function vid(u){
    try{
      u=new URL(u, location.origin);
      if(u.hostname.indexOf('youtu.be')>-1) return u.pathname.slice(1);
      if(u.searchParams.get('v')) return u.searchParams.get('v');
      var m=(''+u).match(/embed\/([\w-]{6,})/); return m?m[1]:null;
    }catch(e){ return null; }
  }
  function log(t){ var el=document.getElementById('log'); el.textContent += t + "\n"; el.scrollTop = el.scrollHeight; }

  // WebSocket
  var ws=null;
  function wsUrl(){ var sch=location.protocol==='https:'?'wss':'ws'; return sch+'://'+location.host+ctx+'/ws/sync?room='+encodeURIComponent(room)+'&name='+encodeURIComponent(name)+'&role='+encodeURIComponent(role); }
  function connect(){
    ws=new WebSocket(wsUrl());
    ws.onopen = ()=>{ document.getElementById('st').textContent='연결됨'; log('WS open'); };
    ws.onclose= ()=>{ document.getElementById('st').textContent='끊김'; log('WS close'); };
    ws.onerror= ()=>{ document.getElementById('st').textContent='에러';  log('WS error'); };
    ws.onmessage=(ev)=>{ var m=JSON.parse(ev.data); handle(m); log('← '+ev.data); };
  }
  function send(obj){ if(ws && ws.readyState===1){ ws.send(JSON.stringify(obj)); log('→ '+JSON.stringify(obj)); } }

  // YouTube Player
  window.onYouTubeIframeAPIReady=function(){
    var pv={ rel:0, modestbranding:1, playsinline:1, origin: window.location.origin };
    if(role==='member'){ pv.controls=0; pv.disablekb=1; pv.fs=0; pv.iv_load_policy=3; }
    player=new YT.Player('player',{
      videoId:'dQw4w9WgXcQ',
      playerVars: pv,
      events:{ onReady:onReady, onStateChange:onState }
    });
  };

  function onReady(){
    // iframe에 autoplay 권한 부여
    try {
      var iframe=player.getIframe();
      var cur=iframe.getAttribute('allow')||'';
      if(cur.indexOf('autoplay')===-1){
        iframe.setAttribute('allow',(cur?cur+'; ':'')+'autoplay; encrypted-media');
      }
    }catch(e){}
    if(role==='member') showStartSyncButton();
    bind();
    connect();
  }

  function onState(e){
    if(role==='host'){
      var cur=Math.floor(player.getCurrentTime());
      if(e.data===YT.PlayerState.PLAYING) send({type:'PLAY',at:cur});
      if(e.data===YT.PlayerState.PAUSED)  send({type:'PAUSE',at:cur});
      return;
    }
    if(applyingRemote) return;
    if(e.data===YT.PlayerState.PLAYING){
      try{ player.pauseVideo(); }catch(err){}
    }
  }

  function bind(){
    document.getElementById('apply').onclick=()=>{
      if(role!=='host') return;
      var id=vid(document.getElementById('url').value.trim());
      if(!id) return alert('링크 오류');
      player.loadVideoById(id); send({type:'LOAD',id:id});
    };
    document.getElementById('play').onclick=()=>{ if(role==='host') player.playVideo(); };
    document.getElementById('pause').onclick=()=>{ if(role==='host') player.pauseVideo(); };
    document.getElementById('b10').onclick=()=>{ if(role==='host') seek(-10); };
    document.getElementById('f10').onclick=()=>{ if(role==='host') seek(+10); };
  }

  function seek(d){
    var t=Math.max(0,(player&&player.getCurrentTime?Math.floor(player.getCurrentTime()):0)+d);
    player.seekTo(t,true); send({type:'SEEK',to:t});
  }

  function handle(m){
    if(role==='host') return;
    applyingRemote=true;
    switch(m.type){
      case 'LOAD': player.loadVideoById(m.id); break;
      case 'PLAY':
        if(!audioUnlocked){ ensureStartButton(); applyingRemote=false; return; }
        player.seekTo(m.at||0,true);
        player.playVideo();
        setTimeout(()=>{ if(player.getPlayerState()!==YT.PlayerState.PLAYING){ try{ player.playVideo(); }catch(e){} } },800);
        break;
      case 'PAUSE':
        player.seekTo(m.at||0,true); player.pauseVideo(); break;
      case 'SEEK':
        player.seekTo(m.to||0,true); break;
    }
    setTimeout(()=>{ applyingRemote=false; },300);
  }

  function showStartSyncButton(){
    var wrap=document.getElementById('player-wrap');
    if(document.getElementById('startSyncBtn')) return;
    var btn=document.createElement('button');
    btn.id='startSyncBtn';
    btn.textContent='동기화 시작(소리 허용)';
    wrap.appendChild(btn);
    var unlockTimer=null;
    btn.onclick=function(){
      try{
        player.unMute(); player.setVolume(100); player.playVideo();
        var tries=0;
        unlockTimer=setInterval(function(){
          var st=player.getPlayerState();
          if(st===YT.PlayerState.PLAYING){
            audioUnlocked=true;
            clearInterval(unlockTimer);
            setTimeout(()=>{ try{player.pauseVideo();}catch(e){} },200);
            btn.remove();
          }else if(++tries>15){
            try{ player.playVideo(); }catch(e){}
            tries=0;
          }
        },100);
      }catch(e){ console.warn('오디오 권한 실패',e); }
    };
  }
  function ensureStartButton(){ if(!document.getElementById('startSyncBtn')) showStartSyncButton(); }
</script>
</body>
</html>
