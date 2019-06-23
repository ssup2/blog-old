---
title: Ansible 설치, 실행 - Ubuntu 18.04
category: Record
date: 2019-06-23T12:00:00Z
lastmod: 2019-06-23T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] Ansible 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Ansible_Install_Ubuntu_18.04/Node_Setting.PNG){: width="600px"}

* Ubuntu 18.04 LTS 64bit, root user
* Ansible 2.5.1

### 2. Ansible 설치

~~~
# apt-get install software-properties-common 
# apt-add-repository ppa:ansible/ansibl
# apt-get update 
# apt-get install ansible
~~~

Control Node에 Ansible을 설치한다.

### 3. SSH Key 생성 및 설정

~~~
# ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Sp0SUDPNKxTIYVObstB0QQPoG/csF9qe/v5+S5e8hf4 root@kube02
The key's randomart image is:
+---[RSA 2048]----+
|   oBB@=         |
|  .+o+.*o        |
| .. o.+  .       |
|  o..ooo..       |
|   +.=ooS        |
|  . o.=o     . o |
|     +..    . = .|
|      o    ..o o |
|     ..oooo...o.E|
+----[SHA256]-----+
~~~

Contorl Node에서 ssh key를 생성한다. passphrase (Password)는 공백을 입력하여 설정하지 않는다. 설정하게 되면 Control Node에서 Managed Node로 SSH를 통해서 접근 할때마다 passphrase를 입력해야 한다.

~~~
# ssh-copy-id root@172.35.0.101 
# ssh-copy-id root@172.35.0.102
~~~

ssh-copy-id 명령어를 이용하여 생성한 ssh Public Key를 모든 Managed Node의 ~/.ssh/authorized_keys 파일에 복사한다. 

### 4. Ansible 구동

~~~
# ansible all -m ping
172.35.0.101 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.35.0.102 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
~~~

ansible all -m ping 명령어를 이용하여 Control Node에서 Managed Node로 ssh 접속이 가능한지 확인한다.

### 5. 참조

* [https://docs.ansible.com/ansible/latest/installation_guide/index.html](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
