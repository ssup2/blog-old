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

* Java, Zookeeper Package를 설치한다.

~~~
# apt install openjdk-8-jdk -y
# apt install zookeeperd -y
~~~

### 3. Kafka 설치

* kafka 계정을 생성한다.
  * Password : kafka

~~~
# useradd -d /opt/kafka -s /bin/bash kafka
# passwd kafka
Enter new UNIX password: kafka
Retype new UNIX password: kafka
~~~

* Kafka Download 및 압축을 푼다.

~~~
# cd /opt
# wget http://www-eu.apache.org/dist/kafka/2.0.0/kafka_2.11-2.0.0.tgz
# mkdir -p /opt/kafka
# tar -xf kafka_2.11-2.0.0.tgz -C /opt/kafka --strip-components=1
# chown -R kafka:kafka /opt/kafka
~~~

* /opt/kafka/config/server.properties 파일의 마지막에 아래의 내용을 추가한다.

<figure>
{% highlight text %}
...
delete.topic.enable = true
{% endhighlight %}
<figcaption class="caption">[파일 1] /opt/kafka/config/server.properties</figcaption>
</figure>

* /lib/systemd/system/zookeeper.service에 아래의 내용을 저장한다.

<figure>
{% highlight text %}
...

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
{% endhighlight %}
<figcaption class="caption">[파일 2] /lib/systemd/system/zookeeper.service</figcaption>
</figure>

* /lib/systemd/system/kafka.service에 아래의 내용을 저장한다.

<figure>
{% highlight text %}
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
{% endhighlight %}
<figcaption class="caption">[파일 3] /lib/systemd/system/kafka.service</figcaption>
</figure>

* Zookeeper, Kafka를 시작한다.

~~~
# systemctl daemon-reload
# systemctl start zookeeper
# systemctl enable zookeeper
# systemctl start kafka
# systemctl enable kafka
~~~

* Zookeeper, Kafka 구동을 확인한다.
  * Zookeeper : 2181 Port 이용
  * Kafka : 9092 Port 이용

~~~
# netstat -plntu
...
tcp6       0      0 :::9092                 :::*                    LISTEN      3005/java
tcp6       0      0 :::2181                 :::*                    LISTEN      2372/java
~~~

### 4. Kafka Test

* HakaseTesting Topic을 생성한다.

~~~
# su - kafka
$ cd bin/
$ ./kafka-topics.sh --create --zookeeper localhost:2181 \
--replication-factor 1 --partitions 1 \
--topic HakaseTesting
~~~

* 새로운 Terminal을 띄워 Producer를 실행한다.

~~~
# su - kafka
$ cd bin/
$ ./kafka-console-producer.sh --broker-list localhost:9092 \
--topic HakaseTesting
> test 123
~~~

* 새로운 Terminal을 띄워 Consumer를 실행한다.

~~~
# su - kafka
$ cd bin/
$ ./kafka-console-consumer.sh --bootstrap-server localhost:9092 \
--topic HakaseTesting --from-beginning
> test 123
~~~

### 5. 참조

* [https://www.howtoforge.com/tutorial/ubuntu-apache-kafka-installation/](https://www.howtoforge.com/tutorial/ubuntu-apache-kafka-installation/)