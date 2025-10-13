<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>마이페이지</title>
<link href="${pageContext.request.contextPath}/css/styles.css" rel="stylesheet" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@400;500;600;700&display=swap" rel="stylesheet">
  <jsp:include page="/WEB-INF/inc/top.jsp" />
</head>
<body>
<div class="app">
<jsp:useBean id="now" class="java.util.Date" />
<c:if test="${empty summary}">
  <jsp:useBean id="summary" class="java.util.HashMap" scope="request"/>
  <c:set target="${summary}" property="totalHours"  value="12"/>
  <c:set target="${summary}" property="doneVideos"  value="7"/>
  <c:set target="${summary}" property="doneCourses" value="2"/>
  <c:set target="${summary}" property="progressPct" value="70"/>
  <c:set target="${summary}" property="lastStudyDate" value="${now}"/>
</c:if>
  <jsp:include page="/WEB-INF/inc/sidebar.jsp" />
  <jsp:include page="/WEB-INF/inc/header.jsp" />
  <main class="main">
    <div class="container">

      <!-- 상단 요약 -->
      <section class="hero">
        <div class="card">
          <div class="inner" style="display:grid;grid-template-columns:auto 1fr;gap:16px;align-items:center">
          <!-- 없을때  -->
					<c:if test = "${sessionScope.login.profileImg == null }">
	                    	<img src="<c:url value="/assets/img/non.png" />" 
	                    	  id="myImage" class="avatar lg" alt="me"/>
	                </c:if>    	  
	                <!-- 있을때  -->
	                <c:if test = "${sessionScope.login.profileImg != null }">
					<img src="<c:url value="${sessionScope.login.profileImg}" />" 
	                    	  id="myImage" class="avatar lg" alt="me"/>
	                </c:if>  
            <div>
              <h2 class="title"><c:out value="${sessionScope.login.memNm != null ? sessionScope.login.memNm : '초보자'}"/></h2>
              <div class="muted">안녕하세요! 오늘도 한 걸음 💪</div>
            </div>
            <form id="profileForm" enctype="multipart/form-data">
	                	<input type="file" id="uploadImage" name="uploadImage" style="display:none;">
	                </form>
            <div class="hero-stats" style="grid-column:1 / -1;margin-top:8px">
              <div class="stat"><div class="muted">학습 시간</div><div class="num"><c:out value="${summary.totalHours != null ? summary.totalHours : 0}"/>시간</div></div>
              <div class="stat"><div class="muted">완료한 동영상</div><div class="num"><c:out value="${summary.doneVideos != null ? summary.doneVideos : 0}"/>개</div></div>
              <div class="stat"><div class="muted">완료한 강좌</div><div class="num"><c:out value="${summary.doneCourses != null ? summary.doneCourses : 0}"/>개</div></div>
            </div>
          </div>
        </div>

        <div class="card course">
          <div class="inner">
            <h3 class="title">React 고급 과정</h3>
            <div class="muted">마지막 학습:
              <fmt:formatDate value="${summary.lastStudyDate != null ? summary.lastStudyDate : now}" pattern="yyyy년 M월 d일"/>
            </div>
            <div class="bar"><i style="width:${summary.progressPct != null ? summary.progressPct : 70}%"></i></div>
            <div class="muted" style="margin-top:6px">진행률:
              <b><c:out value="${summary.progressPct != null ? summary.progressPct : 70}"/>%</b>
            </div>
          </div>
        </div>
      </section>

      <!-- 중간 3열 -->
      <section class="grid-3" style="margin-top:20px">
        <!-- 체크리스트 -->
        <div class="card">
          <div class="inner">
            <h3 class="title">학습 체크리스트</h3>
            <ul class="checklist">
              <c:forEach var="item" items="${checklist}">
                <li>
                  <input type="checkbox" <c:if test="${item.done}">checked</c:if> data-id="${item.id}">
                  <div>
                    <div><c:out value="${item.title}"/></div>
                    <div class="muted"><c:out value="${item.note}"/></div>
                  </div>
                </li>
              </c:forEach>
              <c:if test="${empty checklist}">
  <li>
    <input type="checkbox" checked>
    <div>
      <div>React 훅 정리</div>
      <div class="muted">useState / useEffect / 커스텀 훅</div>
    </div>
  </li>
  <li>
    <input type="checkbox">
    <div>
      <div>HTTP 기본 복습</div>
      <div class="muted">GET/POST, 상태코드, CORS</div>
    </div>
  </li>
  <li>
    <input type="checkbox">
    <div>
      <div>자료구조: 스택/큐</div>
      <div class="muted">예제 3문제 풀기</div>
    </div>
  </li>
</c:if>
            </ul>
          </div>
        </div>

        <!-- 예정된 세션 -->
        <div class="card">
          <div class="inner">
            <h3 class="title">예정된 스터디 세션</h3>
            <div class="session-list">
              <c:forEach var="s" items="${upcoming}">
                <div class="item">
                  <div style="font-weight:600"><c:out value="${s.title}"/></div>
                  <div class="muted"><fmt:formatDate value="${s.startAt}" pattern="yyyy년 M월 d일 HH:mm"/> · <c:out value="${s.mode}"/></div>
                </div>
              </c:forEach>
              <c:if test="${empty upcoming}">
  <div class="item">
    <div style="font-weight:600">알고리즘 기초반 (그리디/정렬)</div>
    <div class="muted">2025년 10월 03일 20:00 · 온라인</div>
  </div>
  <div class="item">
    <div style="font-weight:600">웹 기초: HTML/CSS 실습</div>
    <div class="muted">2025년 10월 04일 19:30 · 오프라인</div>
  </div>
  <div class="item">
    <div style="font-weight:600">네트워크 입문 스터디</div>
    <div class="muted">2025년 10월 05일 21:00 · 온라인</div>
  </div>
</c:if>
            </div>
          </div>
        </div>

        <!-- 캘린더 -->
        <div class="card">
          <div class="inner cal">
            <div>
              <h3 class="title">스터디 캘린더</h3>
              <div class="muted" id="calLabel"></div>
            </div>
            <table id="miniCal">
              <thead>
              <tr><th>Su</th><th>Mo</th><th>Tu</th><th>We</th><th>Th</th><th>Fr</th><th>Sa</th></tr>
              </thead>
              <tbody></tbody>
            </table>
          </div>
        </div>
      </section>
      
      <!-- 내가 호스트인 스터디 -->
	<section class="card" style="margin-top:20px">
		<div class="inner">
		  <h3 class="title">내 스터디</h3>
		  <table class="table">
		    <thead>
		      <tr>
		        <th>그룹명</th>
		        <th>상태</th>
		        <th>생성일</th>
		        <th class="right">액션</th>
		      </tr>
		    </thead>
		    <tbody>
		      <c:choose>
				<c:when test="${empty myHostRooms}">
				  <tr>
				   	스터디를 시작해 보세요!
				  </tr>
				</c:when>
				<c:otherwise>
				<c:forEach var="r" items="${myHostRooms}">
				<tr>
				  <td><c:out value="${r.title}"/></td>
				<td>
				  <c:choose>
				<c:when test="${r.status eq 'OPEN'}"><span class="badge blue">OPEN</span></c:when>
				<c:otherwise><span class="badge gray">CLOSE</span></c:otherwise>
				</c:choose>
				</td>
				<td><fmt:formatDate value="${r.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
				<td class="right">
				  <a class="btn sm"
				     href="${pageContext.request.contextPath}/sync/page?room=${r.roomId}&role=host&name=${sessionScope.loginMemberId}">
				      입장
				    </a>
				  </td>
				</tr>
				</c:forEach>
				</c:otherwise>
				</c:choose>
		      </tbody>
		    </table>
		  </div>
	</section>

      <!-- 참여 기록 -->
      <section class="card" style="margin-top:20px">
        <div class="inner">
          <h3 class="title">스터디 참여 기록</h3>
          <table class="table">
            <thead><tr><th>그룹명</th><th>주제</th><th>날짜</th><th class="right">상태</th></tr></thead>
            <tbody>
            <c:forEach var="r" items="${participations}">
              <tr>
                <td><c:out value="${r.groupName}"/></td>
                <td><c:out value="${r.topic}"/></td>
                <td><fmt:formatDate value="${r.date}" pattern="yyyy년 M월 d일"/></td>
                <td class="right">
                  <c:choose>
                    <c:when test="${r.status eq '완료'}"><span class="badge blue">완료</span></c:when>
                    <c:when test="${r.status eq '대기'}"><span class="badge gray">대기</span></c:when>
                    <c:otherwise><span class="badge red"><c:out value="${r.status}"/></span></c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty participations}">
  <tr>
    <td>운영체제 한바퀴</td>
    <td>프로세스/스레드</td>
    <td>2025년 09월 27일</td>
    <td class="right"><span class="badge blue">완료</span></td>
  </tr>
  <tr>
    <td>JS 비동기 마스터</td>
    <td>Promise/async</td>
    <td>2025년 09월 29일</td>
    <td class="right"><span class="badge gray">대기</span></td>
  </tr>
</c:if>
            </tbody>
          </table>
        </div>
      </section>

    </div>
  </main>
</div>

<script>
document.querySelectorAll('.checklist input[type="checkbox"]').forEach(cb=>{
  cb.addEventListener('change', ()=>{
    fetch('/mypage/checklist/toggle?id='+cb.dataset.id,{method:'POST'}).catch(()=>{});
  });
});
(function(){
  const today=new Date(), y=today.getFullYear(), m=today.getMonth();
  const first=new Date(y,m,1), last=new Date(y,m+1,0);
  document.getElementById('calLabel').textContent=y+'년 '+(m+1)+'월';
  const tbody=document.querySelector('#miniCal tbody'); tbody.innerHTML='';
  let row=document.createElement('tr');
  for(let i=0;i<first.getDay();i++) row.appendChild(document.createElement('td'));
  for(let d=1; d<=last.getDate(); d++){
    const td=document.createElement('td'); td.textContent=d;
    if(d===today.getDate()) td.classList.add('is-today');
    const studyDays=JSON.parse('<c:out value="${calStudyDaysJson != null ? calStudyDaysJson : '[]'}"/>');
    const ymd=y+'-'+String(m+1).padStart(2,'0')+'-'+String(d).padStart(2,'0');
    if(studyDays.includes(ymd)) td.classList.add('has-study');
    row.appendChild(td);
    if((first.getDay()+d)%7===0){tbody.appendChild(row); row=document.createElement('tr');}
  }
  if(row.children.length) tbody.appendChild(row);
})();

// 파일 업로드
$(document).ready(function(){
			$("#myImage").click(function(){
				$("#uploadImage").click();
			});
			//이미지 변경시
			$("#uploadImage").on("change", function(){
				var file = $(this)[0].files[0];
				if(file){
					// FormData html폼 데이터를 전송에 쉽게 가져옴.
					var formData = new FormData($("#profileForm")[0]);
					$.ajax({
						url : '<c:url value="/files/upload" />'
					   ,type: 'POST'
					   ,data:formData
					   ,processData:false	// 전송 객체를 URL인코딩 하지 않도록
					   ,contentType:false	// 파일을 이진 데이터 형태로 전송하기 위해
					   ,success : function(res){
						   console.log(res);
						   if(res.message=='success'){
							   var path = '${pageContext.request.contextPath}';
							   $("#myImage").attr('src',path + res.imagePath);
						   }
					   }
					   ,error : function(e){
						   console.log(e);
					   }
					});
				}
			});
			
		});
</script>
</body>
</html>
