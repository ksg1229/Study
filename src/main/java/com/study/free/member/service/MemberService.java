package com.study.free.member.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.study.free.member.dao.IMemberDAO;
import com.study.free.member.vo.MemberVO;

@Service
public class MemberService {
	
	@Autowired
	IMemberDAO dao;

	public void registMember(MemberVO vo) throws Exception{
		
		int result = dao.registMember(vo);
		if(result == 0) {
			throw new Exception();
		}		
	}
	
	public MemberVO loginMember(MemberVO vo) throws Exception {
		MemberVO result = dao.loginMember(vo);
		if(result == null) {
			throw new Exception();
		}
		return result;
	}
	
	public String profileUpload(MemberVO vo				//사용자 정보
							   ,String uploadDir		//서버 파일 위치
							   ,String webPath			//웹 경로
							   ,MultipartFile file) throws Exception {	//저장 파일
					//파일명 생성
		String origin = file.getOriginalFilename();
		String uniqe = UUID.randomUUID().toString()+"_"+origin;
		String dbPath = webPath + uniqe;
		Path filePath = Paths.get(uploadDir, uniqe );	
		//서버에 저장
		try {
			Files.copy(file.getInputStream(), filePath);
		} catch (IOException e) {
			throw new Exception("file to save the fail", e);
		}
		//DB에 저장
		vo.setProfileImg(dbPath);
		int result = dao.profileUpload(vo);
		if(result ==0) {
			throw new Exception();
		}		
		return dbPath;

}
	

}
