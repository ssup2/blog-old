---
title: lsof
category: Command, Tool
date: 2019-09-14T12:00:00Z
lastmod: 2019-09-14T12:00:00Z
comment: true
adsense: true
---

Open File List를 출력하는 Tool인 lsof 사용법을 정리한다.

### 1. lsof

* lsof : 모든 Open File List를 출력한다.
* lsof -u [User] : 특정 User가 Open하고 있는 File List를 출력한다.
* loof +D [Dir] : 특정 Director의 하위에 있는 Open File List만 출력한다.
* lsof [File] : 특정 File을 Open하고 있는 Process의 정보를 출력한다.
* lsof -c [Binary, Tool] : 특정 Binary, Tool이 Open하고 있는 File List를 출력한다.

* lsof -i TCP : TCP를 이용하고 있는 Process의 정보를 출력한다.
* lsof -i UDP : UDP를 이용하고 있는 Process의 정보를 출력한다.
* lsof -i TCP:[Port Num] : TCP, 특정 Port를 이용하고 있는 Process의 정보를 출력한다.
* lsof -i UDP:[Port Num] : UDP, 특정 Port를 이용하고 있는 Process의 정보를 출력한다.
