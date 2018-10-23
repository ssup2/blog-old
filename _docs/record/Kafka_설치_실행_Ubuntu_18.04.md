---
title: Kafka 설치,설정 - Ubuntu 18.04
category: Record
date: 2018-10-20T12:00:00Z
lastmod: 2018-10-20T12:00:00Z
comment: true
adsense: true
---

### 1. 설정 환경

* Ubuntu 18.04 LTS 64bit, root user

### 2. Java, Zookeeper 설치

* Java, Zookeeper Package 설치

~~~
# apt install openjdk-8-jdk -y
# apt install zookeeperd -y
~~~

### 3. Kafka 설치

* kafka 계정 생성
  * Password : kafka

~~~
# useradd -d /opt/kafka -s /bin/bash kafka
# passwd kafka
Enter new UNIX password: kafka
Retype new UNIX password: kafka
~~~

* Kafka Download 및 압축풀기

~~~
# cd /opt
# wget http://www-eu.apache.org/dist/kafka/2.0.0/kafka_2.11-2.0.0.tgz
# mkdir -p /opt/kafka
# tar -xf kafka_2.11-2.0.0.tgz -C /opt/kafka --strip-components=1
# chown -R kafka:kafka /opt/kafka
~~~

* /opt/kafka/config/server.properties 파일의 마지막에 아래의 내용을 추가

~~~
...
delete.topic.enable = true
~~~

* /lib/systemd/system/zookeeper.service에 아래의 내용 저장 

~~~
[Unit]
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=kafka
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
~~~

* /lib/systemd/system/kafka.service에 아래의 내용 저장

~~~
[Unit]
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
ExecStart=/bin/sh -c '/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties'
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
~~~

* Zookeeper, Kafka 시작

~~~
# systemctl daemon-reload
# systemctl start zookeeper
# systemctl enable zookeeper
# systemctl start kafka
# systemctl enable kafka
~~~

* Zookeeper, Kafka 구동 확인
  * Zookeeper : 2181 Port 이용
  * Kafka : 9092 Port 이용

~~~
# netstat -plntu
...
tcp6       0      0 :::9092                 :::*                    LISTEN      3005/java
tcp6       0      0 :::2181                 :::*                    LISTEN      2372/java
~~~

### 4. Kafka Test

* HakaseTesting Topic 생성

~~~
# su - kafka
$ cd bin/
$ ./kafka-topics.sh --create --zookeeper localhost:2181 \
--replication-factor 1 --partitions 1 \
--topic HakaseTesting
~~~

* 새로운 Terminal을 띄워 Producer 실행

~~~
# su - kafka
$ cd bin/
$ ./kafka-console-producer.sh --broker-list localhost:9092 \
--topic HakaseTesting
> test 123
~~~

* 새로운 Terminal을 띄워 Consumer 실행

~~~
# su - kafka
$ cd bin/
$ ./kafka-console-consumer.sh --bootstrap-server localhost:9092 \
--topic HakaseTesting --from-beginning
> test 123
~~~

### 5. 참조

* [https://www.howtoforge.com/tutorial/ubuntu-apache-kafka-installation/](https://www.howtoforge.com/tutorial/ubuntu-apache-kafka-installation/)