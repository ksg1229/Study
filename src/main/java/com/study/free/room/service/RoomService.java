package com.study.free.room.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.study.free.room.dao.RoomDAO;
import com.study.free.room.dao.RoomMemberDAO;
import com.study.free.room.vo.RoomCreateAggVO;
import com.study.free.room.vo.RoomCreateVO;
import com.study.free.room.vo.RoomVO;
import com.study.free.sync.dao.PlaybackStateDAO;

@Service
public class RoomService {

    private final RoomDAO roomDao;
    private final RoomMemberDAO roomMemberDao;
    private final PlaybackStateDAO playbackStateDao;

    public RoomService(RoomDAO roomDao,
                       RoomMemberDAO roomMemberDao,
                       PlaybackStateDAO playbackStateDao) {
        this.roomDao = roomDao;
        this.roomMemberDao = roomMemberDao;
        this.playbackStateDao = playbackStateDao;
    }

    /** A. 인원 6 고정 + 생성 */
    @Transactional
    public Integer createRoomWithInit(String hostMemberId, String title, Integer maxMember, String ytUrl) {
        RoomCreateAggVO agg = new RoomCreateAggVO();
        agg.setHostMemberId(hostMemberId);
        agg.setTitle(title);
        agg.setMaxMember(6); // ★ 항상 6으로 고정
        agg.setYtId(extractYoutubeId(ytUrl));
        roomDao.createAll(agg); // ROOM + ROOM_MEMBER(HOST) + PLAYBACK_STATE
        return agg.getRoomId();
    }

    /** B. 인원 6 고정 + 생성 (Form 버전) */
    @Transactional
    public Integer createRoomWithVideo(RoomCreateVO form, String hostMemberId){
        RoomCreateAggVO agg = new RoomCreateAggVO();
        agg.setHostMemberId(hostMemberId);
        agg.setTitle(form.getTitle());
        agg.setMaxMember(6); // ★ 항상 6으로 고정
        agg.setYtId(extractYoutubeId(form.getYoutubeUrl()));
        roomDao.createAll(agg);
        return agg.getRoomId();
    }

    @Transactional(readOnly = true)
    public List<RoomVO> listRooms() {
        return roomDao.selectList();
    }

    // 유튜브 ID 파싱
    private String extractYoutubeId(String url) {
        if (url == null) return null;
        int p = url.indexOf("youtu.be/");
        if (p >= 0) {
            String t = url.substring(p + "youtu.be/".length());
            int q = t.indexOf('?'); return q >= 0 ? t.substring(0, q) : t;
        }
        p = url.indexOf("v=");
        if (p >= 0) {
            String t = url.substring(p + 2);
            int q = t.indexOf('&'); return q >= 0 ? t.substring(0, q) : t;
        }
        p = url.indexOf("/embed/");
        if (p >= 0) {
            String t = url.substring(p + "/embed/".length());
            int q = t.indexOf('?'); return q >= 0 ? t.substring(0, q) : t;
        }
        if (url.length() == 11) return url;
        return null;
    }

    /** C. (요청하신 정책) 호스트가 연결 종료/새로고침해도 CLOSE로 전환 */
    @Transactional
    public void closeOnHostDisconnect(Integer roomId, String memberId) {
        String hostId = roomDao.findHostMemberId(roomId);
        if (hostId != null && hostId.equals(memberId)) {
            RoomVO vo = new RoomVO();
            vo.setRoomId(roomId);
            vo.setStatus("CLOSE");
            roomDao.updateStatus(vo); // @Param 필요 없음
        }
    }

    /** D. 명시적 퇴장 API (호스트가 진짜로 나가면 CLOSE) */
    @Transactional
    public void leaveRoom(Integer roomId, String memberId) {
        RoomVO vo = new RoomVO();
        vo.setRoomId(roomId);
        vo.setMemberId(memberId);

        // ROOM_MEMBER에서 삭제
        roomMemberDao.delete(vo);

        // 호스트 확인 후 상태 변경
        String hostId = roomDao.findHostMemberId(roomId);
        if (hostId != null && hostId.equals(memberId)) {
            vo.setStatus("CLOSE");
            roomDao.updateStatus(vo);
        }
    }
    
    @Transactional
    public void closeRoomByHost(Integer roomId, String hostMemberId){
        // 호스트 검증
        String hostId = roomDao.findHostMemberId(roomId);
        if (hostId == null || !hostId.equals(hostMemberId)) {
            throw new IllegalStateException("호스트만 방을 종료할 수 있습니다.");
        }

        RoomVO vo = new RoomVO();
        vo.setRoomId(roomId);
        vo.setStatus("CLOSE");
        roomDao.updateStatus(vo);
    }
    
    @Transactional
    public void openRoomByHost(Integer roomId, String hostMemberId){
        String hostId = roomDao.findHostMemberId(roomId);
        if (hostId == null || !hostId.equals(hostMemberId)) {
            throw new IllegalStateException("호스트만 방을 재오픈할 수 있습니다.");
        }
        RoomVO vo = new RoomVO();
        vo.setRoomId(roomId);
        vo.setStatus("OPEN");
        roomDao.updateStatus(vo);
    }
    
    @Transactional
    public List<RoomVO> getRoomsByHost(String hostMemberId){
        return roomDao.selectByHost(hostMemberId);
    }
}
