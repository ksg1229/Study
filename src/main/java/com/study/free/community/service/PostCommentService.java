package com.study.free.community.service;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.study.free.community.dao.PostCommentDAO;
import com.study.free.community.vo.PostCommentVO;
import com.study.free.community.vo.CreateCommentVO;
import com.study.free.community.vo.CommentPageQueryVO;

@Service
public class PostCommentService {

    private final PostCommentDAO dao;

    public PostCommentService(PostCommentDAO dao) {
        this.dao = dao;
    }

    public int countByPost(BigDecimal postId) {
        return dao.countByPostId(postId);
    }

    public List<PostCommentVO> listByPostPaged(BigDecimal postId, int page, int size) {
        CommentPageQueryVO q = new CommentPageQueryVO();
        q.setPostId(postId);
        q.setPage(page);
        q.setSize(size);
        return dao.selectByPostIdPaged(q);
    }

    public PostCommentVO findOne(BigDecimal commentId) {
        return dao.selectOne(commentId);
    }

    @Transactional
    public void write(CreateCommentVO vo) {
        dao.insert(vo);
    }

    @Transactional
    public void softDelete(BigDecimal commentId) {
        dao.softDelete(commentId);
    }
}