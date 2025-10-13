package com.study.free.sync.dao;

import org.apache.ibatis.annotations.Mapper;
import com.study.free.sync.vo.RoomState;

@Mapper
public interface RoomStateMapper {
    RoomState find(String roomId);
    void insert(RoomState state);
    void update(RoomState state);
}
