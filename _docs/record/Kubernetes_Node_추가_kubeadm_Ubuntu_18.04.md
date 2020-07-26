---
title: Kubernetes Node 추가 / kubeadm 이용 / Ubuntu 18.04 환경
category: Record
date: 2020-07-26T12:00:00Z
lastmod: 2020-07-26T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

설치 환경은 다음과 같다.
* HyperV
  * Master Node : Ubuntu Desktop 18.04.1 64bit : 1대
  * Worker Node : Ubuntu Server 18.04.1 64bit : 2대
* Docker : 19.03.1
* Kubernetes 1.15.3
  * Network Plugin : calico or flannel or cilium 이용
  * Dashboard Addon : Dashboard 이용
* kubeadm 1.15.3
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* Password
  * Kubernetes 설치에 필요한 Password는 간편한 설치를 위해 **root**로 통일한다.
* 모든 Node에서 root User로 설치를 진행한다.

### 2. Package 설치

~~~console
(Added Node)# apt-get update && apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
(Added Node)# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
(Added Node)# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
(Added Node)# apt-get update && sudo apt-get install docker-ce=5:19.03.1~3-0~ubuntu-bionic docker-ce-cli containerd.io
~~~

추가할 Node에 Docker를 설치한다.

~~~console
(Added Node)# apt-get update && apt-get install -y apt-transport-https curl
(Added Node)# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
(Added Node)# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
(Added Node)# apt-get update && apt-get install -y kubeadm=1.15.3-00 kubelet=1.15.3-00
~~~

추가할 Node에 kubeadm과 kubelet을 설치한다.

### 3. Node 추가

#### 3.1. Master Node

~~~console
(Master Node)# kubeadm token create
4n1agp.j97evoelu2k35dre
(Master Node)# kubeadm token list
TOKEN                     TTL       EXPIRES                USAGES                   DESCRIPTION   EXTRA GROUPS
4n1agp.j97evoelu2k35dre   23h       2020-07-27T08:03:59Z   authentication,signing   <none>        system:bootstrappers:kubeadm:default-node-token
~~~

kubeadm을 이용하여 Token을 생성한다.

~~~console
(Master Node)# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
060896fc4bfe949304b8c1af7b23bb5c4e60e6d242722ce5bd02fe4cbc94aabe
~~~

CA 인증서의 Hash값을 얻는다.

#### 3.2. Added Worker Node

~~~console
(Added Node)# kubeadm join 30.0.0.34:6443 --token 4n1agp.j97evoelu2k35dre --discovery-token-ca-cert-hash sha256:060896fc4bfe949304b8c1af7b23bb5c4e60e6d242722ce5bd02fe4cbc94aabe
~~~

kubeadm으로 생성한 Token과 CA 인증서의 Hash 값을 이용하여 Cluster에 Join한다. 30.0.0.34은 Master Node의 IP이다.

### 4. Node 추가 확인

~~~console
(Master Node)# kubectl get nodes
NAME   STATUS   ROLES    AGE    VERSION
vm01   Ready    master   236d   v1.15.3
vm02   Ready    <none>   236d   v1.15.3
vm03   Ready    <none>   236d   v1.15.3
vm04   Ready    <none>   101s   v1.15.3
~~~

Master Node에서 추가된 Node를 확인한다. Node04가 추가된 Node이다.

### 5. 참조

* [https://sarc.io/index.php/cloud/1383-join-token](https://sarc.io/index.php/cloud/1383-join-token)