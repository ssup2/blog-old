---
title: Grafana 설치,실행 - Ubuntu 18.04
category: Record
date: 2019-01-03T12:00:00Z
lastmod: 2019-01-03T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Ubuntu 18.04 LTS 64bit, root user
* Node IP : 192.168.0.150

### 2. Grafana 설치

* /etc/apt/sources.list에 다음의 내용 추가

~~~
deb https://packagecloud.io/grafana/stable/debian/ stretch main
~~~

* Grafana 설치

~~~
# curl https://packagecloud.io/gpg.key | sudo apt-key add -
# apt-get update
# apt-get install grafana
~~~

* Grafana 실행

~~~
# systemctl daemon-reload
# systemctl start grafana-server
# systemctl status grafana-server
# systemctl enable grafana-server.service
~~~

* 접속 확인
  * http://192.168.0.150:3000/login
  * ID, PW - admin/admin

### 3. 참조

* [http://docs.grafana.org/installation/debian/](http://docs.grafana.org/installation/debian/)
