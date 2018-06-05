---
title: Kubernetes 설치 - Ubuntu 16.04
category: Record
date: 2017-07-20T12:00:00Z
lastmod: 2017-07-20T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* VirtualBox 5.0.14r
  * Master Node - Ubuntu Desktop 16.04.2 64bit - 1대
  * Worker Node - Ubuntu Server 16.04.2 64bit - 2대
* Kubernetes
  * Network Addon - flannel 이용
  * Dashboard Addon - Dashboard 이용
* kubeadm
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* Docker 1.12.6
  * Kubernetes에서 1.12.x Version을 권장하고 있다.
* Password
  * Kubernetes 설치에 필요한 Password는 간편한 설치를 위해 **root**로 통일한다.
* 모든 Node에서 root User로 설치를 진행한다.

### 2. Node 설정

![]({{site.baseurl}}/images/record/Kubernetes_Install/Node_Setting.PNG)

* VirtualBox를 이용하여 위의 그림과 같이 가상의 Master, Worker Node (VM)을 생성한다.
* Kubernetes의 Dashboard는 기본적으로 Master의 Web Browser에서만 이용할 수 있다. 따라서 Master Node에는 Ubuntu Desktop Version을 설치한다.
* NAT - Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0/24 Network를 구축한다.
* Router - 공유기를 이용하여 192.168.77.0/24 Network를 구축한다. (NAT)

#### 2.1. Master Node

* /etc/network/interfaces을 다음과 같이 수정

~~~
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.11
netmask 255.255.255.0
gateway 10.0.0.1
dns-nameservers 8.8.8.8

auto enp0s8
iface enp0s8 inet static
address 192.168.77.170
netmask 255.255.255.0
gateway 192.168.77.1
dns-nameservers 8.8.8.8
~~~

#### 2.2. Worker Node

* Worker Node 01의 /etc/network/interfaces을 다음과 같이 수정

~~~
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.31
netmask 255.255.255.0
gateway 10.0.0.1
dns-nameservers 8.8.8.8
~~~

* Worker Node 02의 /etc/network/interfaces을 다음과 같이 수정

~~~
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.41
netmask 255.255.255.0
gateway 10.0.0.1
dns-nameservers 8.8.8.8
~~~

### 3. Package 설치

#### 3.1. 모든 Node

* Docker 설치

~~~
# sudo apt-get update
# sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# sudo apt-get update
# sudo apt-get install docker.io=1.12.6-0ubuntu1~16.04.1
~~~

* kubelet, kubeadm 설치

~~~
# apt-get update && apt-get install -y apt-transport-https
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
# apt-get update
# apt-get install -y kubelet kubeadm
~~~

#### 3.2. Master Node

* kubectl 설치

~~~
# sudo snap install kubectl --classic
~~~

### 4. Cluster 구축

#### 4.1. Master Node

* kubeadm 초기화 (Cluster 생성)
  * 실행 후 Key 값을 얻을 수 있다.
  * 10.0.0.11는 Master NAT 네트워크 IP이다.

~~~
# kubeadm init --apiserver-advertise-address=10.0.0.11 --pod-network-cidr=10.244.0.0/16
...
kubeadm join --token 76f75a.6fbcc5e0e6e74c89 10.0.0.11:6443
~~~

* kubectl config 설정

~~~
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~

* kubectl autocomplete 설정
  * /root/.bashrc에 다음의 내용 추가

~~~
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

source <(kubectl completion bash)
~~~

* Network Addon (flannel) 설치

~~~
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
~~~

* Dashboard Addon (Dashboard) 설치

~~~
# kubectl create -f https://git.io/kube-dashboard
~~~

#### 4.2. Worker Node

* Cluster 참여
  * kubeadm init 결과로 나온 명령어 각 Worker Node에서 수행한다.

~~~
# kubeadm join --token 76f75a.6fbcc5e0e6e74c89 10.0.0.11:6443
~~~

#### 4.3. 검증

* Master Node에서 Cluster 확인

~~~
# kubectl get nodes
NAME       STATUS     AGE       VERSION
ubuntu01   Ready      41m       v1.7.1
ubuntu02   Ready      49s       v1.7.1
ubuntu03   Ready      55s       v1.7.1
~~~

* Master Node에서 Dashboard 접속
  * 아래 명령어 실행 후 Master Node에서 Web Brower를 통해 **http://localhost:8001/ui** 접속

~~~
# kubectl proxy
~~~

### 5. 참조

* Kubernetes 설치 - [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* Docker 설치 - [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* flannel Issue -  [https://github.com/coreos/flannel/issues/671](https://github.com/coreos/flannel/issues/671)
