package com.study.free.member.web;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.study.free.member.service.MemberService;
import com.study.free.member.vo.MemberVO;
import com.study.free.room.service.RoomService;

@Controller
public class MemberController {
	
	@Value("#{util['file.upload.path']}")
	private String CURR_IMAGE_PATH;
	
	@Value("#{util['file.download.path']}")
	private String WEB_PATH;

    @Autowired
    MemberService memService;
    
    @Autowired
    private RoomService roomService;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @RequestMapping("/loginView")
    public String loginView() {
        return "member/loginView";
    }

    @RequestMapping("/loginDo")
    public String loginDo(MemberVO vo,
                          HttpSession session,
                          @RequestParam(value="remember", defaultValue="false") boolean remember,
                          @RequestParam(value="redirect", required=false) String redirect,
                          HttpServletResponse res) {
        try {
            MemberVO user = memService.loginMember(vo); // memId로 조회
            if (user == null) return "redirect:/loginView?error=1";

            boolean match = passwordEncoder.matches(vo.getMemPw(), user.getMemPw());
            if (!match) return "redirect:/loginView?error=1";

            session.setAttribute("login", user);
            session.setAttribute("loginMemberId", user.getMemId());

            Cookie c = remember
              ? new Cookie("rememberId", user.getMemId())
              : new Cookie("rememberId", "");
            c.setMaxAge(remember ? 60*60*24*30 : 0);
            c.setPath("/");
            res.addCookie(c);

            // 원래 가려던 주소로 복귀
            if (redirect != null && !redirect.isEmpty()) {
                return "redirect:" + redirect;
            }
            return "redirect:/";
        } catch (Exception e) {
            e.printStackTrace();
            return "errorView";
        }
    }

    @RequestMapping("/logoutDo")
    public String logoutDo(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }

    @RequestMapping("/registView")
    public String registView() {
        return "member/registView";
    }

    @RequestMapping("/registDo")
    public String registDo(MemberVO vo) {
        vo.setMemPw(passwordEncoder.encode(vo.getMemPw()));
        try {
            memService.registMember(vo);
        } catch (Exception e) {
            e.printStackTrace();
            return "errorView";
        }
        return "redirect:/loginView";
    }

    @RequestMapping("/mypageView")
    public String mypageView(HttpSession session,
                             Model model) {
        Object loginObj = session.getAttribute("login");
        Object loginIdObj = session.getAttribute("loginMemberId");

        String memId = null;
        if (loginIdObj != null) {
            memId = loginIdObj.toString();
        } else if (loginObj instanceof com.study.free.member.vo.MemberVO) {
            memId = ((com.study.free.member.vo.MemberVO) loginObj).getMemId();
            session.setAttribute("loginMemberId", memId); // 이후 재사용
        }

        if (memId == null || memId.isEmpty()) {
            return "redirect:/loginView";
        }

        model.addAttribute("myHostRooms", roomService.getRoomsByHost(memId));
        return "member/mypageView";
    }
    
    @ResponseBody
	@PostMapping("/files/upload")
	public Map<String, String> uploadFile(@RequestParam("uploadImage") MultipartFile file
										  ,HttpSession session) throws Exception{
		
		MemberVO vo = (MemberVO) session.getAttribute("login");
		Map<String, String> map = new HashMap<>();
		String imgPath = memService.profileUpload(vo, CURR_IMAGE_PATH, WEB_PATH, file);
		map.put("imagePath", imgPath);
		map.put("message", "success");
		
		return map;
	}
}
