---
title: Cassandra 설치, 설정 / Ubuntu 18.04
category: Record
date: 2018-10-23T12:00:00Z
lastmod: 2018-10-23T12:00:00Z
comment: true
adsense: true
---

### 1. 설치, 실행 환경

설정, 실행 환경은 다음과 같다.
* Ubuntu 18.04 LTS 64bit, root user

### 2. Java 설치

~~~
# add-apt-repository -y ppa:webupd8team/java
# apt update
# apt install -y oracle-java8-installer
~~~

Java 8를 설치한다.

### 3. Cassandra 설치

~~~
# echo "deb http://www.apache.org/dist/cassandra/debian 39x main" |  tee /etc/apt/sources.list.d/cassandra.list
# curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
# apt update
# apt install cassandra
~~~

Cassandra Package를 설치한다.

~~~
# systemctl enable cassandra
# systemctl start cassandra
# systemctl -l status cassandra
● cassandra.service - LSB: distributed storage system for structured data
   Loaded: loaded (/etc/init.d/cassandra; generated)
   Active: active (running) since Tue 2018-10-23 13:59:47 UTC; 19min ago
     Docs: man:systemd-sysv-generator(8)
  Process: 6375 ExecStop=/etc/init.d/cassandra stop (code=exited, status=0/SUCCESS)
  Process: 6392 ExecStart=/etc/init.d/cassandra start (code=exited, status=0/SUCCESS)
    Tasks: 43 (limit: 4915)
   CGroup: /system.slice/cassandra.service
           └─6545 java -Xloggc:/var/log/cassandra/gc.log -ea -XX:+UseThreadPriorities -XX:ThreadPriorityPolicy=42 -XX:+HeapDumpOnOutOfMemoryError -Xss256k -X

Oct 23 13:59:47 ubuntu_1804_server_01 systemd[1]: Stopped LSB: distributed storage system for structured data.
Oct 23 13:59:47 ubuntu_1804_server_01 systemd[1]: Starting LSB: distributed storage system for structured data...
Oct 23 13:59:47 ubuntu_1804_server_01 systemd[1]: Started LSB: distributed storage system for structured data.
~~~

Cassandra 구동 및 구동을 확인한다.

### 4. 참조

* [http://cassandra.apache.org/download/](http://cassandra.apache.org/download/)
* [https://hostadvice.com/how-to/how-to-install-apache-cassandra-on-an-ubuntu-18-04-vps/](https://hostadvice.com/how-to/how-to-install-apache-cassandra-on-an-ubuntu-18-04-vps/)