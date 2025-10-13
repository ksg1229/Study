package com.study.free.member.dao;

import org.apache.ibatis.annotations.Mapper;

import com.study.free.member.vo.MemberVO;

@Mapper
public interface IMemberDAO {
	
	public int registMember(MemberVO vo);
	
	public MemberVO loginMember(MemberVO vo);
	
	//프로필 이미지
	public int profileUpload(MemberVO vo);

}
