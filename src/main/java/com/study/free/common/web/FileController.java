package com.study.free.common.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.multiaction.MultiActionController;

@Controller
public class FileController {

	@Value("#{util['file.upload.path']}")
	private String CURR_IMAGE_PATH;

	@Value("#{util['file.download.path']}")
	private String WEB_PATH;

	@RequestMapping("/download")
	public void download(String imageFileName, HttpServletResponse resp) throws IOException {
	    // 실제 파일 경로
	    File file = new File(CURR_IMAGE_PATH, imageFileName).getCanonicalFile();

	    if (!file.exists() || !file.isFile()) {
	        resp.sendError(HttpServletResponse.SC_NOT_FOUND, "file not found");
	        return;
	    }

	    // ===== 1) Content-Disposition: ASCII fallback + RFC5987 UTF-8 =====
	    // ASCII 대체(따옴표/역슬래시 이스케이프 포함)
	    String asciiFallback = imageFileName.replaceAll("[^\\x20-\\x7E]", "_").replace("\\", "_");
	    // RFC5987용 UTF-8 퍼센트 인코딩(공백은 %20 유지)
	    String encodedUtf8 = java.net.URLEncoder.encode(imageFileName, java.nio.charset.StandardCharsets.UTF_8)
	            .replace("+", "%20");

	    String contentDisposition = "attachment; filename=\"" + asciiFallback + "\"; filename*=UTF-8''" + encodedUtf8;

	    // ===== 2) 기타 헤더 =====
	    String mime = java.nio.file.Files.probeContentType(file.toPath());
	    if (mime == null) mime = "application/octet-stream";

	    resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
	    resp.setHeader("Pragma", "no-cache");
	    resp.setDateHeader("Expires", 0);
	    resp.setHeader("Content-Disposition", contentDisposition);
	    resp.setContentType(mime);
	    resp.setContentLengthLong(file.length());

	    // ===== 3) 파일 스트리밍 =====
	    try (InputStream in = new FileInputStream(file);
	         OutputStream out = resp.getOutputStream()) {
	        byte[] buffer = new byte[8192];
	        int n;
	        while ((n = in.read(buffer)) != -1) {
	            out.write(buffer, 0, n);
	        }
	        out.flush();
	    }
	}

	@RequestMapping("/multiImgUpload")
	public void multiImgUpload(HttpServletRequest req, HttpServletResponse res) {
		try {
			// 저장 후 이미지 저장 정보 전달
			String sFileInfo = "";
			String fileName = req.getHeader("file-name");
			String prifix = fileName.substring(fileName.lastIndexOf(".") + 1);
			prifix = prifix.toLowerCase();
			// 저장될 이름
			String realName = UUID.randomUUID().toString().replace("-", "") + "." + prifix;
			InputStream is = req.getInputStream();
			OutputStream os = new FileOutputStream(new File(CURR_IMAGE_PATH + "\\" + realName));
			int read = 0;
			byte b[] = new byte[1024];
			while ((read = is.read(b)) != -1) {
				os.write(b, 0, read);
			}
			if (is != null) {
				is.close();
			}
			os.flush();
			os.close();
			// smart edit 규칙
			sFileInfo += "&bNewLine=true";
			sFileInfo += "&sFileName=" + fileName;
			sFileInfo += "&sFileURL=" + WEB_PATH + realName;
			PrintWriter print = res.getWriter();
			print.print(sFileInfo);
			print.flush();
			print.close();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@PostMapping("/uploadChatImage")
	@ResponseBody
	public Map<String, String> uploadChatImage(MultipartFile file) throws IllegalStateException, IOException {
		Map<String, String> result = new HashMap<>();
		if (file != null && !file.isEmpty()) {
			String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
			File f = new File(CURR_IMAGE_PATH, fileName);
			file.transferTo(f);
			result.put("imagePath", WEB_PATH + fileName);
		}
		return result;

	}

}