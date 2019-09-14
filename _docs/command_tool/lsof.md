---
title: lsof
category: Command, Tool
date: 2019-09-14T12:00:00Z
lastmod: 2019-09-14T12:00:00Z
comment: true
adsense: true
---

Open File List를 출력하는 lsof의 사용법을 정리한다.

### 1. lsof

* lsof : 모든 Open File List를 출력한다.
* lsof -u [User] : [User]가 Open하고 있는 File List를 출력한다.
* loof +D [Dir] : [Director]의 하위에 있는 Open File List만 출력한다.
* lsof [File] : [File]을 Open하고 있는 Process의 정보를 출력한다.
* lsof -c [Binary, Tool] : [Binary, Tool]이 Open하고 있는 File List를 출력한다.

* lsof -i TCP : TCP를 이용하고 있는 Process의 정보를 출력한다.
* lsof -i TCP:[Port] : TCP, [Port]를 이용하고 있는 Process의 정보를 출력한다.
* lsof -i TCP:[Port Start]-[Port End] : 
* lsof -i UDP : UDP를 이용하고 있는 Process의 정보를 출력한다.
* lsof -i UDP:[Port] : UDP, [Port]를 이용하고 있는 Process의 정보를 출력한다.
