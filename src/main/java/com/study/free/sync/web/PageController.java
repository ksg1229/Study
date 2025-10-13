package com.study.free.sync.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class PageController {

  @GetMapping("/sync/page")
  public String page(@RequestParam String room,
                     @RequestParam String role,
                     @RequestParam String name,
                     Model m){
    m.addAttribute("room", room);
    m.addAttribute("role", role);
    m.addAttribute("name", name);
    m.addAttribute("title", "스터디 세션");
    return "study-session";
  }
}