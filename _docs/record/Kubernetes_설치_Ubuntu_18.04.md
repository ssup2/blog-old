---
title: Kubernetes 설치 - Ubuntu 18.04
category: Record
date: 2018-07-15T12:00:00Z
lastmod: 2018-12-18T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* VirtualBox 5.0.14r
  * Master Node - Ubuntu Desktop 18.04.1 64bit - 1대
  * Worker Node - Ubuntu Server 18.04.1 64bit - 2대
* Kubernetes 1.12
  * Network Addon - calico or flannel or cilium 이용
  * Dashboard Addon - Dashboard 이용
* kubeadm 1.12
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* Password
  * Kubernetes 설치에 필요한 Password는 간편한 설치를 위해 **root**로 통일한다.
* 모든 Node에서 root User로 설치를 진행한다.

### 2. Node 설정

![]({{site.baseurl}}/images/record/Kubernetes_Install_Ubuntu_18.04/Node_Setting.PNG)

* VirtualBox를 이용하여 위의 그림과 같이 가상의 Master, Worker Node (VM)을 생성한다.
* Hostname : Master Node - node1, Worker Node1 - node2, Worker Node2 - node3
* NAT : Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* Router : 공유기를 이용하여 192.168.0.0/24 Network를 구축한다. (NAT)

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

* 모든 Node에서 수행
* Swap Off
  * /etc/fstab 파일에서 아래와 같이 swap.img 주석 처리

~~~
# /swap.img       none    swap    sw      0       0
~~~

* Docker 설치

~~~
# apt-get update
# apt-get install -y docker.io
~~~

* kubelet, kubeadm 설치

~~~
# apt-get update && apt-get install -y apt-transport-https curl
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
# apt-get update
# apt-get install -y kubeadm=1.12.3-00 kubelet=1.12.3-00
~~~

### 4. Cluster 구축

#### 4.1. Master Node

* kubeadm 초기화

~~~
# swapoff -a
# kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=192.167.0.0/16 --kubernetes-version=v1.12.0
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

#### 4.2. Worker Node

* Cluster 참여
  * kubeadm init 결과로 나온 명령어 Worker Node에서 수행한다.

~~~
# swapoff -a
# kubeadm join 10.0.0.10:6443 --token 46i2fg.yoidccf4k485z74u --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

#### 4.3. 검증

* Master Node에서 Cluster 확인
  * 모든 Node가 Ready 상태가 되야한다.

~~~
# kubectl get nodes
NAME      STATUS   ROLES    AGE     VERSION
node1     Ready    master   9m1s    v1.12.3
node2     Ready    <none>   8m37s   v1.12.3
node3     Ready    <none>   8m40s   v1.12.3
~~~

### 5. Network Plugin 설치

* Calico, Flannel, Cilium 셋중 하나를 선택하여 설치
* 만약 다른 Network Plugin으로 교체할 경우 모든 Node에서 kubeadm reset 명령어로 초기화 진행

#### 5.1. Master Node

##### 5.1.1. Calico 설치

* Calico 설치

~~~
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
~~~

##### 5.1.2. Flannel 설치

* Flannel 설치

~~~
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
~~~

##### 5.1.3. Cilium 설치

* bpffs mount 및 설정

~~~
# mount bpffs /sys/fs/bpf -t bpf
# echo "bpffs                      /sys/fs/bpf             bpf     defaults 0 0" >> /etc/fstab
~~~

* Cilium을 위한 etcd 구동 및 Cilium 설치

~~~
# wget https://github.com/cilium/cilium/archive/v1.3.0.zip
# unzip v1.3.0.zip
# kubectl create -f cilium-1.3.0/examples/kubernetes/addons/etcd/standalone-etcd.yaml
# kubectl create -f cilium-1.3.0/examples/kubernetes/1.12/cilium.yaml
~~~

#### 5.2. Worker Node

##### 5.2.1. Cilium 설치

* bpffs mount 및 설정

~~~
# mount bpffs /sys/fs/bpf -t bpf
# echo "bpffs                      /sys/fs/bpf             bpf     defaults 0 0" >> /etc/fstab
~~~

### 6. Web UI (Dashboard) 설치

#### 6.1 Master Node

* Web UI 설치

~~~
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
~~~

* kube-apiserver Insecure 설정
  * /etc/kubernetes/manifests/kube-apiserver.yaml 파일의 command에 아래의 내용 수정 & 추가

~~~
...
spec:
  containers:
  - command:
...
    - --insecure-bind-address=0.0.0.0
    - --insecure-port=8080
...
~~~

* kubelet Service 재시작

~~~
# service kubelet restart
~~~

* Web UI Privilege 권한을 위한 config 파일 생성
  * 아래의 내용으로 ~/dashboard-admin.yaml 파일 생성 

~~~
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
~~~

* Web UI에 Privilege 권한 적용

~~~
# kubectl create -f ~/dashboard-admin.yaml
# rm ~/dashboard-admin.yaml
~~~

* Web UI 접속
  * http://192.168.0.150:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login
  * 접속 후 Skip Click

### 7. 참조

* Kubernetes 설치 - [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* Docker 설치 - [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* Calio, Flannel, Cilium 설치 - [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)
* Web UI 설치 - https://github.com/kubernetes/dashboard/wiki/Access-control#basic
