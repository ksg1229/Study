package com.study.free.room.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.study.free.room.vo.RoomVO;

@Mapper
public interface RoomMemberDAO {
    int insertHost(@Param("roomId") Integer roomId, @Param("memberId") String memberId);
    
    int delete(RoomVO vo);
}
