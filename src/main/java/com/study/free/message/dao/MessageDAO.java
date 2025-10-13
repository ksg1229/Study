package com.study.free.message.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.study.free.message.vo.MessageQueryVO;
import com.study.free.message.vo.MessageVO;

@Mapper
public interface MessageDAO {

	int insert(MessageVO vo);
    List<MessageVO> selectByRoom(MessageQueryVO q); // ← 단일 파라미터

}
