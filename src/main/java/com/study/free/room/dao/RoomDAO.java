package com.study.free.room.dao;

import java.util.List;
import java.util.Optional;

import org.apache.ibatis.annotations.Mapper;

import com.study.free.room.vo.RoomCreateAggVO;
import com.study.free.room.vo.RoomVO;

@Mapper
public interface RoomDAO {
    // 방 + HOST + PLAYBACK_STATE 통합 생성 (한 번의 호출)
    int createAll(RoomCreateAggVO agg);

    Optional<RoomVO> findById(Integer roomId);
    Optional<RoomVO> findByTitle(String title);
    List<RoomVO> selectList(); // 썸네일 포함 목록
    
    int updateStatus(RoomVO vo);
    String findHostMemberId(Integer roomId);
    List<RoomVO> selectByHost(String hostMemberId);
    int countByTitle(String title);
}