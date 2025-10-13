package com.study.free.sync.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.study.free.sync.dao.PlaybackStateDAO;
import com.study.free.sync.vo.PlaybackStateVO;

@Service
public class PlaybackStateService {
	
	@Autowired
    PlaybackStateDAO dao;

    public PlaybackStateService(PlaybackStateDAO dao) {
        this.dao = dao;
    }

    public PlaybackStateVO get(Integer roomId){
        return dao.selectByRoomId(roomId);
    }

    public void save(PlaybackStateVO vo){
        dao.upsert(vo);
    }
}
