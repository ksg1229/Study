# StudySync (스터디싱크)

**유튜브 기반 실시간 소규모 스터디 플랫폼**

StudySync는 개인 학습뿐만 아니라 실시간으로 친구들과 함께 영상을 시청하며 학습할 수 있는 환경을 제공합니다. 영상 동기화, 채팅, 화이트보드 등 다양한 도구로 마치 한 공간에 있는 듯한 학습 경험을 선사합니다.

## ✨ 주요 기능

*   **📺 실시간 영상 동기화 (Watch Together)**
    *   YouTube 영상을 호스트의 제어(재생, 일시정지, 탐색)에 맞춰 모든 참여자가 동시에 시청할 수 있습니다.
    *   중간에 입장해도 현재 재생 위치로 자동 동기화됩니다.
*   **🛠 스터디 협업 도구**
    *   **실시간 채팅**: 학습 중 자유로운 의견 교환
    *   **화이트보드**: 캔버스를 통한 판서 및 아이디어 시각화
    *   **이미지 공유**: 학습 자료 및 이미지 실시간 공유
*   **👥 그룹 및 커뮤니티**
    *   스터디 방 개설 및 참여 (호스트/게스트 권한 관리)
    *   추천 강의 및 스터디 세션 탐색
    *   공지사항 및 게시판 기능

## 🛠 기술 스택 (Tech Stack)

### Backend
*   **Language**: Java 8
*   **Framework**: Spring Framework 4.3.28 (Spring MVC)
*   **Database**: Oracle Database (MyBatis 3.5.6)
*   **Real-time**: Spring WebSocket
*   **Security**: Spring Security 5.3.13

### Frontend
*   **View**: JSP 2.1 / JSTL 1.2
*   **Styling**: Custom CSS (Responsive)
*   **Client Logic**: JavaScript (WebSocket handling, YouTube IFrame API)

## 📦 설치 및 실행

1.  프로젝트 클론
2.  Maven 의존성 설치 (`mvn install`)
3.  Tomcat 서버 설정 및 배포
4.  `http://localhost:8080/` 접속

---
*이 프로젝트는 학습 및 포트폴리오 목적으로 제작되었습니다.*
