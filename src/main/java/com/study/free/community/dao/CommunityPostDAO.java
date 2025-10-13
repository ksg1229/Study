package com.study.free.community.dao;

import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import com.study.free.community.vo.CommunityPostVO;

@Mapper
public interface CommunityPostDAO {

    // 목록(삭제글 제외)
    List<CommunityPostVO> selectList();

    // 단건
    CommunityPostVO selectOne(BigDecimal postId);

    // 조회수 +1
    int increaseView(BigDecimal postId);

    // 등록
    int insert(CommunityPostVO vo);

    // 수정
    int update(BigDecimal postId, String title, String content, String category);

    // 소프트 삭제
    int softDelete(BigDecimal postId);
}