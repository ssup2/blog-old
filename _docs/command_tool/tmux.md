---
title: tmux
category: Command, Tool
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

tmux 사용법을 정리한다.

### 1. tmux

#### 1.1. Session 단축키

* tmux new -s [session-name] : Session 생성
* tmux ls : Session 목록
* tmux attach -t [session-name or session-number] : Session Attach
* ctrl + b, d : Session Detach

#### 1.2. Window 단축키

* ctrl + b, c : Window 생성
* ctrl + b, 0~9 : 번호 Windows로 이동
* ctrl + b, n : 다음 Windows로 이동
* ctrl + b, p : 이전 Windows로 이동
* ctrl + b, l : 마지막 Windows로 이동
* ctrl + b, w : Window Selector 실행

#### 1.3. Pane

* ctrl + b, % : 횡 분활
* ctrl + b, " : 종 분활
* ctrl + b, 방향키 : Pane 이동

#### 1.4. ETC

* ctrl + b, ? : 단축키 목록

### 2. 참조

* https://edykim.com/ko/post/tmux-introductory-series-summary/