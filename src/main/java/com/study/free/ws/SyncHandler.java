package com.study.free.ws;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.study.free.sync.dao.PlaybackStateDAO;
import com.study.free.sync.vo.PlaybackStateVO;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class SyncHandler extends TextWebSocketHandler {

    // ====== 기존 필드 ======
    private final Map<String, Set<WebSocketSession>> rooms = new ConcurrentHashMap<>();
    private final ObjectMapper om = new ObjectMapper();
    
    private final PlaybackStateDAO playbackDao; // ★ 추가

    public SyncHandler(PlaybackStateDAO playbackDao) {
        this.playbackDao = playbackDao;
    }

    // 허용 kind (이미지/그림/권한 포함)
    private static final Set<String> ALLOW = new HashSet<>(
            Arrays.asList("ctrl","tick","chat","draw","perm","admin")
    );

    // ====== 방 상태(영상/재생/화이트보드) 저장소 ======
    private final Map<String, RoomState> states = new ConcurrentHashMap<>();
    private final Set<String> hostOnline = ConcurrentHashMap.newKeySet();

    // ====== 내부 상태 클래스 (메모리 유지) ======
    private static class RoomState {
    	volatile String videoId = null; 
        volatile double positionSec = 0;
        volatile boolean playing = false;
        volatile long lastUpdateMillis = System.currentTimeMillis();
        volatile boolean wbOpen = false;
        volatile boolean seeded = false; 
        
        synchronized void seed(String vid, int pos, boolean playing){
            if (vid == null || vid.isEmpty()) return;
            videoId = vid; positionSec = Math.max(0, pos);
            this.playing = playing;
            lastUpdateMillis = System.currentTimeMillis();
            seeded = true;
        }

        synchronized void load(String vid){
            if (vid == null || vid.isEmpty()) return;
            videoId = vid; positionSec = 0; playing = false;
            lastUpdateMillis = System.currentTimeMillis();
        }
        synchronized void playAt(double at){
            positionSec = at; playing = true;
            lastUpdateMillis = System.currentTimeMillis();
        }
        synchronized void pauseAt(double at){
            positionSec = at; playing = false;
            lastUpdateMillis = System.currentTimeMillis();
        }
        synchronized void seekTo(double to){
            positionSec = to;
            lastUpdateMillis = System.currentTimeMillis();
        }
        synchronized void tick(double at){
            positionSec = at; playing = true;
            lastUpdateMillis = System.currentTimeMillis();
        }
        synchronized void setWbOpen(boolean open){ wbOpen = open; }

        synchronized double currentPosition(){
            if (!playing) return positionSec;
            long now = System.currentTimeMillis();
            double delta = (now - lastUpdateMillis) / 1000.0;
            return Math.max(0, positionSec + delta);
        }
        synchronized Snapshot snapshot(){
            return new Snapshot(videoId, Math.floor(currentPosition()), playing, wbOpen);
        }
        synchronized void freeze(){ // 호스트 이탈 시 위치 고정 + 정지
            positionSec = currentPosition(); playing = false;
            lastUpdateMillis = System.currentTimeMillis();
        }
        static class Snapshot {
            final String id; final double at; final boolean playing; final boolean wbOpen;
            Snapshot(String id, double at, boolean playing, boolean wbOpen){
                this.id=id; this.at=at; this.playing=playing; this.wbOpen=wbOpen;
            }
        }
    }

    // ====== 기존 메서드 ======
    @Override
    public void afterConnectionEstablished(WebSocketSession s) {
        // 세션 속성에서 room 번호와 role(사용자 역할: host/member 등)을 꺼냄
        String room = (String) s.getAttributes().get("room");
        String role = String.valueOf(s.getAttributes().get("role")); 
        // rooms 맵에 해당 room이 없으면 새로 생성하고, 세션을 추가
        // 방 번호별로 접속한 세션(WebSocket 연결)들을 관리
        rooms.computeIfAbsent(room, k -> ConcurrentHashMap.newKeySet()).add(s);
        // states 맵에서 해당 room의 상태(RoomState)를 가져옴 없으면 새 RoomState 생성
        RoomState st = states.computeIfAbsent(room, k -> new RoomState());
        // DB에서 영상 상태를 읽어와 방 상태 초기화 (처음 한 번만 실행)
        if (!st.seeded) {
            try {
                // room 번호를 정수로 변환
                Integer rid = Integer.valueOf(room);
                // DB에서 해당 방의 재생 상태 조회
                PlaybackStateVO pb = playbackDao.selectByRoomId(rid);

                if (pb != null) {
                    // DB 값에서 재생 상태 해석: IS_PAUSED = 'N'이면 playing=true
                    boolean playing = "N".equalsIgnoreCase(pb.getIsPaused());
                    // RoomState에 유튜브 ID, 위치(초), 재생여부를 초기화(seed)
                    st.seed(
                        pb.getYtId(), 
                        Optional.ofNullable(pb.getPositionSec()).orElse(0), 
                        playing
                    );
                }
            } catch (Exception ignore) {
                // roomId 변환 실패나 DB 조회 오류 발생 시 무시
            }
        }
        // 접속자가 host라면 hostOnline 집합에 추가 (호스트 온라인 표시)
        if ("host".equals(role)) hostOnline.add(room);
        // 접속 로그 출력
        log(s, "OPEN room=" + room + " role=" + role);
    }

    @Override
    protected void handleTextMessage(WebSocketSession s, TextMessage msg) throws Exception {
        String room = (String) s.getAttributes().get("room");
        String role = String.valueOf(s.getAttributes().get("role"));
        String payload = msg.getPayload();

        // 크기 로깅 (문제 추적용)
        int size = payload.getBytes(StandardCharsets.UTF_8).length;
        log(s, "MSG bytes=" + size);

        // kind 판별
        String kind = null;
        JsonNode root = null; // CHANGE: 한 번만 파싱
        try {
            root = om.readTree(payload);
            JsonNode k = root.get("kind");
            if (k != null && k.isTextual()) kind = k.asText();
        } catch (Exception ignore) {}

        // ======  방 상태 갱신 및 스냅샷 응답 ======
        RoomState st = states.computeIfAbsent(room, k -> new RoomState());

        if ("admin".equals(kind)) {
            String type = text(root, "type");
            if ("STATE_REQ".equals(type)) {
                RoomState.Snapshot snap = st.snapshot();
                Map<String, Object> resp = new HashMap<>();
                resp.put("kind", "ctrl");
                resp.put("type", "SNAPSHOT");
                if (snap.id != null && !snap.id.isEmpty()) resp.put("id", snap.id); // ★
                resp.put("at", snap.at);
                resp.put("playing", snap.playing);
                resp.put("wbOpen", snap.wbOpen);
                send(s, om.writeValueAsString(resp));
                return;
            }
        }

        if ("ctrl".equals(kind)) {
            if ("host".equals(role)) {
                String type = text(root, "type");
                if ("LOAD".equals(type)) {
                    st.load(text(root, "id"));
                } else if ("PLAY".equals(type)) {
                    st.playAt(num(root, "at", 0));
                } else if ("PAUSE".equals(type)) {
                    st.pauseAt(num(root, "at", 0));
                } else if ("SEEK".equals(type)) {
                    st.seekTo(num(root, "to", 0));
                }
            }
            broadcast(room, s, payload); // 기존 정책 유지(보낸 사람 제외)
            return;
        }

        if ("tick".equals(kind)) {
            if ("host".equals(role)) {
                st.tick(num(root, "at", 0));
            }
            broadcast(room, s, payload); // 멤버 드리프트 보정
            return;
        }

        if ("draw".equals(kind)) {
            String type = text(root, "type");
            if ("WB_TOGGLE".equals(type)) {
                st.setWbOpen(bool(root, "open", false));
            }
            broadcast(room, null, payload); // 모두에게
            return;
        }

        if ("chat".equals(kind) || "perm".equals(kind)) {
            broadcast(room, s, payload); // 보낸 사람 제외 (중복 해결)
            return;
        }

        // 허용 목록 외 -> 그대로 브로드캐스트(기존 동작 유지)
        // if (kind != null && !ALLOW.contains(kind)) { log(s, "BLOCK kind=" + kind); return; }
        broadcast(room, s, payload);
    }

    private void broadcast(String room, WebSocketSession sender, String json) {
        Set<WebSocketSession> set = rooms.getOrDefault(room, Collections.emptySet());
        for (WebSocketSession x : set) {
            if (x.isOpen() && x != sender) {
                try { x.sendMessage(new TextMessage(json)); }
                catch (Exception e) { /* 무시하고 계속 */ }
            }
        }
    }

    // 단일 전송 헬퍼
    private void send(WebSocketSession s, String json) {
        if (s != null && s.isOpen()) {
            try { s.sendMessage(new TextMessage(json)); } catch (Exception ignore) {}
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession s, CloseStatus st) {
        String room = (String) s.getAttributes().get("room");
        String role = String.valueOf(s.getAttributes().get("role")); // ★ ADD
        Set<WebSocketSession> set = rooms.get(room);
        if (set != null) set.remove(s);

        // 호스트가 나가면 상태 고정 + 재생 정지, 상태는 유지(새 입장자에게 계속 제공)
        if ("host".equals(role)) {
            hostOnline.remove(room);
            RoomState rs = states.get(room);
            if (rs != null) rs.freeze();
        }
        log(s, "CLOSE " + st + " role=" + role);
    }

    private void log(WebSocketSession s, String m) {
        String room = String.valueOf(s.getAttributes().get("room"));
        String name = String.valueOf(s.getAttributes().get("name"));
        System.out.println("[SyncHandler]["+room+"]["+name+"] " + m);
    }

    // ====== JSON 편의 메서드 ======
    private static String text(JsonNode n, String k){
        if (n==null) return null; JsonNode v=n.get(k);
        return (v!=null && v.isTextual()) ? v.asText() : null;
    }
    private static double num(JsonNode n, String k, double def){
        if (n==null) return def; JsonNode v=n.get(k);
        return (v!=null && v.isNumber()) ? v.asDouble() : def;
    }
    private static boolean bool(JsonNode n, String k, boolean def){
        if (n==null) return def; JsonNode v=n.get(k);
        return (v!=null && v.isBoolean()) ? v.asBoolean() : def;
    }
}
