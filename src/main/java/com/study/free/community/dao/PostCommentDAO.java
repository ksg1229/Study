package com.study.free.community.dao;

import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import com.study.free.community.vo.PostCommentVO;
import com.study.free.community.vo.CreateCommentVO;
import com.study.free.community.vo.CommentPageQueryVO;

@Mapper
public interface PostCommentDAO {
    int countByPostId(BigDecimal postId);
    List<PostCommentVO> selectByPostIdPaged(CommentPageQueryVO q); // 11g ROWNUM
    PostCommentVO selectOne(BigDecimal commentId);                  // 🔹 단건 조회(작성자 확인)
    int insert(CreateCommentVO vo);
    int softDelete(BigDecimal commentId);
}