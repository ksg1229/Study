package com.study.free.ws;

import java.util.Map;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

@Component
public class SyncHandshakeInterceptor implements HandshakeInterceptor {
    @Override
    public boolean beforeHandshake(ServerHttpRequest req, ServerHttpResponse res,
                                   WebSocketHandler wsh, Map<String, Object> attrs) {
        // 쿼리파라미터 파싱
        String q = req.getURI().getQuery(); // room=...&name=...&role=...
        if (q != null) {
            for (String kv : q.split("&")) {
                String[] p = kv.split("=",2);
                if (p.length==2) {
                    String k=p[0], v=decode(p[1]);
                    attrs.put(k, v);
                }
            }
        }
        return true;
    }

    @Override
    public void afterHandshake(ServerHttpRequest req, ServerHttpResponse res,
                               WebSocketHandler wsh, Exception ex) { }

    private String decode(String s) {
        try { return java.net.URLDecoder.decode(s, "UTF-8"); }
        catch(Exception e){ return s; }
    }
}
