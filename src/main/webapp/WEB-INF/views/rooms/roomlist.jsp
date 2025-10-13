<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>스터디 방 목록</title>
  <jsp:include page="/WEB-INF/inc/top.jsp" />
  <%-- 만약 top.jsp에서 공통 CSS를 링크하지 않는다면, 아래처럼 직접 링크
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
  --%>
  <style>
    /* 썸네일/플레이스홀더 보조 스타일 */
    .thumb{width:140px;height:80px;object-fit:cover;border-radius:8px;border:1px solid var(--line)}
    .placeholder{
      width:140px;height:80px;display:grid;place-items:center;
      border:1px dashed var(--line);border-radius:8px;color:var(--muted);font-size:12px
    }
    /* 상태 배지 */
    .badge{display:inline-block;padding:2px 8px;border-radius:999px;font-size:12px;border:1px solid var(--line)}
    .badge.open{background:#eafff3;border-color:#b6f0cf;color:#107e49}
    .badge.close{background:#ffeaea;border-color:#f4b4b4;color:#b42318}
    /* 버튼 */
    .btn.enter{ background:var(--accent); color:#fff; border-color:var(--accent) }
    .btn.disabled{background:#e5e7eb;border-color:#e5e7eb;color:#9ca3af;cursor:not-allowed;pointer-events:none}
    /* 셀 비활성(클릭 막기 + 흐림) */
    .cell-disabled{opacity:.6;pointer-events:none}
    /* 레이아웃 */
    .wrap{max-width:1080px;margin:24px auto;padding:0 16px}
    .table{width:100%;border-collapse:collapse;background:var(--card);box-shadow:var(--shadow);border-radius:12px;overflow:hidden}
    .table th,.table td{padding:12px 14px;border-bottom:1px solid var(--line)}
    .table th{background:rgba(0,0,0,.02);text-align:left}
    .pagination{display:flex;gap:8px;justify-content:center;margin:16px 0}
    .page{padding:6px 12px;border:1px solid var(--line);border-radius:8px}
    .page.active{background:var(--accent);border-color:var(--accent);color:#fff}
    .page.disabled{opacity:.5;pointer-events:none}
  </style>
</head>
<body class="rooms-page">

<%-- =========================================
     (선택) 전체 페이지 강제 인증 가드
     로그인 안 되어 있으면 즉시 로그인으로 리다이렉트
     주석 해제해서 사용
========================================= --%>
<%--
<c:if test="${empty sessionScope.login or empty sessionScope.login.memId}">
  <c:redirect url='${pageContext.request.contextPath}/login'/>
</c:if>
--%>

<%-- 공통 플래그/URL 설정 --%>
<c:set var="isLogin"   value="${not empty sessionScope.login and not empty sessionScope.login.memId}"/>
<c:set var="loginUrl"  value="${pageContext.request.contextPath}/loginView"/>

<div class="app">
  <jsp:include page="/WEB-INF/inc/header.jsp"/>
  <jsp:include page="/WEB-INF/inc/sidebar.jsp"/>

  <main class="wrap">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
      <h2>스터디 방 목록</h2>
      <c:choose>
        <c:when test="${isLogin}">
          <!-- 로그인 상태 -->
          <a href="${pageContext.request.contextPath}/rooms/create" class="btn enter">+ 새 방 만들기</a>
        </c:when>
        <c:otherwise>
          <!-- 비로그인 상태: 방 만들기 누르면 로그인으로 -->
          <a href="${loginUrl}" class="btn enter">+ 새 방 만들기</a>
        </c:otherwise>
      </c:choose>
    </div>

    <table class="table">
      <thead>
        <tr>
          <th style="width:140px">썸네일</th>
          <th>제목</th>
          <th>호스트</th>
          <th>상태</th>
          <th style="width:100px">인원수</th>
          <th style="width:160px">생성일</th>
          <th style="width:120px"></th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="room" items="${rooms}">
          <%-- 로그인한 사용자가 이 방의 호스트인지 판단해서 roleParam 설정 (로그인일 때만 의미) --%>
          <c:set var="roleParam" value="member"/>
          <c:if test="${isLogin and sessionScope.login.memId == room.hostMemberId}">
            <c:set var="roleParam" value="host"/>
          </c:if>

          <tr>
            <td>
              <c:choose>
                <c:when test="${not empty room.ytId}">
                  <c:choose>
                    <%-- CLOSE면 링크 제거 + 클릭 막기 --%>
                    <c:when test="${room.status == 'CLOSE'}">
                      <div class="cell-disabled" title="닫힌 방">
                        <img class="thumb"
                             src="https://i.ytimg.com/vi/${room.ytId}/hqdefault.jpg"
                             alt="thumbnail" loading="lazy"
                             onerror="this.style.display='none'; this.nextElementSibling.style.display='grid';"/>
                        <div class="placeholder" style="display:none;">No Image</div>
                      </div>
                    </c:when>
                    <%-- OPEN + 로그인 --%>
                    <c:when test="${isLogin}">
                      <a href="${pageContext.request.contextPath}/sync/page?room=${room.roomId}&role=${roleParam}&name=${sessionScope.login.memNm}" title="입장">
                        <img class="thumb"
                             src="https://i.ytimg.com/vi/${room.ytId}/hqdefault.jpg"
                             alt="thumbnail" loading="lazy"
                             onerror="this.style.display='none'; this.nextElementSibling.style.display='grid';"/>
                        <div class="placeholder" style="display:none;">No Image</div>
                      </a>
                    </c:when>
                    <%-- OPEN + 비로그인 --%>
                    <c:otherwise>
                      <a href="${loginUrl}" title="로그인 필요">
                        <img class="thumb"
                             src="https://i.ytimg.com/vi/${room.ytId}/hqdefault.jpg"
                             alt="thumbnail" loading="lazy"
                             onerror="this.style.display='none'; this.nextElementSibling.style.display='grid';"/>
                        <div class="placeholder" style="display:none;">No Image</div>
                      </a>
                    </c:otherwise>
                  </c:choose>
                </c:when>
                <c:otherwise>
                  <div class="placeholder">No Image</div>
                </c:otherwise>
              </c:choose>
            </td>

            <td>${room.title}</td>
            <td>${room.hostMemberId}</td>

            <td>
              <c:choose>
                <c:when test="${room.status == 'OPEN'}"><span class="badge open">OPEN</span></c:when>
                <c:otherwise><span class="badge close">CLOSE</span></c:otherwise>
              </c:choose>
            </td>

            <%-- 인원수는 고정 6 --%>
            <td>6</td>

            <%-- createdAt 포맷(ISO/LocalDateTime이면 fmt가 바로 안 먹을 수 있어 원문 표기 유지) --%>
            <td>
<%--               <c:out value="${room.createdAt}"/> --%>
			<fmt:formatDate value="${room.createdAt}" pattern="yyyy-MM-dd  HH:mm:ss"/>
            </td>

            <td>
			  <c:choose>
			    <c:when test="${room.status == 'CLOSE'}">
			      <!-- 닫힘: 호스트면 재오픈 버튼, 아니면 비활성 -->
			      <c:choose>
			        <c:when test="${isLogin and sessionScope.login.memId == room.hostMemberId}">
			          <button type="button" class="btn enter btn-reopen" data-room="${room.roomId}">
			            재오픈
			          </button>
			        </c:when>
			        <c:otherwise>
			          <a class="btn disabled" href="javascript:void(0)">닫힘</a>
			        </c:otherwise>
			      </c:choose>
			    </c:when>
			
			    <c:otherwise>
			      <!-- OPEN 상태는 기존 로직 유지 -->
			      <c:choose>
			        <c:when test="${isLogin}">
			          <a class="btn enter"
			             href="${pageContext.request.contextPath}/sync/page?room=${room.roomId}&role=${roleParam}&name=${sessionScope.login.memNm}">
			            <c:choose>
			              <c:when test="${roleParam == 'host'}">입장(Host)</c:when>
			              <c:otherwise>입장</c:otherwise>
			            </c:choose>
			          </a>
			        </c:when>
			        <c:otherwise>
			          <a class="btn enter" href="${loginUrl}">로그인</a>
			        </c:otherwise>
			      </c:choose>
			    </c:otherwise>
			  </c:choose>
			</td>
          </tr>
        </c:forEach>

        <c:if test="${empty rooms}">
          <tr><td colspan="7" style="text-align:center;color:#888">아직 생성된 방이 없습니다.</td></tr>
        </c:if>
      </tbody>
    </table>

    <%-- (선택) 페이지네이션 예시
    <nav class="pagination">
      <a class="page disabled">이전</a>
      <a class="page active">1</a>
      <a class="page">2</a>
      <a class="page">다음</a>
    </nav>
    --%>
  </main>
</div>
<script>
(function(){
  const ctx = "<c:out value='${pageContext.request.contextPath}'/>";

  // 재오픈
  document.addEventListener("click", async (e)=>{
    const btn = e.target.closest(".btn-reopen");
    if(!btn) return;
    const roomId = btn.getAttribute("data-room");
    if(!roomId) return;

    if(!confirm("이 방을 다시 OPEN 상태로 전환할까요?")) return;

    try{
      const res = await fetch(ctx + "/rooms/open/" + roomId, {
        method: "POST",
        headers: {
          "Accept": "application/json"
          // Spring Security CSRF 사용 시 아래 두 줄 주석 해제
          // "<c:out value='${_csrf.headerName}'/>": "<c:out value='${_csrf.token}'/>"
        }
      });
      if(!res.ok){
        const t = await res.text().catch(()=> "");
        alert("재오픈 실패 (HTTP " + res.status + ")");
        console.error("open error", t);
        return;
      }
      // 성공 시 새로고침
      location.reload();
    }catch(err){
      console.error(err);
      alert("네트워크 오류로 재오픈하지 못했습니다.");
    }
  });
})();
</script>

</body>
</html>
