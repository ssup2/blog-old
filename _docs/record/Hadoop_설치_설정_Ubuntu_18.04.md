---
title: Hadoop 설치, 설정 - Ubuntu 18.04
category: Record
date: 2018-06-20T12:00:00Z
lastmod: 2018-06-20T12:00:00Z
comment: true
adsense: true
---

### 1. 설정 환경

* Ubuntu 18.04 LTS 64bit, root user
* Java openjdk 10.0.1 2018-04-17
* Hadoop 3.0.3
* HDFS 설치를 위한 별도의 Disk - /dev/sdb

### 2. sshd 설치, 설정

* sshd 설치

~~~
# apt update
# apt install openssh-server
~~~

* /etc/ssh/sshd_config 파일에 아래와 같이 수정하여 root Login 허용

~~~
#LoginGraceTime 2m
PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10
~~~

* sshd 재시작 및 ssh 접속시 password가 불필요하도록 설정

~~~
# service sshd restart
# ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# chmod 0600 ~/.ssh/authorized_keys
# ssh localhost

...
Are you sure you want to continue connecting (yes/no)? yes
~~~

### 3. Java 설치 

* Java Package 설치

~~~
# apt update
# apt install -y apt install default-jdk
# apt apt-get install openssh-server
~~~

### 4. Hadoop 설치, 설정

* Hadoop Binary Download

~~~
# cd ~
# wget http://mirror.navercorp.com/apache/hadoop/common/hadoop-3.0.3/hadoop-3.0.3.tar.gz
# tar zxvf hadoop-3.0.3.tar.gz
~~~

* ~/hadoop-3.0.3/etc/hadoop/hadoop-env.sh 파일을 아래와 같이 수정

~~~
# The java implementation to use. By default, this environment
# variable is REQUIRED on ALL platforms except OS X!
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
~~~

* ~/hadoop-3.0.3/etc/hadoop/core-site.xml 파일을 아래와 같이 수정

~~~
<configuration>
	<property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
~~~

* ~/hadoop-3.0.3/etc/hadoop/hdfs-site.xml 파일을 아래와 같이 수정

~~~
<configuration>
	<property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
~~~

* ~/.bashrc 파일에 아래의 환경변수 추가

~~~
export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"
~~~


* HDFS Format 및 HDFS 시작

~~~
# cd ~/hadoop-3.0.3
# bin/hdfs namenode -format
# sbin/start-dfs.sh
~~~

* HDFS 동작 확인 
  * Web Browser에서 http://localhost:9870 접속

### 5. YARN 설치, 설정

* root user 폴더 생성

~~~
# cd ~/hadoop-3.0.
# bin/hdfs dfs -mkdir /user
# bin/hdfs dfs -mkdir /user/root
~~~

* ~/hadoop-3.0.3/etc/hadoop/mapred-site.xml 파일을 아래와 같이 수정

~~~
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
~~~

* ~/hadoop-3.0.3/etc/hadoop/yarn-site.xml 파일을 아래와 같이 수정

~~~
<configuration>
    <property>
    	<name>yarn.nodemanager.aux-services</name>
    	<value>mapreduce_shuffle</value>
    </property>
    <property>
    	<name>yarn.nodemanager.vmem-check-enabled</name>
    	<value>false</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=/root/hadoop-3.0.3</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=/root/hadoop-3.0.3</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=/root/hadoop-3.0.3</value>
    </property>
</configuration>
~~~

* YARN 시작 

~~~
# cd ~/hadoop-3.0.3
# sbin/start-yarn.sh
~~~

* YARN 동작 확인 
  * Web Browser에서 http://localhost:8088 접속

### 6. 참조

* [http://www.admintome.com/blog/installing-hadoop-on-ubuntu-17-10/](http://www.admintome.com/blog/installing-hadoop-on-ubuntu-17-10/)
