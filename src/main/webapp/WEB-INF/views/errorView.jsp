<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
 <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>error page</title>
<jsp:include page="/WEB-INF/inc/top.jsp" ></jsp:include>
</head>
<body>
<div class="app">
<jsp:include page="/WEB-INF/inc/header.jsp" />
		<!-- top 영역 -->
		<header class="masthead bg-primary text-white text-center">
            <div class="container d-flex align-items-center flex-column">
                <!-- Masthead Avatar Image-->
                <img class="masthead-avatar mb-5" src="${pageContext.request.contextPath}/assets/img/avataaars.svg" alt="..." />
                <!-- Masthead Heading-->
                <h1 class="masthead-heading text-uppercase mb-0">에러 페이지</h1>
                <!-- Icon Divider-->
                <div class="divider-custom divider-light">
                    <div class="divider-custom-line"></div>
                    <div class="divider-custom-icon"><i class="fas fa-star"></i></div>
                    <div class="divider-custom-line"></div>
                </div>
                <!-- Masthead Subheading-->
                <p class="masthead-subheading font-weight-light mb-0">의도치 않은 에러가 발생했습니다...</p>
            </div>
        </header>
		<!-- footer영역 -->
		<jsp:include page="/WEB-INF/inc/footer.jsp" ></jsp:include>
		<!-- footer영역 -->
		</div>
</body>
</html>