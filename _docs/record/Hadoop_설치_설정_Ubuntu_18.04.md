---
title: Hadoop 설치, 설정 - Ubuntu 18.04
category: Record
date: 2018-06-20T12:00:00Z
lastmod: 2018-06-20T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Ubuntu 18.04 LTS 64bit, root user
* Java openjdk version "1.8.0_171"
* Hadoop 3.0.3

### 2. sshd 설치, 설정

* sshd 설치

~~~
# apt update
# apt install -y openssh-server
# apt install -y pdsh
~~~

* /etc/ssh/sshd_config 파일에 아래와 같이 수정하여 root Login 허용

~~~
...
#LoginGraceTime 2m
PermitRootLogin yes
#StrictModes yes
...
~~~

* sshd 재시작 및 ssh 접속시 password가 불필요하도록 설정

~~~
# service sshd restart
# ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# chmod 0600 ~/.ssh/authorized_keys
# echo "ssh" > /etc/pdsh/rcmd_default
# ssh localhost

...
Are you sure you want to continue connecting (yes/no)? yes
~~~

### 3. Java 설치 

* Java Package 설치

~~~
# apt update
# apt install -y openjdk-8-jdk
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
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
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
export HADOOP_HOME="/root/hadoop-3.0.3"
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME

export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"
~~~

* HDFS Format 및 HDFS 시작

~~~
# hdfs namenode -format
# start-dfs.sh
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
</configuration>
~~~

* YARN 시작 

~~~
# start-yarn.sh
~~~

* YARN 동작 확인 
  * Web Browser에서 http://localhost:8088 접속

### 6. 동작 확인

* 6개의 JVM이 동작 확인

~~~
# jps
3988 NameNode
5707 Jps
5355 NodeManager
4203 DataNode
4492 SecondaryNameNode
5133 ResourceManager
~~~

* Example 구동

~~~
# cd ~/hadoop-3.0.3
# yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-3.0.3.jar pi 16 1000
...
Estimated value of Pi is 3.14250000000000000000
~~~

### 7. Issue 해결

* There are 0 datanode(s) Error 발생시

~~~
# stop-yarn.sh
# stop-dfs.sh
# rm -rf /tmp/*
# start-dfs.sh
# start-yarn.sh
~~~

### 8. 참조

* [http://www.admintome.com/blog/installing-hadoop-on-ubuntu-17-10/](http://www.admintome.com/blog/installing-hadoop-on-ubuntu-17-10/)
* [https://data-flair.training/blogs/installation-of-hadoop-3-x-on-ubuntu/](https://data-flair.training/blogs/installation-of-hadoop-3-x-on-ubuntu/)
