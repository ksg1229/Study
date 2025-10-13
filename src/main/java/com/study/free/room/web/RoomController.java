package com.study.free.room.web;

import java.util.List;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.study.free.room.service.RoomService;
import com.study.free.room.vo.RoomCreateFormVO;
import com.study.free.room.vo.RoomVO;
import com.study.free.room.dao.RoomDAO; // 중복체크용 DAO

@Controller
@RequestMapping("/rooms")
public class RoomController {

    private final RoomService roomService;

    @Autowired
    private RoomDAO roomDAO; //  추가

    @Autowired
    public RoomController(RoomService roomService) {
        this.roomService = roomService;
    }

    // 목록
    @GetMapping({"", "/", "/list"})
    public String list(Model model) {
        List<RoomVO> rooms = roomService.listRooms();
        model.addAttribute("rooms", rooms);
        return "rooms/roomlist";
    }

    // 생성 폼
    @GetMapping("/create")
    public String createForm() {
        return "rooms/roomcreate";
    }

    // 생성 처리 → 세션 페이지로 리다이렉트
    @PostMapping("/create")
    public String create(RoomCreateFormVO form, HttpSession session, Model model) {
        String loginMemberId = getLoginMemberId(session);
        if (loginMemberId == null) {
            model.addAttribute("error", "로그인이 필요합니다.");
            return "redirect:/login";
        }

        // 입력 정리
        String title = safe(form.getTitle());
        String ytUrl = safe(form.getYtUrl());  // ★ 추가: ytUrl도 정리
        if (title.isEmpty()) {
            model.addAttribute("error", "제목은 필수입니다.");
            form.setTitle(title);
            form.setYtUrl(ytUrl);
            model.addAttribute("form", form);
            return "rooms/roomcreate";
        }
        if (ytUrl.isEmpty()) {                 // ★ 추가: ytUrl 필수 체크
            model.addAttribute("error", "유튜브 링크는 필수입니다.");
            form.setTitle(title);
            form.setYtUrl(ytUrl);
            model.addAttribute("form", form);
            return "rooms/roomcreate";
        }

        // 최대 인원 고정(6)
        final Integer maxMember = 6;
        form.setMaxMember(maxMember);
        form.setTitle(title);
        form.setYtUrl(ytUrl);

        // 1) 사전 중복 체크
        if (roomDAO.countByTitle(title) > 0) {
            model.addAttribute("error", "이미 존재하는 방 제목입니다. 다른 이름을 사용해 주세요.");
            model.addAttribute("form", form);
            return "rooms/roomcreate";
        }

        try {
            // 2) 생성 (DB 유니크 경합 대비하여 try-catch)
            Integer roomId = roomService.createRoomWithInit(
                loginMemberId, title, maxMember, ytUrl   // ★ ytUrl 사용
            );
            return "redirect:/sync/page?room=" + roomId + "&role=host&name=" + loginMemberId;

        } catch (DuplicateKeyException e) {
            // 동시성으로 유니크 제약 재충돌 시
            model.addAttribute("error", "이미 존재하는 방 제목입니다. 다른 이름을 사용해 주세요.");
            model.addAttribute("form", form);
            return "rooms/roomcreate";
        }
    }

    // 실시간 제목 중복 체크 (AJAX)
    @GetMapping(value="/check-title", produces="application/json;charset=UTF-8")
    @ResponseBody
    public java.util.Map<String, Object> checkTitle(@RequestParam(required=false) String title){
        String t = safe(title);
        boolean ok = (!t.isEmpty() && roomDAO.countByTitle(t) == 0);
        return java.util.Map.of("ok", ok);
    }

    @PostMapping(value="/close/{roomId}", produces="application/json;charset=UTF-8")
    @ResponseBody
    public String close(@PathVariable Integer roomId, HttpSession session){
        String loginMemberId = getLoginMemberId(session);
        if (loginMemberId == null) return "{\"ok\":false,\"msg\":\"로그인이 필요합니다.\"}";
        roomService.closeRoomByHost(roomId, loginMemberId);
        return "{\"ok\":true}";
    }

    @PostMapping(value="/open/{roomId}", produces="application/json;charset=UTF-8")
    @ResponseBody
    public String open(@PathVariable Integer roomId, HttpSession session){
        String loginMemberId = getLoginMemberId(session);
        if (loginMemberId == null) return "{\"ok\":false,\"msg\":\"로그인이 필요합니다.\"}";
        roomService.openRoomByHost(roomId, loginMemberId);
        return "{\"ok\":true}";
    }

    private String getLoginMemberId(HttpSession session) {
        Object v = session.getAttribute("loginMemberId");
        if (v != null) return v.toString();
        // 기존 세션 모델이 login 객체라면 memId 리플렉션으로 보정
        Object login = session.getAttribute("login");
        if (login != null) {
            try { return (String) login.getClass().getMethod("getMemId").invoke(login); }
            catch (Exception ignored) {}
        }
        return null;
    }

    private String safe(String s){
        return (s == null) ? "" : s.trim();
    }
}
