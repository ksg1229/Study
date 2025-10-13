package com.study.free.sync.vo;

public class Participant {
	//참가자 (메모리용)
	private String sessionId;
	private String name;
	private String role; // host|member
	
	public Participant() {
	}

	public String getSessionId() {
		return sessionId;
	}

	public void setSessionId(String sessionId) {
		this.sessionId = sessionId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	@Override
	public String toString() {
		return "Participant [sessionId=" + sessionId + ", name=" + name + ", role=" + role + "]";
	}
	
	
	
	
}
