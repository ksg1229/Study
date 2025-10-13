package com.study.free.community.service;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.study.free.community.dao.CommunityPostDAO;
import com.study.free.community.vo.CommunityPostVO;

@Service
public class CommunityPostService {
	
    private final CommunityPostDAO dao;
    public CommunityPostService(CommunityPostDAO dao) { this.dao = dao; }

    public List<CommunityPostVO> list() { return dao.selectList(); }

    @Transactional
    public CommunityPostVO viewAndIncrease(BigDecimal postId) {
        dao.increaseView(postId);               // 먼저 +1
        return dao.selectOne(postId);           // 최신값 조회
    }
    
    @Transactional
    public BigDecimal write(CommunityPostVO vo) {
        dao.insert(vo);           // 실행 후 vo.setPostId가 채워짐
        return vo.getPostId();
    }
    
    // 단건(권한검증 등에서 사용)
    public CommunityPostVO findOne(BigDecimal postId) {
        return dao.selectOne(postId);
    }

    // 수정
    @Transactional
    public void update(BigDecimal postId, String title, String content, String category) {
        dao.update(postId, title, content, category);
    }

    // 삭제(소프트)
    @Transactional
    public void softDelete(BigDecimal postId) {
        dao.softDelete(postId);
    }
    
    
}