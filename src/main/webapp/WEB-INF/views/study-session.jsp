<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <!DOCTYPE html>
    <html lang="ko">

    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width,initial-scale=1" />
      <title>스터디 세션</title>
      <jsp:include page="/WEB-INF/inc/top.jsp" />
      <!-- ★ top.jsp에 jQuery가 없다면 주석 해제
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
-->
    </head>

    <body class="session-page <c:out value='${role}'/>">
      <div class="app">
        <jsp:include page="/WEB-INF/inc/header.jsp" />
        <jsp:include page="/WEB-INF/inc/sidebar.jsp" />

        <div class="container">
          <!-- LEFT -->
          <section>
            <div class="card">
              <h2 style="margin:6px 0 10px;">
                <c:out value="${title != null ? title : '스터디 세션'}" />
              </h2>

              <!-- Player + Whiteboard -->
              <div id="playerWrap" class="playerWrap">
                <div id="player"></div>
                <canvas id="wbCanvas" class="hidden"></canvas><!-- wbOpen이면 모두에게 보임 -->
                <button id="startBtn" style="display:none">동기화</button>
              </div>

              <div class="controls">
                <input id="url" class="hostOnly" placeholder="YouTube 링크" style="min-width:320px" />
                <button id="apply" class="hostOnly">적용</button>
                <button id="play" class="hostOnly">재생</button>
                <button id="pause" class="hostOnly">일시정지</button>
                <button id="b10" class="hostOnly">⟲10</button>
                <button id="f10" class="hostOnly">10⟳</button>
                <button id="end" class="hostOnly"
                  style="margin-left:8px;color:#fff;background:#ef4444;border:0;padding:6px 10px;border-radius:6px">
                  강의 종료
                </button>
                <button id="wbToggle" class="hostOnly">화이트보드 열기</button><!-- 토글 -->
                <span id="st" class="muted">연결중…</span>
              </div>

              <div id="wbToolbar">
                <button id="reqDraw" class="memberOnly">그리기 권한 요청</button>
                <button id="wbPen">펜</button>
                <input id="wbColor" type="color" value="#ff4757" />
                <input id="wbSize" type="range" min="1" max="12" value="3" style="width:120px" />
                <button id="wbUndo" class="hostOnly">되돌리기</button>
                <button id="wbRedo" class="hostOnly">다시하기</button>
                <button id="wbClear" class="hostOnly">화이트보드 지우기</button>
              </div>
            </div>
            <!-- ❌ 이미지 공유 카드 삭제 완료 -->
          </section>

          <!-- RIGHT -->
          <aside style="display:flex;flex-direction:column;gap:12px">
            <div class="card">
              <h3 style="margin:0 0 8px">채팅</h3>
              <div id="chat" class="scrollBox chatList"></div>
              <div class="chatForm">
                <button id="chatPlus" title="이미지 전송">+</button>
                <input id="chatInput" type="text" placeholder="메시지 입력" />
                <button id="chatSend">보내기</button>
                <input id="chatImgFile" type="file" accept="image/*" style="display:none" />
              </div>
            </div>

            <div class="card">
              <h3 style="margin:0 0 8px">내 메모</h3>
              <div id="memo" class="scrollBox memoList"></div>
              <div class="chatForm">
                <input id="memoInput" type="text" placeholder="메모 입력 (현재 재생 위치에 저장)" />
                <button id="memoSend">저장</button>
              </div>
            </div>
          </aside>
        </div>
      </div>
      <script>

        //===== MEMBER sync guards =====
        var lastHostSignal = 0;      // WS로 받은 마지막 시각
        var lastLocalAdjust = 0;     // 클라이언트가 마지막으로 seek/재생상태 바꾼 시각
        var adjustCooldownMs = 1200; // 보정 쿨다운

        // ===== utils =====
        function g(id) { return document.getElementById(id); }
        function escapeHtml(s) { return (s || "").replace(/[&<>"']/g, function (c) { return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]); }); }
        function debounce(fn, wait) { var t; return function () { clearTimeout(t); var a = arguments; t = setTimeout(() => fn.apply(this, a), wait); } }

        // ===== JSP → JS =====
        var role = '<c:out value="${role}"/>';
        var room = '<c:out value="${room}"/>';
        var name = '<c:out value="${name}"/>';
        var ctx = '${pageContext.request.contextPath}';

        //로그인 세션에 저장된 members.mem_id를 JS로 전달
        var meId = '<c:out value="${sessionScope.loginMemberId}"/>';
        if (!meId) { meId = ''; }
        if (role === 'member') document.body.classList.add('member');

        //★ DB에서 내려온 재생상태(컨트롤러에서 playback 모델 주입 필요)
        var INIT = {
          ytId: '<c:out value="${playback.ytId}"/>',
          pos: <c:out value="${playback.positionSec != null ? playback.positionSec : 0}" />,
          paus: '<c:out value="${playback.isPaused != null ? playback.isPaused : \'Y\'}"/>'
        };

        // ★ API 베이스 URL
        var ROOM_ID = parseInt(room, 10) || 0;
        var API_BASE = ctx + '/api/rooms/' + ROOM_ID;

        // 권한
        var canDraw = (role === 'host'); // 호스트는 기본 그리기 권한
        var canShareImage = (role === 'host');  // 채팅 이미지 전송 권한(패널은 제거)

        // 화이트보드 오픈 상태
        var wbOpen = false;

        // ===== YouTube =====
        (function () { var s = document.createElement('script'); s.src = 'https://www.youtube.com/iframe_api'; document.head.appendChild(s); })();
        var player = null, tickTimer = null;
        // ★ currentVid/초기 재생상태를 DB 값으로
        var currentVid = (INIT.ytId && INIT.ytId.length ? INIT.ytId : 'dQw4w9WgXcQ');
        var INIT_POS = INIT.pos || 0;
        var INIT_PAUS = INIT.paus || 'Y'; // 'Y'|'N'

        window.onYouTubeIframeAPIReady = function () {
          var pv = { rel: 0, modestbranding: 1, playsinline: 1, origin: location.origin };
          if (role === 'member') { pv.controls = 0; pv.disablekb = 1; pv.fs = 0; pv.iv_load_policy = 3; }
          player = new YT.Player('player', { videoId: currentVid, playerVars: pv, events: { onReady: onReady, onStateChange: onState } });
        };

        // ★ 재생상태 DB 저장(1초 쓰로틀)
        function savePlaybackToDB(data) {
          data = Object.assign({ ytId: currentVid }, data); // 항상 영상ID 포함
          if (!ROOM_ID || !window.$) return;
          var now = Date.now();
          if (!savePlaybackToDB._last) savePlaybackToDB._last = 0;
          if (now - savePlaybackToDB._last < 1000) return; // 쓰로틀
          savePlaybackToDB._last = now;
          $.post(API_BASE + '/playback', data);
        }

        function onReady() {
          // 멤버는 자동재생 제한 해제용 버튼 표시
          if (role === 'member') {
            var b = g('startBtn');
            b.style.display = 'block';
            b.onclick = function () {
              try {
                player.playVideo();
                setTimeout(() => player.pauseVideo(), 200); // 권한 언락만 하고 멈춤
                b.remove();
              } catch (e) { }
            };
          }

          // 공통 초기화
          setupWS();
          bindControls();
          initWhiteboard();
          refreshMessages();
          toggleWBButton();

          // ★ 호스트만 DB 초기 상태 반영
          if (role === 'host') {
            try {
              if (INIT_POS > 0) player.seekTo(INIT_POS, true);
              if (INIT_PAUS === 'Y') player.pauseVideo(); else player.playVideo();
            } catch (e) { }
          }

          // ★ 멤버만 폴링 보정 시작 (WS가 열려있으면 폴링은 자동으로 쉬게 설계함)
          if (window.$ && role === 'member') {
            startMemberPolling();
          }
        }


        function onState(e) {
          if (role !== 'host') return;
          var cur = Math.floor(player.getCurrentTime() || 0);
          if (e.data === YT.PlayerState.PLAYING) {
            send({ kind: 'ctrl', type: 'PLAY', at: cur, id: currentVid });
            // ★ DB 반영
            savePlaybackToDB({ positionSec: cur, isPaused: 'N' });
            if (!tickTimer) { tickTimer = setInterval(() => { try { send({ kind: 'tick', at: Math.floor(player.getCurrentTime() || 0), id: currentVid }); } catch (_) { } }, 2000); }
          }
          if (e.data === YT.PlayerState.PAUSED) {
            send({ kind: 'ctrl', type: 'PAUSE', at: cur, id: currentVid });
            // ★ DB 반영
            savePlaybackToDB({ positionSec: cur, isPaused: 'Y' });
            if (tickTimer) { clearInterval(tickTimer); tickTimer = null; }
          }
        }

        function disableSessionUI() {
          // 플레이어 정지
          try { player.pauseVideo(); } catch (_) { }
          // 컨트롤 잠그기
          document.querySelectorAll('.hostOnly, .memberOnly, .chatForm button, .chatForm input')
            .forEach(el => { el.disabled = true; el.classList.add('disabled'); });

          // 안내 배너 붙이기
          if (!document.getElementById('sessionEndBanner')) {
            var banner = document.createElement('div');
            banner.id = 'sessionEndBanner';
            banner.style.cssText = 'margin-top:8px;padding:10px;border-radius:8px;background:#fee2e2;color:#991b1b;border:1px solid #fecaca;';
            banner.textContent = '이 세션은 종료되었습니다. (읽기 전용)';
            g('playerWrap').parentElement.insertBefore(banner, g('playerWrap').nextSibling);
          }

          // 화이트보드 닫기
          wbOpen = false;
          updateWBVisibility();
        }

        function endSessionBroadcast() {
          // 모든 클라이언트에 종료 알림
          send({ kind: 'ctrl', type: 'END' });
          // 채팅에 시스템 메시지
          appendChat({ kind: 'chat', name: 'System', text: '세션이 종료되었습니다.', ts: Date.now() });
          if (window.$) $.post(API_BASE + '/messages', { msgType: 'SYSTEM', content: '세션 종료' });
        }


        // ===== Controls / Chat / Memo =====
        function bindControls() {
          g('apply').onclick = function () {
            if (role !== 'host') return;
            var id = pickId(g('url').value);
            if (!id) return alert('유효한 YouTube 링크가 아닙니다.');
            currentVid = id; player.loadVideoById(id);
            send({ kind: 'ctrl', type: 'LOAD', id: id });
            // ★ DB 반영 (영상 교체 시 위치 0, 일시정지)
            savePlaybackToDB({ ytId: id, positionSec: 0, isPaused: 'Y' });
          };
          g('wbToggle').onclick = function () {
            // 호스트이거나, 멤버라도 그리기 권한이 있어야 토글 허용
            if (!(role === 'host' || canDraw)) return;
            wbOpen = !wbOpen;
            updateWBVisibility();
            this.textContent = wbOpen ? '화이트보드 닫기' : '화이트보드 열기';
            send({ kind: 'draw', type: 'WB_TOGGLE', open: wbOpen });
          };
          g('play').onclick = () => { if (role === 'host') player.playVideo(); };
          g('pause').onclick = () => { if (role === 'host') player.pauseVideo(); };
          // 강의 종료 (호스트 전용)
          g('end').onclick = function () {
            if (role !== 'host') return;
            if (!confirm('정말 세션(강의)을 종료할까요? 모든 참여자의 화면이 잠깁니다.')) return;

            // 1) 현재 위치 저장 + 일시정지 상태로 DB 반영
            var cur = Math.floor(player?.getCurrentTime?.() || 0);
            try { player.pauseVideo(); } catch (_) { }
            savePlaybackToDB({ positionSec: cur, isPaused: 'Y' });

            // 2) 종료 방송
            endSessionBroadcast();

            // 3) 로컬 UI 잠금
            disableSessionUI();
          };

          g('b10').onclick = () => { if (role === 'host') seek(-10); };
          g('f10').onclick = () => { if (role === 'host') seek(+10); };

          // Whiteboard toggle
          g('wbToggle').onclick = function () {
            if (role !== 'host') return;
            wbOpen = !wbOpen;
            updateWBVisibility();
            this.textContent = wbOpen ? '화이트보드 닫기' : '화이트보드 열기';
            send({ kind: 'draw', type: 'WB_TOGGLE', open: wbOpen });
          };

          // Chat (text)
          g('chatSend').onclick = sendChat;
          g('chatInput').addEventListener('keydown', e => { if (e.key === 'Enter') sendChat(); });

          // Chat (+) image send
          var chatFile = g('chatImgFile');
          g('chatPlus').onclick = function () {
            if (role !== 'host' && !canShareImage) {
              send({ kind: 'chat', name, sub: 'PERM_REQ_IMG', ts: Date.now() });
              appendChat({ kind: 'chat', name: 'System', text: '이미지 권한 요청을 보냈습니다.', ts: Date.now() });
              return;
            }
            chatFile.click();
          };
          chatFile.onchange = function (e) {
            var f = e.target.files && e.target.files[0]; if (!f) return;
            if (!/^image\//.test(f.type)) return alert('이미지 파일만 가능합니다.');
            shrinkImage(f, 1280, 0.85, function (data) {
              var msg = { kind: 'chat', name, img: data, ts: Date.now() };
              appendChat(msg); send(msg);
              chatFile.value = '';
              // DB 이미지 저장
              if (window.$) {
                $.ajax({
                  url: API_BASE + '/messages',
                  type: 'POST',
                  contentType: 'application/json',
                  data: JSON.stringify({ msgType: 'IMAGE', content: data })
                });
              }
            });
          };

          g('memoSend').onclick = saveMemoLocal;
          g('memoInput').addEventListener('keydown', e => { if (e.key === 'Enter') saveMemoLocal(); });
        }

        function seek(d) {
          var t = Math.max(0, (player ? player.getCurrentTime() : 0) + d);
          player.seekTo(t, true);
          send({ kind: 'ctrl', type: 'SEEK', to: Math.floor(t), id: currentVid });
          // ★ DB 반영(재생/일시정지 상태는 그대로 유지)
          savePlaybackToDB({ positionSec: Math.floor(t) });
        }

        function pickId(u) {
          try {
            var x = new URL(u, location.origin);
            if (x.hostname.indexOf('youtu.be') > -1) return x.pathname.slice(1);
            var v = x.searchParams.get('v'); if (v) return v;
            var m = ('' + u).match(/embed\/([\w-]{6,})/); return m ? m[1] : null;
          } catch (e) { return null; }
        }

        // ===== WebSocket =====
        var ws = null;
        function wsUrl() {
          var sch = (location.protocol === 'https:' ? 'wss' : 'ws');
          return sch + '://' + location.host + ctx + '/ws/sync'
            + '?room=' + encodeURIComponent(room)
            + '&name=' + encodeURIComponent(name)
            + '&role=' + encodeURIComponent(role);
        }
        function setupWS() {
          ws = new WebSocket(wsUrl());
          ws.onopen = () => { g('st').textContent = '연결됨'; send({ kind: 'admin', type: 'STATE_REQ' }); };
          ws.onclose = () => { g('st').textContent = '끊김'; };
          ws.onerror = () => { g('st').textContent = '에러'; };
          ws.onmessage = (ev) => { try { route(JSON.parse(ev.data)); } catch (e) { } };
        }
        function send(o) { if (ws && ws.readyState === 1) ws.send(JSON.stringify(o)); }
        function route(m) {
          switch (m.kind) {
            case 'ctrl': return handleCtrl(m);
            case 'tick': return handleTick(m);
            case 'chat': return handleChat(m);
            case 'perm': return handlePerm(m);
            case 'draw': return handleDraw(m);
          }
        }

        // ---- CTRL/TICK ----
        function handleCtrl(m) {
          // 공통 END
          if (m.type === 'END') {
            disableSessionUI();
            return;
          }

          if (m.type === 'SNAPSHOT') {
            lastHostSignal = Date.now();

            if (role === 'host') {
              // 호스트는 '초기 진입' 시에만 DB 스냅샷 반영 (프로젝트 기본값에 맞춰 조건 조정 가능)
              var isUninitialized = !currentVid || currentVid === 'dQw4w9WgXcQ';
              if (isUninitialized) {
                if (m.id) { currentVid = m.id; player?.loadVideoById?.(m.id, m.at || 0); }
                if (typeof m.at === 'number') { try { player.seekTo(m.at, true); } catch (_) { } }
                if (m.playing) { try { player.playVideo(); } catch (_) { } } else { try { player.pauseVideo(); } catch (_) { } }
                if (typeof m.wbOpen === 'boolean') { wbOpen = m.wbOpen; g('wbToggle').textContent = wbOpen ? '화이트보드 닫기' : '화이트보드 열기'; updateWBVisibility(); toggleWBButton(); }
              }
              return;
            }

            // 멤버는 항상 반영
            if (m.id) { currentVid = m.id; if (player?.loadVideoById) player.loadVideoById(m.id); }
            if (typeof m.at === 'number') { try { player.seekTo(m.at, true); } catch (_) { } }
            if (m.playing) { try { player.playVideo(); } catch (_) { } } else { try { player.pauseVideo(); } catch (_) { } }
            if (typeof m.wbOpen === 'boolean') { wbOpen = m.wbOpen; updateWBVisibility(); }
            return;
          }

          // 호스트는 이후 외부 제어 무시
          if (role === 'host') return;

          if (m.type === 'LOAD' && m.id) {
            lastHostSignal = Date.now();
            currentVid = m.id;
            player?.loadVideoById?.(m.id);
            return;
          }

          if (m.type === 'PLAY') {
            lastHostSignal = Date.now();
            const at = (typeof m.at === 'number') ? m.at : null;
            if (at != null) {
              const cur = player?.getCurrentTime?.() || 0;
              const drift = Math.abs(cur - at);
              if (drift > 0.9) { player.seekTo(at, true); lastLocalAdjust = Date.now(); }
            }
            player.playVideo();
            return;
          }

          if (m.type === 'PAUSE') {
            lastHostSignal = Date.now();
            const at = (typeof m.at === 'number') ? m.at : null;
            if (at != null) {
              const cur = player?.getCurrentTime?.() || 0;
              const drift = Math.abs(cur - at);
              if (drift > 0.9) { player.seekTo(at, true); lastLocalAdjust = Date.now(); }
            }
            player.pauseVideo();
            return;
          }

          if (m.type === 'SEEK') {
            lastHostSignal = Date.now();
            player.seekTo(m.to || 0, true);
            lastLocalAdjust = Date.now();
            return;
          }
        }

        function handleTick(m) {
          if (role === 'host') return;
          lastHostSignal = Date.now();
          if (m.id && m.id !== currentVid) return;

          // 플레이 중일 때만 따라감
          const state = player?.getPlayerState?.();
          if (state !== YT.PlayerState.PLAYING) return;

          // 방금 내가 조정했다면 쿨다운 동안 무시
          if (Date.now() - lastLocalAdjust < adjustCooldownMs) return;

          const local = player?.getCurrentTime?.() || 0;
          const drift = (m.at || 0) - local;
          if (Math.abs(drift) > 1.2) {
            player.seekTo(m.at || 0, true);
            lastLocalAdjust = Date.now();
          }
        }

        // ---- Chat ----
        function sendChat() {
          var v = (g('chatInput').value || "").trim(); if (!v) return;
          var msg = { kind: 'chat', name, text: v, ts: Date.now() };
          appendChat(msg); g('chatInput').value = ''; send(msg);
          // DB 저장 + 목록 갱신
          if (window.$) {
            $.ajax({
              url: API_BASE + '/messages',
              type: 'POST',
              contentType: 'application/json',
              data: JSON.stringify({ msgType: 'TEXT', content: v }),
              success: function () { refreshMessages(); }
            });
          }
        }
        function appendChat(m) {
          var el = g('chat'); var t = new Date(m.ts || Date.now());
          var hh = ('0' + t.getHours()).slice(-2), mm = ('0' + t.getMinutes()).slice(-2);
          var me = (m.name === name);
          var p = document.createElement('div');
          p.className = 'chatItem ' + (me ? 'mine' : 'other');

          if (m.sub === 'PERM_REQ_DRAW' && role === 'host') {
            p.innerHTML = '<div class="meta">' + escapeHtml(m.name) + ' [' + hh + ':' + mm + ']</div>'
              + '<div>그리기 권한 요청</div>'
              + '<div class="permBtns">'
              + '<button data-act="DRAW_GRANT" data-to="' + escapeHtml(m.name) + '">수락</button>'
              + '<button data-act="DRAW_DENY"  data-to="' + escapeHtml(m.name) + '">거절</button>'
              + '</div>';
            setTimeout(bindPermButtons, 0, p);
          } else if (m.sub === 'PERM_REQ_IMG' && role === 'host') {
            p.innerHTML = '<div class="meta">' + escapeHtml(m.name) + ' [' + hh + ':' + mm + ']</div>'
              + '<div>이미지 공유 권한 요청</div>'
              + '<div class="permBtns">'
              + '<button data-act="IMG_GRANT" data-to="' + escapeHtml(m.name) + '">수락</button>'
              + '<button data-act="IMG_DENY"  data-to="' + escapeHtml(m.name) + '">거절</button>'
              + '</div>';
            setTimeout(bindPermButtons, 0, p);
          } else {
            var meta = '<div class="meta">' + (me ? '나' : escapeHtml(m.name || '')) + ' [' + hh + ':' + mm + ']</div>';
            var text = m.text ? '<div>' + escapeHtml(m.text || '') + '</div>' : '';
            var img = m.img ? '<div class="imgWrap"><img src="' + m.img + '" alt="img"/></div>' : '';
            p.innerHTML = meta + text + img;
          }

          el.appendChild(p); el.scrollTop = el.scrollHeight;
        }
        function bindPermButtons(p) {
          p.querySelectorAll('.permBtns button').forEach(function (btn) {
            btn.onclick = function () {
              var to = this.getAttribute('data-to');
              var act = this.getAttribute('data-act');
              send({ kind: 'perm', type: act, to });
              send({ kind: 'chat', name: 'System', text: '[' + to + '] ' + act.replace('_', ' '), ts: Date.now() });
            };
          });
        }
        function handleChat(m) { appendChat(m); }

        // ---- Permission 결과 ----
        function handlePerm(m) {
          if (m.to !== name) return;
          if (m.type === 'DRAW_GRANT') { canDraw = true; updateWBVisibility(); toggleWBButton(); toast('그리기 권한이 허용되었습니다.'); }
          if (m.type === 'DRAW_DENY') { canDraw = false; updateWBVisibility(); toggleWBButton(); toast('그리기 권한이 거절되었습니다.'); }
          if (m.type === 'IMG_GRANT') { canShareImage = true; toast('이미지 공유 권한이 허용되었습니다.'); }
          if (m.type === 'IMG_DENY') { canShareImage = false; toast('이미지 공유 권한이 거절되었습니다.'); }
        }
        function toast(t) { try { console.log(t); } catch (e) { } }

        // ===== Notes =====
        function saveMemoLocal() {
          var v = (g('memoInput').value || "").trim(); if (!v) return;
          var at = Math.floor(player?.getCurrentTime?.() || 0);
          var el = g('memo'); var t = new Date();
          var hh = ('0' + t.getHours()).slice(-2), mm = ('0' + t.getMinutes()).slice(-2);
          var p = document.createElement('div'); p.className = 'memoItem';
          p.innerHTML = '<div class="meta">[' + hh + ':' + mm + '] @' + at + 's</div><div>' + escapeHtml(v) + '</div>';
          el.appendChild(p); el.scrollTop = el.scrollHeight;
          g('memoInput').value = '';
          // DB 저장 + 목록 갱신
          if (window.$) {
            $.ajax({
              url: API_BASE + '/messages',
              type: 'POST',
              contentType: 'application/json',
              data: JSON.stringify({ msgType: 'MEMO', content: v, atSec: at }),
              success: function () { refreshMessages(); }
            });
          }
        }

        /* ★ DB 메시지 로딩/렌더 */
        function refreshMessages() {
          if (!window.$) return;
          $.getJSON(API_BASE + '/messages', function (list) {
            g('chat').innerHTML = '';
            g('memo').innerHTML = '';
            (list || []).forEach(function (m) {
              if (m.msgType === 'TEXT' || m.msgType === 'IMAGE' || m.msgType === 'SYSTEM') {
                appendChatFromDB(m);
              } else if (m.msgType === 'MEMO') {
                appendMemoFromDB(m);
              }
            });
            g('chat').scrollTop = g('chat').scrollHeight;
            g('memo').scrollTop = g('memo').scrollHeight;
          });
        }
        function appendChatFromDB(m) {
          var t = new Date(m.createdAt || Date.now());
          var hh = ('0' + t.getHours()).slice(-2), mm = ('0' + t.getMinutes()).slice(-2);
          var p = document.createElement('div');

          var isMine = (meId && m.senderId === meId); // 내 글 여부
          p.className = 'chatItem ' + (isMine ? 'mine' : 'other');

          var contentHtml = '';
          if (m.msgType === 'IMAGE') {
            contentHtml = '<div class="imgWrap"><img src="' + (m.content || '') + '" alt="img"/></div>';
          } else {
            contentHtml = '<div>' + escapeHtml(m.content || '') + '</div>';
          }

          p.innerHTML = '<div class="meta">'
            + (isMine ? '나' : escapeHtml(m.senderId || '')) + ' [' + hh + ':' + mm + ']'
            + '</div>'
            + contentHtml;

          g('chat').appendChild(p);
        }
        function appendMemoFromDB(m) {
          //내 메모만 보이게 필터
          if (!meId || m.senderId !== meId) return;

          var t = new Date(m.createdAt || Date.now());
          var hh = ('0' + t.getHours()).slice(-2), mm = ('0' + t.getMinutes()).slice(-2);
          var p = document.createElement('div');
          p.className = 'memoItem';
          var at = (m.atSec != null ? ' @' + m.atSec + 's' : '');
          p.innerHTML = '<div class="meta">[' + hh + ':' + mm + ']' + at + '</div>'
            + '<div>' + escapeHtml(m.content || '') + '</div>';
          g('memo').appendChild(p);
        }

        /* ===== 유틸: 이미지 리사이즈 (채팅 이미지 전송에서 사용) ===== */
        function shrinkImage(file, maxDim, quality, cb) {
          const img = new Image(), fr = new FileReader();
          fr.onload = (e) => { img.src = e.target.result; };
          img.onload = () => {
            let w = img.width, h = img.height, scale = Math.min(1, maxDim / Math.max(w, h));
            let cw = Math.round(w * scale), ch = Math.round(h * scale);
            const cvs = document.createElement('canvas'); cvs.width = cw; cvs.height = ch;
            const ctx = cvs.getContext('2d'); ctx.drawImage(img, 0, 0, cw, ch);
            cb(cvs.toDataURL('image/jpeg', quality));
          };
          fr.readAsDataURL(file);
        }

        /* ===== Whiteboard over Player (DPR 보정 반영) ===== */
        var wb = { canvas: null, ctx: null, tool: 'pen', color: '#ff4757', size: 3, drawing: false, history: [], redo: [], myStroke: null, cssW: 0, cssH: 0, dpr: 1 };

        function initWhiteboard() {
          wb.canvas = g('wbCanvas'); wb.ctx = wb.canvas.getContext('2d');
          setWBInputsEnabled(false);

          var req = g('reqDraw'); if (req) req.onclick = function () {
            if (canDraw) return alert('이미 권한이 있습니다.');
            send({ kind: 'chat', name, sub: 'PERM_REQ_DRAW', ts: Date.now() });
            appendChat({ kind: 'chat', name: 'System', text: '그리기 권한 요청을 보냈습니다.', ts: Date.now() });
          };

          bindWBToolbar(); attachWBPointerHandlers();
          window.addEventListener('resize', debounce(resizeWB, 150));
          resizeWB();
          updateWBVisibility();
          toggleWBButton();
        }

        function setWBInputsEnabled(enabled) {
          ['wbPen', 'wbColor', 'wbSize', 'wbUndo', 'wbRedo', 'wbClear'].forEach(id => {
            let el = g(id); if (el) el.disabled = !enabled;
          });
          wb.canvas.style.pointerEvents = enabled ? 'auto' : 'none';
        }

        function updateWBVisibility() {
          const visible = wbOpen;
          wb.canvas.classList.toggle('hidden', !visible);
          const enableDraw = wbOpen && canDraw;
          setWBInputsEnabled(enableDraw);
          wb.canvas.style.pointerEvents = enableDraw ? 'auto' : 'none';
          if (visible) resizeWB();
        }

        function bindWBToolbar() {
          g('wbPen').onclick = () => { wb.tool = 'pen'; };
          g('wbColor').oninput = (e) => { wb.color = e.target.value; };
          g('wbSize').oninput = (e) => { wb.size = +e.target.value; };
          g('wbUndo').onclick = () => { if (!(wbOpen && canDraw) || !wb.history.length) return; wb.redo.push(wb.history.pop()); redrawWB(); send({ kind: 'draw', type: 'UNDO' }); };
          g('wbRedo').onclick = () => { if (!(wbOpen && canDraw) || !wb.redo.length) return; wb.history.push(wb.redo.pop()); redrawWB(); send({ kind: 'draw', type: 'REDO' }); };
          g('wbClear').onclick = () => { clearWB(); send({ kind: 'draw', type: 'CLEAR' }); };
        }

        function attachWBPointerHandlers() {
          wb.canvas.addEventListener('mousedown', onWBDown);
          window.addEventListener('mousemove', onWBMove);
          window.addEventListener('mouseup', onWBUp);
          wb.canvas.addEventListener('touchstart', onWBDown, { passive: false });
          window.addEventListener('touchmove', onWBMove, { passive: false });
          window.addEventListener('touchend', onWBUp);
        }

        function canvasRect() { var r = wb.canvas.getBoundingClientRect(); return { left: r.left, top: r.top, w: r.width, h: r.height }; }
        function eventPoint(e) {
          var r = canvasRect(); var x, y;
          if (e.touches && e.touches[0]) { x = e.touches[0].clientX - r.left; y = e.touches[0].clientY - r.top; }
          else { x = e.clientX - r.left; y = e.clientY - r.top; }
          return { nx: Math.max(0, Math.min(1, x / r.w)), ny: Math.max(0, Math.min(1, y / r.h)) };
        }

        function onWBDown(e) {
          if (!(wbOpen && canDraw)) return; e.preventDefault();
          wb.drawing = true; var p = eventPoint(e);
          wb.myStroke = { tool: wb.tool, color: wb.color, size: wb.size, points: [p] };
        }
        function onWBMove(e) {
          if (!(wbOpen && canDraw) || !wb.drawing) return; e.preventDefault();
          var p = eventPoint(e);
          wb.myStroke.points.push(p);
          redrawWB(); drawStroke(wb.myStroke);
        }
        function onWBUp(e) {
          if (!(wbOpen && canDraw) || !wb.drawing) return; e.preventDefault();
          wb.drawing = false;
          if (wb.myStroke) {
            wb.history.push(wb.myStroke); wb.redo = [];
            send({ kind: 'draw', type: 'PATH', stroke: wb.myStroke });
            wb.myStroke = null;
          }
          redrawWB();
        }

        function drawStroke(st) {
          var ctx = wb.ctx, w = wb.cssW, h = wb.cssH;
          ctx.save(); ctx.lineCap = 'round'; ctx.lineJoin = 'round';
          ctx.strokeStyle = st.color || '#ff4757'; ctx.lineWidth = (st.size || 3);
          var pts = st.points || []; if (pts.length > 1) { ctx.beginPath(); ctx.moveTo(pts[0].nx * w, pts[0].ny * h); for (var i = 1; i < pts.length; i++) ctx.lineTo(pts[i].nx * w, pts[i].ny * h); ctx.stroke(); }
          ctx.restore();
        }
        function redrawWB() {
          hardClearCanvas();
          for (var i = 0; i < wb.history.length; i++) drawStroke(wb.history[i]);
        }
        function clearWB() {
          wb.history = []; wb.redo = [];
          hardClearCanvas();
        }
        function resizeWB() {
          var box = g('playerWrap');
          var rect = box.getBoundingClientRect();
          var dpr = window.devicePixelRatio || 1;

          wb.cssW = rect.width; wb.cssH = rect.height; wb.dpr = dpr;
          wb.canvas.width = Math.round(rect.width * dpr);
          wb.canvas.height = Math.round(rect.height * dpr);

          wb.ctx.setTransform(dpr, 0, 0, dpr, 0, 0);   // 논리좌표 = CSS 픽셀
          hardClearCanvas();                      // 🔑 버퍼 전체 초기화
          redrawWB();
        }

        function handleDraw(m) {
          if (m.type === 'CLEAR') { clearWB(); return; }
          if (m.type === 'WB_TOGGLE') { wbOpen = !!m.open; if (role === 'host') { g('wbToggle').textContent = wbOpen ? '화이트보드 닫기' : '화이트보드 열기'; } updateWBVisibility(); toggleWBButton(); return; }
          if (m.type === 'UNDO') { if (wb.history.length) { wb.redo.push(wb.history.pop()); redrawWB(); } return; }
          if (m.type === 'REDO') { if (wb.redo.length) { wb.history.push(wb.redo.pop()); redrawWB(); } return; }
          if (m.type === 'PATH' && m.stroke && m.stroke.points && m.stroke.points.length) { if (wbOpen) { wb.history.push(m.stroke); redrawWB(); } }
        }

        function hardClearCanvas() {
          const c = wb.canvas, ctx = wb.ctx;
          ctx.save();
          ctx.setTransform(1, 0, 0, 1, 0, 0);          // 🔑 변환 초기화(픽셀 좌표)
          ctx.clearRect(0, 0, c.width, c.height);    // 버퍼 전체 지우기
          ctx.restore();
        }

        /*======= 이미지 확대 추가 =====*/
        // ===== Robust Chat image lightbox (auto-create modal + lazy refs) =====
        (function () {
          function q(id) { return document.getElementById(id); }

          // 모달이 없으면 자동 생성
          function ensureModal() {
            if (q('imgModal')) return;
            var tpl = ''
              + '<div id="imgModal" class="imgModal hidden" aria-modal="true" role="dialog">'
              + '  <div class="imgModal__backdrop" id="imgBackdrop"></div>'
              + '  <div class="imgModal__body">'
              + '    <button id="imgClose" class="imgModal__close" aria-label="닫기">×</button>'
              + '    <img id="imgView" alt="image preview"/>'
              + '    <div class="imgModal__toolbar">'
              + '      <button id="zoomOut" type="button">-</button>'
              + '      <span id="zoomVal">100%</span>'
              + '      <button id="zoomIn" type="button">+</button>'
              + '      <button id="zoomReset" type="button">맞춤</button>'
              + '    </div>'
              + '  </div>'
              + '</div>';
            document.body.insertAdjacentHTML('beforeend', tpl);
          }

          ensureModal();

          // 참조는 "늦게" 가져오도록 함수화
          var modal, backdrop, btnClose, view, zoomVal, btnIn, btnOut, btnReset, stage;
          function refreshRefs() {
            modal = q('imgModal');
            backdrop = q('imgBackdrop');
            btnClose = q('imgClose');
            view = q('imgView');
            zoomVal = q('zoomVal');
            btnIn = q('zoomIn');
            btnOut = q('zoomOut');
            btnReset = q('zoomReset');
            if (!stage) { stage = document.createElement('div'); stage.id = 'imgStage'; }
          }
          refreshRefs();

          var ready = false, zoom = 1, fitZ = 1, tx = 0, ty = 0, dragging = false, sx = 0, sy = 0;

          // stage 감싸기 (view가 아직 null이면 재시도)
          function ensureStage() {
            if (!view) { refreshRefs(); }
            if (!view) return false; // 여전히 없으면 포기
            if (view.parentElement && view.parentElement.id === 'imgStage') return true;
            var parent = view.parentElement;
            if (!parent) { refreshRefs(); parent = view.parentElement; }
            if (!parent) return false;
            parent.insertBefore(stage, view);
            stage.appendChild(view);
            return true;
          }

          function applyTransform() {
            stage.style.transform = 'translate3d(' + tx + 'px,' + ty + 'px,0) scale(' + zoom + ')';
            if (zoomVal) zoomVal.textContent = Math.round(zoom * 100) + '%';
          }
          function computeFit() {
            var body = modal.querySelector('.imgModal__body');
            if (!body || !view) { fitZ = 1; return; }
            var availW = body.clientWidth;
            var toolbarH = (modal.querySelector('.imgModal__toolbar')?.offsetHeight || 0) + 8;
            var availH = body.clientHeight - toolbarH;
            var natW = view.naturalWidth || view.width || 1;
            var natH = view.naturalHeight || view.height || 1;
            fitZ = Math.min(availW / natW, availH / natH);
            if (!isFinite(fitZ) || fitZ <= 0) fitZ = 1;
          }
          function fitReset() { computeFit(); zoom = fitZ; tx = 0; ty = 0; applyTransform(); ready = true; }
          function setZoom(nz) { zoom = Math.max(0.2, Math.min(6, nz)); applyTransform(); }

          function openModal(src) {
            ensureModal(); refreshRefs();
            if (!ensureStage()) return;       // 안전장치
            ready = false;
            view.onload = function () { fitReset(); };
            view.src = src;
            if (view.complete) fitReset();    // 캐시 로드 대비
            modal.classList.remove('hidden');
            document.addEventListener('keydown', onKeydown);
          }
          function closeModal() {
            refreshRefs();
            if (!modal) return;
            modal.classList.add('hidden');
            document.removeEventListener('keydown', onKeydown);
          }
          function onKeydown(e) { if (e.key === 'Escape') closeModal(); }

          // 채팅 이미지 클릭 → 모달 오픈 (위임)
          var chatBox = q('chat');
          if (chatBox) {
            chatBox.addEventListener('click', function (e) {
              var img = e.target.closest && e.target.closest('.imgWrap img');
              if (!img) return;
              openModal(img.src);
            });
          }

          // 닫기
          document.addEventListener('click', function (e) {
            if (e.target && (e.target.id === 'imgBackdrop' || e.target.id === 'imgClose')) closeModal();
          });

          // 줌 컨트롤
          document.addEventListener('click', function (e) {
            if (!modal || modal.classList.contains('hidden')) return;
            if (e.target && e.target.id === 'zoomIn') setZoom(zoom + 0.2);
            if (e.target && e.target.id === 'zoomOut') setZoom(zoom - 0.2);
            if (e.target && e.target.id === 'zoomReset') fitReset();
          });

          // 더블클릭: fit ↔ 2x
          document.addEventListener('dblclick', function (e) {
            if (!stage || !ready) return;
            if (!modal || modal.classList.contains('hidden')) return;
            if (!stage.contains(e.target)) return;
            var target = (zoom < fitZ * 1.6) ? (fitZ * 2) : fitZ;
            setZoom(target); tx = 0; ty = 0; applyTransform();
          });

          // 휠 줌
          document.addEventListener('wheel', function (e) {
            if (!modal || modal.classList.contains('hidden')) return;
            if (!stage || !stage.contains(e.target)) return;
            e.preventDefault();
            setZoom(zoom + (e.deltaY < 0 ? 0.15 : -0.15));
          }, { passive: false });

          // 드래그 이동
          document.addEventListener('mousedown', function (e) {
            if (!modal || modal.classList.contains('hidden')) return;
            if (!stage || !stage.contains(e.target)) return;
            e.preventDefault();
            dragging = true; sx = e.clientX; sy = e.clientY; stage.classList.add('grabbing');
          });
          window.addEventListener('mousemove', function (e) {
            if (!dragging) return;
            tx += (e.clientX - sx); ty += (e.clientY - sy);
            sx = e.clientX; sy = e.clientY; applyTransform();
          });
          window.addEventListener('mouseup', function () {
            dragging = false; stage.classList.remove('grabbing');
          });

          // 터치 이동
          document.addEventListener('touchstart', function (e) {
            if (!modal || modal.classList.contains('hidden')) return;
            if (!stage || !stage.contains(e.target)) return;
            if (e.touches.length !== 1) return;
            var t = e.touches[0]; dragging = true; sx = t.clientX; sy = t.clientY;
          }, { passive: true });
          window.addEventListener('touchmove', function (e) {
            if (!dragging || e.touches?.length !== 1) return;
            var t = e.touches[0]; tx += (t.clientX - sx); ty += (t.clientY - sy);
            sx = t.clientX; sy = t.clientY; applyTransform();
          }, { passive: true });
          window.addEventListener('touchend', function () { dragging = false; });

          // 창 크기 변경 시 재맞춤
          window.addEventListener('resize', function () {
            if (!modal || modal.classList.contains('hidden')) return;
            fitReset();
          });
        })();

        //강의 종료시 open에서 close로 변경
        (function () {
          const role = "<c:out value='${role}'/>";
          const roomId = "<c:out value='${room}'/>";
          // JSP에서 컨텍스트패스 안전하게 문자열로 주입
          const ctx = "<c:out value='${pageContext.request.contextPath}'/>";

          const endBtn = document.getElementById("end");
          if (!endBtn) return;

          endBtn.addEventListener("click", async function () {
            if (role !== "host") {
              alert("호스트만 종료할 수 있습니다.");
              return;
            }
            if (!confirm("강의를 종료하고 방을 닫을까요?")) return;

            const url = ctx + "/rooms/close/" + roomId;

            try {
              const res = await fetch(url, {
                method: "POST",
                headers: {
                  // Spring Security CSRF를 쓰면 아래 두 줄(주석 해제)도 필요합니다.
                  // "<c:out value='${_csrf.headerName}'/>": "<c:out value='${_csrf.token}'/>"
                  "Accept": "application/json"
                }
              });

              if (!res.ok) {
                const text = await res.text().catch(() => "");
                console.error("closeRoom HTTP error", res.status, text);
                alert("종료 요청이 거부되었습니다. (HTTP " + res.status + ")");
                return;
              }

              // 응답이 JSON이 아닐 수도 있어 방어코드
              let data = {};
              try { data = await res.json(); } catch (_) { }

              if (data.ok === true || Object.keys(data).length === 0) {
                alert("방이 닫혔습니다.");
                location.href = ctx + "/rooms";
              } else {
                alert(data.msg || "종료 처리에 실패했습니다.");
              }
            } catch (e) {
              console.error("closeRoom fetch error", e);
              alert("네트워크 오류로 종료하지 못했습니다.");
            }
          });
        })();


        function startMemberPolling() {
          setInterval(function () {
            // WS가 살아있으면 폴링으로는 건드리지 않음(이중 보정 방지)
            if (ws && ws.readyState === 1) return;

            // 최근 WS 신호나 로컬 조정 직후면 스킵(튀김 방지)
            if (Date.now() - Math.max(lastHostSignal, lastLocalAdjust) < 1500) return;

            $.getJSON(API_BASE + '/playback', function (pb) {
              if (!pb || !player) return;

              // 영상이 바뀐 경우 즉시 교체
              if (pb.ytId && pb.ytId !== currentVid) {
                currentVid = pb.ytId;
                player.loadVideoById(currentVid, pb.positionSec || 0);
                lastLocalAdjust = Date.now();
                return;
              }

              // 플레이 중일 때만 드리프트 보정 (정지 상태는 건드리지 않음)
              var state = player.getPlayerState();
              if (state === YT.PlayerState.PLAYING) {
                var cur = Math.floor(player.getCurrentTime() || 0);
                var drift = Math.abs(cur - (pb.positionSec || 0));
                if (drift > 2.5) {
                  player.seekTo(pb.positionSec || 0, true);
                  lastLocalAdjust = Date.now();
                }
              }

              // 상태 보정
              if (pb.isPaused === 'Y' && player.getPlayerState() === YT.PlayerState.PLAYING) {
                player.pauseVideo();
              }
              if (pb.isPaused === 'N' && player.getPlayerState() !== YT.PlayerState.PLAYING) {
                try { player.playVideo(); } catch (e) { }
              }
            });
          }, 2000);
        }
        function toggleWBButton() {
          var btn = g('wbToggle');
          if (!btn) return;
          // 호스트이거나, 멤버라도 그리기 권한(canDraw)이 있으면 버튼 노출
          var visible = (role === 'host') || canDraw;
          btn.style.display = visible ? '' : 'none';
          // 현재 상태에 맞춰 라벨 갱신
          btn.textContent = wbOpen ? '화이트보드 닫기' : '화이트보드 열기';
        }

      </script>
      <!-- Image Lightbox Modal -->
      <div id="imgModal" class="imgModal hidden">
        <div class="imgModal__backdrop" id="imgBackdrop"></div>
        <div class="imgModal__body">
          <button id="imgClose" class="imgModal__close">×</button>
          <img id="imgView" alt="image preview" /><!-- ← 이걸 JS가 자동으로 #imgStage로 감쌈 -->
          <div class="imgModal__toolbar">
            <button id="zoomOut" type="button">-</button>
            <span id="zoomVal">100%</span>
            <button id="zoomIn" type="button">+</button>
            <button id="zoomReset" type="button">맞춤</button>
          </div>
        </div>
      </div>
    </body>

    </html>