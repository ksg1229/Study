package com.study.free.sync.web;

import javax.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;
import com.study.free.sync.service.PlaybackStateService;
import com.study.free.sync.vo.PlaybackStateVO;

@RestController
@RequestMapping("/api/rooms")
public class PlaybackApiController {

    private final PlaybackStateService service;

    public PlaybackApiController(PlaybackStateService service) {
        this.service = service;
    }

    @GetMapping("/{roomId}/playback")
    public PlaybackStateVO get(@PathVariable("roomId") Integer roomId){
        return service.get(roomId);
    }

    @PutMapping("/{roomId}/playback")
    public String save(@PathVariable("roomId") Integer roomId,
                       @RequestBody PlaybackStateVO body,
                       HttpServletRequest req){
        body.setRoomId(roomId);
        if (body.getUpdatedBy() == null) {
            Object uid = req.getSession().getAttribute("loginId");
            body.setUpdatedBy(uid != null ? String.valueOf(uid) : "system");
        }
        service.save(body);
        return "OK";
    }
}
