---
title: Kubernetes 설치 / kubeadm 이용 / Ubuntu 18.04, Jetson Nano Cluster 환경
category: Record
date: 2020-04-19T12:00:00Z
lastmod: 2020-04-19T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

![[그림 1] Kubernetes 설치 환경 (Jetson Nano Cluster)]({{site.baseurl}}/images/record/Kubernetes_Install_kubeadm_Ubuntu_18.04_Jetson_Nano_Cluster/Environment.PNG)

[그림 1]은 Jetson Nano Cluster 기반 Kubernetes 설치 환경을 나타내고 있다. 상세한 환경 정보는 다음과 같다.

* Kubernetes 1.18.2
  * Network Plugin : calico or flannel or cilium 이용
  * Dashboard Addon : Dashboard 이용
* kubeadm 1.18.2
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* CNI
  * flannel 0.12.0
* Docker 19.03
* Node
  * Jetson Nano
    * r32.3.1 (Ubuntu 18.04)
    * Node 01 : Master Node
    * Node 02, 03, 04 : Worker Node

### 2. Node 설정

#### 2.1. All Node

~~~console
(All)# apt-get remove docker docker.io containerd runc nvidia-docker2
(All)# apt-get update
(All)# apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
(All)# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
(All)# add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
(All)# apt-get update
(All)# apt-get install docker-ce docker-ce-cli containerd.io
~~~

GPU 이용을 위해서 Docker 19.03 Version을 설치한다.

~~~console
(All)# apt-get update && apt-get install -y apt-transport-https curl
(All)# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
(All)# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
(All)# apt-get update
(All)# apt-get install -y kubelet=1.18.2-00 kubeadm=1.18.2-00
~~~

kubelet, kubeadm을 설치한다.

~~~console
(All)# swapoff -a
(All)# rm /etc/systemd/nvzramconfig.sh
~~~

zram을 Disable 한다.

#### 2.2. Master Node

~~~console
(Master)# kubeadm init --apiserver-advertise-address=192.168.0.41 --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.18.2
...
kubeadm join 10.0.0.10:6443 --token x7tk20.4hp9x2x43g46ara5 --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
(Master)# mkdir -p $HOME/.kube
(Master)# cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
(Master)# chown $(id -u):$(id -g) $HOME/.kube/config
~~~

Master Node에서 Cluster를 초기화 한다.

#### 2.3. Worker Node

~~~console
(Worker)# kubeadm join 10.0.0.10:6443 --token x7tk20.4hp9x2x43g46ara5 --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

Worker Node에서 Master Node에서 출력 되었던 "kubeadm join" 명령어를 통해서 Worker를 Cluster에 추가한다.

#### 2.4. 검증

~~~console
(Master)# kubectl get nodes
NAME       STATUS     ROLES    AGE    VERSION
jetson01   NotReady   master   7m2s   v1.18.2
jetson02   NotReady   <none>   72s    v1.18.2
jetson03   NotReady   <none>   62s    v1.18.2
jetson04   NotReady   <none>   59s    v1.18.2
~~~

Master Node에서 Cluster를 확인한다. 모든 Node가 List에서 보여야 한다. Network 설정이 안되어 있기 때문에 NotReady 상태로 유지된다. Network Plugin 설치후 Ready 상태를 확인 가능하다.

### 3. Flannel Network Plugin 설치

~~~console
(Master)# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.12.0/Documentation/kube-flannel.yml
~~~

Master Node에서 flannel Network Plugin을 설치한다.

~~~console
(Master) # kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
jetson01   Ready    master   18m   v1.18.2
jetson02   Ready    <none>   12m   v1.18.2
jetson03   Ready    <none>   12m   v1.18.2
jetson04   Ready    <none>   12m   v1.18.2
~~~

모든 Node가 Ready 상태인것을 확인할 수 있다.

### 4. 참조

* Docker 설치 : [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* NVIDIA Toolkit 설치 : [https://github.com/NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker)
* NVIDIA GPU Query : [https://github.com/NVIDIA/nvidia-docker/wiki/NVIDIA-Container-Runtime-on-Jetson](https://github.com/NVIDIA/nvidia-docker/wiki/NVIDIA-Container-Runtime-on-Jetson)