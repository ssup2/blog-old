---
title: Kubernetes 설치 - Ubuntu 18.04
category: Record
date: 2018-07-15T12:00:00Z
lastmod: 2018-07-15T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* VirtualBox 5.0.14r
  * Master Node - Ubuntu Desktop 18.04 64bit - 1대
  * Worker Node - Ubuntu Server 18.04 64bit - 1대
* Kubernetes 1.11
  * Network Addon - calico or flannel 이용
  * Dashboard Addon - Dashboard 이용
* kubeadm
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* Docker 1.12.6
  * Kubernetes에서 1.12.x Version을 권장하고 있다.
* Password
  * Kubernetes 설치에 필요한 Password는 간편한 설치를 위해 **root**로 통일한다.
* 모든 Node에서 root User로 설치를 진행한다.

### 2. Node 설정

![]({{site.baseurl}}/images/record/Kubernetes_Install_Ubuntu18.04/Node_Setting.PNG)

* VirtualBox를 이용하여 위의 그림과 같이 가상의 Master, Worker Node (VM)을 생성한다.
* Kubernetes의 Dashboard는 기본적으로 Master의 Web Browser에서만 이용할 수 있다. 따라서 Master Node에는 Ubuntu Desktop Version 또는 X Server를 이용한다.
* NAT - Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* Router - 공유기를 이용하여 192.168.0.0/24 Network를 구축한다. (NAT)

#### 2.1. Master Node

* /etc/netplan directory의 모든 파일을 삭제하고 /etc/netplan/01-network.yaml 파일 작성

~~~
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.10/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
        enp0s8:
            dhcp4: no
            addresses: [192.168.0.150/24]
            gateway4: 192.168.0.1
            nameservers:
                addresses: [8.8.8.8]
~~~

#### 2.2. Worker Node

* Worker Node 01의 /etc/netplan directory의 모든 파일을 삭제하고 /etc/netplan/01-network.yaml 파일 작성

~~~
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.20/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
~~~

* Worker Node 02의 /etc/netplan directory의 모든 파일을 삭제하고 /etc/netplan/01-network.yaml 파일 작성

~~~
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.30/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
~~~

### 3. Package 설치

#### 3.1. 모든 Node

* Docker 설치

~~~
# apt-get update
# apt-get install -y docker.io

# sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# sudo apt-get update
# sudo apt-get install docker.io=1.12.6-0ubuntu1~16.04.1
~~~

* kubelet, kubeadm 설치

~~~
# apt-get update && apt-get install -y apt-transport-https curl
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

### 4. Cluster 구축 Calico

#### 4.1. Master Node

* Calio, Flannel 둘중 하나를 선택하여 설치

#### 4.1.1. Calico 설치

* kubeadm 초기화 (Cluster 생성)
  * 실행 후 Key 값을 얻을 수 있다.
  * 10.0.0.10는 Master NAT 네트워크 IP이다.

~~~
# swapoff -a
# kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v1.11.0
...
kubeadm join 10.0.0.10:6443 --token x7tk20.4hp9x2x43g46ara5 --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
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

* Calico 설치

~~~
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
~~~

* Dashboard Addon (Dashboard) 설치

~~~
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
~~~

#### 4.1.2. Flannel 설치

* kubeadm 초기화 (Cluster 생성)
  * 실행 후 Key 값을 얻을 수 있다.
  * 10.0.0.11는 Master NAT 네트워크 IP이다.

~~~
# kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.11.0
...
kubeadm join 10.0.0.10:6443 --token 46i2fg.yoidccf4k485z74u --discovery-token-ca-cert-hash sha256:7faf874316231b4455882f400064a9861c2d446bdf6512802a4b633a04ec44f2
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

* Flannel 설치

~~~
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
~~~

* Dashboard Addon (Dashboard) 설치

~~~
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
~~~

#### 4.2. Worker Node

* Cluster 참여
  * kubeadm init 결과로 나온 명령어 Worker Node에서 수행한다.

~~~
# swapoff -a
# kubeadm join 10.0.0.10:6443 --token 46i2fg.yoidccf4k485z74u --discovery-token-ca-cert-hash sha256:7faf874316231b4455882f400064a9861c2d446bdf6512802a4b633a04ec44f2
~~~

#### 4.3. 검증

* Master Node에서 Cluster 확인

~~~
# kubectl get nodes
NAME                STATUS    ROLES     AGE       VERSION
supsup-virtualbox   Ready     master    21m       v1.11.1
ubuntu01            Ready     <none>    1m        v1.11.1
ubuntu02            Ready     <none>    1m        v1.11.1
~~~

* Master Node에서 Dashboard 접속
  * 아래 명령어 실행 후 Master Node에서 Web Brower를 통해 **http://localhost:8001/ui** 접속

~~~
# kubectl proxy
~~~

### 5. 참조

* Kubernetes 설치 - [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* Docker 설치 - [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* Calio 설치 - [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)
* Flannel 설치 - [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)