package com.study.free.community.web;

import java.math.BigDecimal;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.study.free.common.PageMeta;
import com.study.free.community.service.CommunityPostService;
import com.study.free.community.service.PostCommentService;
import com.study.free.community.vo.CommunityPostVO;
import com.study.free.community.vo.CreateCommentVO;
import com.study.free.community.vo.PostCommentVO;

import java.util.List;

@Controller
@RequestMapping("/community")
public class CommunityController {

    private final CommunityPostService postService;
    private final PostCommentService commentService;

    public CommunityController(CommunityPostService postService, PostCommentService commentService) {
        this.postService = postService;
        this.commentService = commentService;
    }

    @GetMapping({ "/", "/list" })
    public String list(Model model) {
        model.addAttribute("posts", postService.list()); // 기존 서비스 메서드 사용
        return "community/list"; // /WEB-INF/views/community/list.jsp
    }

    // 상세 (조회수 +1, 댓글 목록 페이징)
    @GetMapping("/view/{id}")
    public String view(@PathVariable("id") BigDecimal id,
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "size", defaultValue = "10") int size,
            HttpSession session,
            Model model) {

        Object v = session.getAttribute("loginMemberId");
        String loginMemberId = v == null ? null : v.toString();
        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin"); // null 가능

        model.addAttribute("post", postService.viewAndIncrease(id));

        int total = commentService.countByPost(id);
        List<PostCommentVO> comments = commentService.listByPostPaged(id, page, size);
        PageMeta pm = new PageMeta(page, size, total);

        model.addAttribute("comments", comments);
        model.addAttribute("pageMeta", pm);
        model.addAttribute("loginMemberId", loginMemberId);
        model.addAttribute("isAdmin", isAdmin != null && isAdmin);

        return "community/view";
    }

    // 댓글 작성
    @PostMapping("/comments")
    public String writeComment(@ModelAttribute CreateCommentVO form, HttpSession session,
            @RequestParam(name = "page", defaultValue = "1") int page) {
        Object v = session.getAttribute("loginMemberId");
        String loginId = v == null ? null : v.toString();
        form.setAuthorId(loginId);

        // 간단한 로그인 체크
        if (loginId == null || loginId.isEmpty()) {
            return "redirect:/login"; // 프로젝트 로그인 경로에 맞게 수정
        }

        commentService.write(form);
        return "redirect:/community/view/" + form.getPostId() + "?page=" + page;
    }

    // 댓글 삭제 (권한 비교: 작성자 또는 관리자만)
    @PostMapping("/comments/{commentId}/delete")
    public String deleteComment(@PathVariable("commentId") BigDecimal commentId,
            @RequestParam("postId") BigDecimal postId,
            @RequestParam(name = "page", defaultValue = "1") int page,
            HttpSession session) {

        String loginId = (String) session.getAttribute("loginMemberId");
        if (loginId == null || loginId.isEmpty()) {
            return "redirect:/login"; // 프로젝트 로그인 경로에 맞춰 변경
        }

        // 본인만 삭제: 작성자 비교
        PostCommentVO target = commentService.findOne(commentId);
        if (target != null && loginId.equals(target.getAuthorId())) {
            commentService.softDelete(commentId);
        }
        // 작성자 아니면 아무 일도 하지 않고 원래 페이지로 리다이렉트
        return "redirect:/community/view/" + postId + "?page=" + page;
    }

    private String getLoginId(HttpSession session) {
        Object v = session.getAttribute("loginMemberId"); // ← 여기 키 이름이 포인트
        return v == null ? null : v.toString();
    }

    @GetMapping("/write")
    public String writeForm(HttpSession session) {
        if (getLoginId(session) == null)
            return "redirect:/loginView?redirect=/community/write";
        return "community/write";
    }

    @PostMapping("/writeDo")
    public String writeDo(@ModelAttribute CommunityPostVO vo, HttpSession session, Model model) {
        String authorId = getLoginId(session);
        if (authorId == null)
            return "redirect:/loginView?redirect=/community/write";

        if (vo.getTitle() == null || vo.getTitle().trim().isEmpty() || vo.getTitle().length() > 300) {
            model.addAttribute("error", "제목은 1~300자로 입력하세요.");
            return "community/write";
        }
        if (vo.getContent() == null || vo.getContent().trim().isEmpty()) {
            model.addAttribute("error", "내용을 입력하세요.");
            return "community/write";
        }
        if (vo.getCategory() != null && vo.getCategory().length() > 50) {
            model.addAttribute("error", "카테고리는 50자 이내로 입력하세요.");
            return "community/write";
        }

        vo.setAuthorId(authorId);
        BigDecimal newId = postService.write(vo);
        return "redirect:/community/view/" + newId.toPlainString();
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable("id") BigDecimal id, HttpSession session, Model model) {
        String loginId = getLoginId(session);
        if (loginId == null)
            return "redirect:/loginView?redirect=/community/edit/" + id.toPlainString();

        CommunityPostVO post = postService.findOne(id);
        if (post == null || "Y".equals(post.getDelYn()))
            return "redirect:/community/list";

        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
        boolean canEdit = loginId.equals(post.getAuthorId()) || (isAdmin != null && isAdmin);
        if (!canEdit)
            return "redirect:/community/view/" + id.toPlainString();

        model.addAttribute("post", post);
        return "community/edit";
    }

    @PostMapping("/editDo")
    public String editDo(@ModelAttribute CommunityPostVO vo, HttpSession session, Model model) {
        String loginId = getLoginId(session);
        if (loginId == null)
            return "redirect:/loginView?redirect=/community/list";

        // 원본 조회
        CommunityPostVO origin = postService.findOne(vo.getPostId());
        if (origin == null || "Y".equals(origin.getDelYn()))
            return "redirect:/community/list";

        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
        boolean canEdit = loginId.equals(origin.getAuthorId()) || (isAdmin != null && isAdmin);
        if (!canEdit)
            return "redirect:/community/view/" + vo.getPostId().toPlainString();

        // 간단 검증
        if (vo.getTitle() == null || vo.getTitle().trim().isEmpty() || vo.getTitle().length() > 300) {
            model.addAttribute("error", "제목은 1~300자로 입력하세요.");
            model.addAttribute("post", origin);
            return "community/edit";
        }
        if (vo.getContent() == null || vo.getContent().trim().isEmpty()) {
            model.addAttribute("error", "내용을 입력하세요.");
            model.addAttribute("post", origin);
            return "community/edit";
        }
        if (vo.getCategory() != null && vo.getCategory().length() > 50) {
            model.addAttribute("error", "카테고리는 50자 이내로 입력하세요.");
            model.addAttribute("post", origin);
            return "community/edit";
        }

        // 업데이트
        postService.update(vo.getPostId(), vo.getTitle(), vo.getContent(), vo.getCategory());
        return "redirect:/community/view/" + vo.getPostId().toPlainString();
    }

    @PostMapping("/delete/{id}")
    public String deletePost(@PathVariable("id") BigDecimal id, HttpSession session) {
        String loginId = getLoginId(session);
        if (loginId == null)
            return "redirect:/loginView?redirect=/community/view/" + id.toPlainString();

        CommunityPostVO post = postService.findOne(id);
        if (post == null)
            return "redirect:/community/list";

        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
        boolean canDelete = loginId.equals(post.getAuthorId()) || (isAdmin != null && isAdmin);
        if (!canDelete)
            return "redirect:/community/view/" + id.toPlainString();

        postService.softDelete(id);
        return "redirect:/community/list";
    }
}