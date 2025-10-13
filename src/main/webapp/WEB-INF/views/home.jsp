<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>StudySync</title>
<jsp:include page="/WEB-INF/inc/top.jsp" />
</head>
<body>
<div class="app" style="grid-template-columns:0 1fr; grid-template-areas:'aside header' 'aside main'">
  <!-- aside 비움(메인은 사이드 없음) -->
  <nav class="side" style="display:none"></nav>

   <jsp:include page="/WEB-INF/inc/header.jsp" />

  <main class="main">
    <div class="container">

      <!-- HERO -->
      <section class="hero">
        <div>
          <h1>유튜브 기반 소규모 스터디 플랫폼, <b>StudySync</b></h1>
          <div class="muted">개인 학습과 실시간 그룹 학습을 한곳에서. 동기화 시청 · 채팅 · 이미지 공유 · 화이트보드까지.</div>
          <div class="cta">
            <c:choose>
			    <c:when test="${empty sessionScope.login}">
			      <a href="<c:url value='/loginView"'>
			                 <c:param name='redirect' value='/rooms'/>
			               </c:url>"
			         class="btn primary">스터디 참여하기</a>
			    </c:when>
			    <c:otherwise>
			      <a href="<c:url value='/rooms'/>" class="btn primary">스터디 참여하기</a>
			    </c:otherwise>
			  </c:choose>
            <a href="<c:url value='https://www.youtube.com/?app=desktop&hl=ko&gl=KR'/>" class="btn ghost">개인 학습 시작</a>
            <c:if test="${not empty sessionScope.login}">
			    <a href="<c:url value='/rooms/create'/>" class="btn">스터디 개설</a>
			  </c:if>
          </div>
        </div>
        <div class="hero-card">
          <div class="hero-stats">
            <div class="stat"><div class="muted">이번 주 학습 시간</div><div class="num"><c:out value="${home.weekHours != null ? home.weekHours : 12}"/>시간</div></div>
            <div class="stat"><div class="muted">활성 스터디</div><div class="num"><c:out value="${home.activeStudies != null ? home.activeStudies : 8}"/>개</div></div>
          </div>
          <div style="margin-top:10px" class="muted">
            <c:choose>
              <c:when test="${empty sessionScope.login}">로그인하고 학습 진도를 저장해보세요.</c:when>
              <c:otherwise><b><c:out value="${sessionScope.login.memNm}"/></b>님, 이어서 학습해볼까요?</c:otherwise>
            </c:choose>
          </div>
        </div>
      </section>

      <!-- 추천 영상 -->
      <section class="section" style="margin-top:20px">
        <h2 class="title">추천 강의 영상</h2>
        <div class="grid-4">
          <c:forEach var="v" items="${recVideos}">
            <a class="card" href="<c:url value='/video/detail'/>?id=${v.id}">
              <div class="video-thumb">
                <img src="https://img.youtube.com/vi/${v.youtubeId}/hqdefault.jpg" alt="${v.title}"/>
                <span class="play">▶ 재생</span>
              </div>
              <div class="inner">
                <div style="font-weight:600"><c:out value="${v.title}"/></div>
                <div class="muted"><c:out value="${v.channel}"/> · <c:out value="${v.duration}"/></div>
              </div>
            </a>
          </c:forEach>
          <c:if test="${empty recVideos}">
  <a class="card" href="https://youtu.be/i5yHkP1jQmo" target="_blank" rel="noopener">
    <div class="video-thumb">
      <img src="https://img.youtube.com/vi/i5yHkP1jQmo/hqdefault.jpg" alt="자료구조 핵심정리"/>
      <span class="play">▶ 재생</span>
    </div>
    <div class="inner">
      <div style="font-weight:600">자료구조 핵심정리 (한 번에 훑기)</div>
      <div class="muted">CS Channel · 32:18</div>
    </div>
  </a>
  <a class="card" href="https://youtu.be/LP1NbL41l4U target="_blank" rel="noopener">
    <div class="video-thumb">
      <img src="https://img.youtube.com/vi/LP1NbL41l4U/hqdefault.jpg" alt="네트워크 기초"/>
      <span class="play">▶ 재생</span>
    </div>
    <div class="inner">
      <div style="font-weight:600">네트워크 기초: TCP/IP 이해</div>
      <div class="muted">네트워크러 · 24:05</div>
    </div>
  </a>
  <a class="card" href="https://youtu.be/kUMe1FH4CHE" target="_blank" rel="noopener">
    <div class="video-thumb">
      <img src="https://img.youtube.com/vi/kUMe1FH4CHE/hqdefault.jpg" alt="HTML/CSS 빠르게 배우기"/>
      <span class="play">▶ 재생</span>
    </div>
    <div class="inner">
      <div style="font-weight:600">HTML/CSS 빠르게 배우기</div>
      <div class="muted">Web School · 41:09</div>
    </div>
  </a>
  <a class="card" href="https://youtu.be/UmnCZ7-9yDY" target="_blank" rel="noopener">
    <div class="video-thumb">
      <img src="https://img.youtube.com/vi/UmnCZ7-9yDY/hqdefault.jpg" alt="자바스크립트 기초"/>
      <span class="play">▶ 재생</span>
    </div>
    <div class="inner">
      <div style="font-weight:600">자바스크립트 기초 한 방에</div>
      <div class="muted">JS Lab · 58:12</div>
    </div>
  </a>
</c:if>
        </div>
      </section>

      <div style="display:grid;grid-template-columns:2fr 1fr;gap:20px;margin-top:20px">
        <!-- 추천 스터디 세션 -->
        <section class="section">
          <h2 class="title">추천 스터디 세션</h2>
          <div class="list">
            <c:forEach var="s" items="${recStudies}">
              <div class="row">
                <div>
                  <div style="font-weight:600"><a href="<c:url value='/study/detail'/>?id=${s.id}" style="text-decoration:none;color:inherit"><c:out value="${s.title}"/></a></div>
                  <div class="muted"><c:out value="${s.hostName}"/> · <fmt:formatDate value="${s.startAt}" pattern="M월 d일 HH:mm"/> · 정원 <c:out value="${s.limit}"/>명</div>
                </div>
                <div><span class="badge"><c:out value="${s.category}"/></span></div>
              </div>
            </c:forEach>
            <c:if test="${empty recStudies}">
  <div class="row">
    <div>
      <div style="font-weight:600"><a href="#" style="text-decoration:none;color:inherit">알고리즘 기초반 (그리디/정렬)</a></div>
      <div class="muted">호스트 김튜터 · 10월 3일 20:00 · 정원 6명</div>
    </div>
    <div><span class="badge">CS</span></div>
  </div>
  <div class="row">
    <div>
      <div style="font-weight:600"><a href="#" style="text-decoration:none;color:inherit">웹 기초: HTML/CSS 실습</a></div>
      <div class="muted">호스트 박디자 · 10월 4일 19:30 · 정원 6명</div>
    </div>
    <div><span class="badge">WEB</span></div>
  </div>
  <div class="row">
    <div>
      <div style="font-weight:600"><a href="#" style="text-decoration:none;color:inherit">네트워크 입문 스터디</a></div>
      <div class="muted">호스트 이엔지 · 10월 5일 21:00 · 정원 6명</div>
    </div>
    <div><span class="badge">NETWORK</span></div>
  </div>
</c:if>
          </div>
        </section>

        <!-- 공지/커뮤니티 -->
        <aside class="section">
          <h2 class="title">공지 & 커뮤니티</h2>
          <div class="list">
            <c:forEach var="n" items="${notices}">
              <div class="row">
                <div style="font-weight:600"><a href="<c:url value='/board/detail'/>?id=${n.id}" style="text-decoration:none;color:inherit"><c:out value="${n.title}"/></a></div>
                <div class="muted"><fmt:formatDate value="${n.createdAt}" pattern="yyyy.MM.dd"/></div>
              </div>
            </c:forEach>
            <c:if test="${empty notices}">
			  <div class="row">
			    <div style="font-weight:600"><a href="#" style="text-decoration:none;color:inherit">베타 오픈 안내</a></div>
			    <div class="muted">2025.09.25</div>
			  </div>
			  <div class="row">
			    <div style="font-weight:600"><a href="#" style="text-decoration:none;color:inherit">그룹 시청 동기화 개선</a></div>
			    <div class="muted">2025.09.27</div>
			  </div>
			  <div class="row">
			    <div style="font-weight:600"><a href="#" style="text-decoration:none;color:inherit">튜터 매칭 기능 예고</a></div>
			    <div class="muted">2025.10.01</div>
			  </div>
			</c:if>
          </div>
        </aside>
      </div>
      
      

    </div>
  </main>
</div>
</body>
</html>