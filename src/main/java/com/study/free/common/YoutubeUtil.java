package com.study.free.common;


import java.util.regex.*;

public class YoutubeUtil {
    private static final Pattern[] PATTERNS = new Pattern[]{
        Pattern.compile("v=([a-zA-Z0-9_-]{11})"),
        Pattern.compile("youtu\\.be/([a-zA-Z0-9_-]{11})"),
        Pattern.compile("embed/([a-zA-Z0-9_-]{11})")
    };

    public static String extractVideoId(String urlOrId){
        if (urlOrId == null) return null;
        String s = urlOrId.trim();
        if (s.matches("^[a-zA-Z0-9_-]{11}$")) return s;
        for (Pattern p : PATTERNS) {
            Matcher m = p.matcher(s);
            if (m.find()) return m.group(1);
        }
        return null;
    }
}