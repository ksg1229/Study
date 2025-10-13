// src/main/java/com/study/free/message/web/MessageApiController.java
package com.study.free.message.web;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.study.free.message.dao.MessageDAO;
import com.study.free.message.vo.MessageVO;
import com.study.free.message.vo.MessageQueryVO;

@Controller
@RequestMapping("/api/rooms/{roomId}")
public class MessageApiController {

    private final MessageDAO messageDao;

    public MessageApiController(MessageDAO messageDao) {
        this.messageDao = messageDao;
    }

    // 목록 조회: 채팅(TEXT) + 메모(MEMO) 함께 반환
    @GetMapping("/messages")
    @ResponseBody
    public List<MessageVO> list(@PathVariable("roomId") Integer roomId) {
        MessageQueryVO q = new MessageQueryVO();
        q.setRoomId(roomId);
        q.setLimit(500); // 필요 시 조절
        return messageDao.selectByRoom(q);
    }

    // 저장: x-www-form-urlencoded 본문을 커맨드 객체로 바인딩
    // (요청 필드: msgType(TEXT/MEMO/IMAGE), content, atSec, metaJson)
    @PostMapping("/messages")
    @ResponseBody
    public Map<String,Object> create(@PathVariable("roomId") Integer roomId,
                                     MessageCreateForm form,
                                     HttpSession session) {
        String memId = (String) session.getAttribute("loginMemberId"); // ← 실제 세션키로!
        if (memId == null || memId.isEmpty()) {
            throw new RuntimeException("AUTH_REQUIRED"); // 또는 401로 매핑
        }
        MessageVO vo = new MessageVO();
        vo.setRoomId(roomId);
        vo.setSenderId(memId);               // FK: MEMBERS.MEM_ID
        vo.setMsgType(safeType(form.getMsgType()));
        vo.setContent(nvl(form.getContent()));
        vo.setAtSec(form.getAtSec());
        vo.setMetaJson(form.getMetaJson());
        int n = messageDao.insert(vo);
        Map<String,Object> res = new HashMap<>();
        res.put("ok", n > 0);
        return res;
    }

    // ==== 내부 유틸 ====
    private String safeType(String t){
        if (t == null) return "TEXT";
        t = t.toUpperCase(Locale.ROOT);
        if (!"TEXT".equals(t) && !"MEMO".equals(t) && !"IMAGE".equals(t) && !"SYSTEM".equals(t)) {
            return "TEXT";
        }
        return t;
    }
    private String nvl(String s){ return s == null ? "" : s; }

    // ==== 커맨드 객체 (폼 바인딩) ====
    public static class MessageCreateForm {
        private String msgType;
        private String content;
        private Integer atSec;
        private String metaJson;

        public String getMsgType() { return msgType; }
        public void setMsgType(String msgType) { this.msgType = msgType; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public Integer getAtSec() { return atSec; }
        public void setAtSec(Integer atSec) { this.atSec = atSec; }
        public String getMetaJson() { return metaJson; }
        public void setMetaJson(String metaJson) { this.metaJson = metaJson; }
    }
}
