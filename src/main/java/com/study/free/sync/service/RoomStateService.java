package com.study.free.sync.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.study.free.sync.dao.RoomStateMapper;
import com.study.free.sync.vo.RoomState;

@Service
public class RoomStateService {

    @Autowired
    private RoomStateMapper mapper;

    public RoomState load(String roomId) {
        return mapper.find(roomId);
    }

    public void save(RoomState state) {
        // 먼저 DB에 해당 roomId가 있으면 update, 없으면 insert
        RoomState exists = mapper.find(state.getRoomId());
        if (exists == null) {
            mapper.insert(state);
        } else {
            mapper.update(state);
        }
    }
}
