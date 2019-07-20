---
title: Kubernetes 설치 / kubespray 이용 / Ubuntu 18.04, OpenStack 환경
category: Record
date: 2019-07-20T12:00:00Z
lastmod: 2019-07-20T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] Kubernetes 설치 환경]({{site.baseurl}}/images/record/Kubernetes_kubespray_Ubuntu_18.04_OpenStack/Environment.PNG)

* VM : Ubuntu 18.04, 2 vCPU, 4GB Memory
  * Master Node * 1
  * Slave Node * 2
  * Deploy Node * 1
* Kubernetes
  * CNI : Cilium Plugin
* kubespray : 2.10.4

### 2. Ubuntu Package 설치

~~~
(Deploy)# apt-get install software-properties-common
(Deploy)# apt-add-repository ppa:ansible/ansible
(Deploy)# apt-get update
(Deploy)# apt-get install python3-pip
(Deploy)# pip3 install -r requirements.txt
~~~

Deploy Node에 Python을 설치한다.

### 3. Ansible 설정

~~~
(Deploy)# ssh-keygen -t rsa
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

Deploy Node에서 ssh key를 생성한다. passphrase (Password)는 공백을 입력하여 설정하지 않는다. 설정하게 되면 Deploy Node에서 Managed Node로 SSH를 통해서 접근 할때마다 passphrase를 입력해야 한다.

~~~
(Deploy)# ssh-copy-id root@node01
(Deploy)# ssh-copy-id root@node02
(Deploy)# ssh-copy-id root@node03
~~~

Deploy Node에서 ssh-copy-id 명령어를 이용하여 생성한 ssh Public Key를 나머지 Node의 ~/.ssh/authorized_keys 파일에 복사한다.

### 4. kubespray 설정, 구동

~~~
# git clone -b v2.10.4 https://github.com/kubernetes-sigs/kubespray.git
# cd kubespray
# cp -rfp inventory/sample inventory/mycluster
# declare -a IPS=(10.0.0.7 10.0.0.3 10.0.0.15)
# CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
~~~

kubespray를 설치하고 기본설정을 진행한다.

{% highlight text %}
...
kube_network_plugin: cilium
...
persistent_volumes_enabled: true
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Deploy Node - inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml</figcaption>
</figure>

Deploy Node의 inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml 파일을 변경하여 CNI Plugin으로 cilium을 이용하도록 설정하고, Persistent Volume을 Enable 설정하여 Kubernetes가 OpenStack의 Cinder를 이용하도록 설정한다.

~~~
# ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml
~~~

Kubernets Cluster를 구성한다.

### 5. Octavia 연동

### 6. Kubernetes Cluster 초기화

~~~
# ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root reset.yml
~~~

Kubernetes Cluster를 초기화한다.

### 7. 참고

* [https://kubespray.io/#/](https://kubespray.io/#/)