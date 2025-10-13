package com.study.free.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.*;
import com.study.free.ws.SyncHandler;
import com.study.free.ws.SyncHandshakeInterceptor;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final SyncHandler handler;
    private final SyncHandshakeInterceptor interceptor;

    public WebSocketConfig(SyncHandler handler, SyncHandshakeInterceptor interceptor) {
        this.handler = handler;
        this.interceptor = interceptor;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry reg) {
        reg.addHandler(handler, "/ws/sync")
           .addInterceptors(interceptor)
           .setAllowedOrigins("*"); // 필요시 고정 오리진으로
    }
}
