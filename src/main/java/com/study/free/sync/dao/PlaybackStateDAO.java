// src/main/java/com/study/free/sync/dao/PlaybackStateDAO.java
package com.study.free.sync.dao;

import org.apache.ibatis.annotations.Mapper;
import com.study.free.sync.vo.PlaybackStateVO;

@Mapper
public interface PlaybackStateDAO {
    PlaybackStateVO selectByRoomId(Integer roomId);
    int upsert(PlaybackStateVO vo);  // ★ insert/update 대신 upsert 하나
}
