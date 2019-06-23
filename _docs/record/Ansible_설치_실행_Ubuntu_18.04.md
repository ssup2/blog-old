---
title: Ansible 설치, 실행 - Ubuntu 18.04
category: Record
date: 2019-06-21T12:00:00Z
lastmod: 2019-06-21T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] Ansible 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Ansible_Install_Ubuntu_18.04/Node_Setting.PNG){: width="600px"}

* Ubuntu 18.04 LTS 64bit, root user

### 2. Ansible 설치

#### 2.1. Control Node

~~~
# apt-get install software-properties-common 
# apt-add-repository ppa:ansible/ansibl
# apt-get update 
# apt-get install ansible
~~~

Control Node에 Ansible을 설치한다.

### 3. SSH

### 4. 참조

* [https://docs.ansible.com/ansible/latest/installation_guide/index.html](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
