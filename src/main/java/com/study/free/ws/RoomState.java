package com.study.free.ws;

public class RoomState {
    private volatile String videoId = "dQw4w9WgXcQ";
    private volatile double positionSec = 0;
    private volatile boolean playing = false;
    private volatile long lastUpdateMillis = System.currentTimeMillis();
    private volatile boolean wbOpen = false;

    public synchronized void load(String vid){ videoId=vid; positionSec=0; playing=false; lastUpdateMillis=System.currentTimeMillis(); }
    public synchronized void playAt(double at){ positionSec=at; playing=true; lastUpdateMillis=System.currentTimeMillis(); }
    public synchronized void pauseAt(double at){ positionSec=at; playing=false; lastUpdateMillis=System.currentTimeMillis(); }
    public synchronized void seekTo(double to){ positionSec=to; lastUpdateMillis=System.currentTimeMillis(); }
    public synchronized void tick(double at){ positionSec=at; playing=true; lastUpdateMillis=System.currentTimeMillis(); }
    public synchronized void setWbOpen(boolean open){ wbOpen=open; }

    public synchronized double currentPosition(){
        if(!playing) return positionSec;
        long now=System.currentTimeMillis();
        double delta=(now-lastUpdateMillis)/1000.0;
        return Math.max(0, positionSec+delta);
    }
    public synchronized Snapshot snapshot(){ return new Snapshot(videoId, currentPosition(), playing, wbOpen); }
    public synchronized void freeze(){ positionSec=currentPosition(); playing=false; lastUpdateMillis=System.currentTimeMillis(); }

    public static class Snapshot {
        public final String videoId; public final double at; public final boolean playing; public final boolean wbOpen;
        public Snapshot(String videoId,double at,boolean playing,boolean wbOpen){
            this.videoId=videoId; this.at=at; this.playing=playing; this.wbOpen=wbOpen;
        }
    }
}
