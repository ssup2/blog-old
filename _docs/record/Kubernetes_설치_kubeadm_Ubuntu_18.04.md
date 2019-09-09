---
title: Kubernetes 설치 / kubeadm 이용 / Ubuntu 18.04 환경
category: Record
date: 2018-07-15T12:00:00Z
lastmod: 2019-06-04T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

설치 환경은 다음과 같다.
* VirtualBox 5.0.14r
  * Master Node : Ubuntu Desktop 18.04.1 64bit : 1대
  * Worker Node : Ubuntu Server 18.04.1 64bit : 2대
* Kubernetes 1.12
  * Network Plugin : calico or flannel or cilium 이용
  * Dashboard Addon : Dashboard 이용
* kubeadm 1.12
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* Password
  * Kubernetes 설치에 필요한 Password는 간편한 설치를 위해 **root**로 통일한다.
* 모든 Node에서 root User로 설치를 진행한다.

### 2. Node 설정

![[그림 1] Kubernetes 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Kubernetes_Install_kubeadm_Ubuntu_18.04/Node_Setting.PNG)

VirtualBox를 이용하여 [그림 1]과 같이 가상의 Master, Worker Node (VM)을 생성한다.
* Hostname : Master Node - node1, Worker Node1 - node2, Worker Node2 - node3
* NAT : Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* Router : 공유기를 이용하여 192.168.0.0/24 Network를 구축한다. (NAT)

#### 2.1. Master Node

{% highlight yaml %}
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
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Master Node - /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Master Node의 /etc/netplan/50-cloud-init.yaml 파일을 [파일 1]과 같이 설정한다.

#### 2.2. Worker Node

{% highlight yaml %}
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.20/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Worker Node 01 - /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Worker Node 01의 /etc/netplan/50-cloud-init.yaml 파일을 [파일 2]와 같이 설정한다.

{% highlight yaml %}
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.30/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Worker Node 02 - /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Worker Node 02의 /etc/netplan/50-cloud-init.yaml 파일을 [파일 3]과 같이 설정한다.

### 3. Package 설치

모든 Node에서 Kubernetes를 위한 Package를 설치한다.

~~~
(All)# apt-get update
(All)# apt-get install -y docker.io
~~~

Docker를 설치한다.

~~~
(All)# apt-get update && apt-get install -y apt-transport-https curl
(All)# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
(All)# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
(All)# apt-get update
(All)# apt-get install -y kubeadm=1.12.3-00 kubelet=1.12.3-00
~~~

kubelet, kubeadm를 설치한다.

### 4. Cluster 구축

#### 4.1. Master Node

Cluster 구축을 위한 kubeadm 명령어의 옵션은 이용할 Network Plugin에 따라 달라진다. 따라서 Cluster 구축전 Calico, Flannel, Cilium 3개의 Network Plugin인 중에서 이용할 Network Plugin을 하나를 선택해야 한다. 선택한 Network Plugin 항목에 있는 명령어와 공통 항목 명령어를 실행하여 Cluster를 구축한다.

##### 4.1.1. Calico 기반 구축

~~~
(Master)# swapoff -a
(Master)# sed -i '/swap.img/s/^/#/' /etc/fstab
(Master)# kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v1.12.0
...
kubeadm join 10.0.0.10:6443 --token x7tk20.4hp9x2x43g46ara5 --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

kubeadm를 초기화 한다. --pod-network-cidr는 반드시 **192.168.0.0/16**으로 설정해야 한다. Docker Version으로 인한 Error가 발생하면 kubeadm init 마지막에 '--ignore-preflight-errors=SystemVerification'를 붙인다.

##### 4.1.1. Flannel 기반 구축

~~~
(Master)# swapoff -a
(Master)# sed -i '/swap.img/s/^/#/' /etc/fstab
(Master)# kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.12.0
...
kubeadm join 10.0.0.10:6443 --token x7tk20.4hp9x2x43g46ara5 --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

kubeadm를 초기화 한다. --pod-network-cidr는 반드시 **10.244.0.0/16**으로 설정해야 한다. Docker Version으로 인한 Error가 발생하면 kubeadm init 마지막에 '--ignore-preflight-errors=SystemVerification'를 붙인다.

##### 4.1.3. Cilium 기반 구축

~~~
(Master)# swapoff -a
(Master)# sed -i '/swap.img/s/^/#/' /etc/fstab
(Master)# kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=192.167.0.0/16 --kubernetes-version=v1.12.0
...
kubeadm join 10.0.0.10:6443 --token x7tk20.4hp9x2x43g46ara5 --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

kubeadm를 초기화 한다. --pod-network-cidr는 --pod-network-cidr와 중복만 되지 않으면 된다. 위에서는 --pod-network-cidr를 192.167.0.0/16으로 설정하였다. Docker Version으로 인한 Error가 발생하면 kubeadm init 마지막에 '--ignore-preflight-errors=SystemVerification'를 붙인다.

##### 4.1.4. 공통

~~~
(Master)# mkdir -p $HOME/.kube
(Master)# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
(Master)# sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~

kubectl config를 설정한다.

~~~
(Master)# kubectl taint nodes --all node-role.kubernetes.io/master-
~~~

Master Node에도 Pod이 생성될 수 있도록 설정한다.

{% highlight text %}
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

source <(kubectl completion bash)
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] Master Node - ~/.bashrc</figcaption>
</figure>

kubectl autocomplete를 설정한다. ~/.bashrc에 [파일 4]의 내용을 추가한다.

#### 4.2. Worker Node

~~~
(Worker)# swapoff -a
(Worker)# sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
(Worker)# kubeadm join 10.0.0.10:6443 --token 46i2fg.yoidccf4k485z74u --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

Cluster를 구성한다. kubeadm init 결과로 나온 **kubeadm join ~~** 명령어를 모든 Worker Node에서 수행한다. Docker Version으로 인한 Error가 발생하면 kubeadm join 마지막에 '--ignore-preflight-errors=SystemVerification'를 붙인다.

#### 4.3. 검증

~~~
(Master)# kubectl get nodes
NAME    STATUS     ROLES    AGE   VERSION
node1   NotReady   master   84s   v1.12.3
node2   NotReady   <none>   31s   v1.12.3
node3   NotReady   <none>   27s   v1.12.3
~~~

Master Node에서 Cluster를 확인한다. 모든 Node가 List에서 보여야 한다. Network 설정이 안되어 있기 때문에 NotReady 상태로 유지된다. Network Plugin 설치후 Ready 상태를 확인 가능하다.

### 5. Network Plugin 설치

Cluster 구축시 선택했던 Network Plugin만 설치한다.

#### 5.1. Master Node

##### 5.1.1. Calico 설치

~~~
(Master)# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
(Master)# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
~~~

Calico를 설치한다.

##### 5.1.2. Flannel 설치

~~~
(Master)# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
~~~

Flannel를 설치한다.

##### 5.1.3. Cilium 설치

~~~
(Master)# mount bpffs /sys/fs/bpf -t bpf
(Master)# echo "bpffs                      /sys/fs/bpf             bpf     defaults 0 0" >> /etc/fstab
~~~

bpffs mount 및 설정을 진행한다.

~~~
(Master)# wget https://github.com/cilium/cilium/archive/v1.3.0.zip
(Master)# unzip v1.3.0.zip
(Master)# kubectl apply -f cilium-1.3.0/examples/kubernetes/addons/etcd/standalone-etcd.yaml
~~~

Cilium Download 및 Cilium 구동을 위한 etcd를 설치한다.

{% highlight yaml %}
...
      containers:
        - image: docker.io/cilium/cilium:v1.3.0
          imagePullPolicy: IfNotPresent
          name: cilium-agent
          command: ["cilium-agent"]
          args:
            - "--debug=$(CILIUM_DEBUG)"
            - "--kvstore=etcd"
            - "--kvstore-opt=etcd.config=/var/lib/etcd-config/etcd.config"
            - "--disable-ipv4=$(DISABLE_IPV4)"
            - "--prefilter-device=enp0s3"
            - "--prefilter-mode=generic"
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] Master Node - cilium-1.3.0/examples/kubernetes/1.12/cilium.yaml</figcaption>
</figure>

Cilium 설정을 변경하여 Prefilter 기능을 활성화 한다. prefilter Interface는 Kubernets Cluster Network를 구성하는 NIC의 Interface를 지정해야한다. Kubernets Cluster Network를 구성하는 NIC의 Device Driver가 XDP를 지원하지 않으면 --prefilter-mode에 generic 설정을 추가해야 한다. cilium-1.3.0/examples/kubernetes/1.12/cilium.yaml 파일을 [파일 5]와 같이 변경한다.

~~~
(Master)# kubectl apply -f cilium-1.3.0/examples/kubernetes/1.12/cilium.yaml
~~~

Cilium을 설치한다.

#### 5.2. Worker Node

##### 5.1.1. Calico, Flannel 설치

Worker Node에서는 작업이 필요없다.

##### 5.2.2. Cilium 설치

~~~
(Worker)# mount bpffs /sys/fs/bpf -t bpf
(Worker)# echo "bpffs                      /sys/fs/bpf             bpf     defaults 0 0" >> /etc/fstab
~~~

bpffs mount 및 설정을 진행한다.

### 6. Web UI (Dashboard) 설치

#### 6.1 Master Node

~~~
(Master)# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
~~~

Web UI 설치를 진행한다.

{% highlight yaml %}
...
spec:
  containers:
  - command:
...
    - --insecure-bind-address=0.0.0.0
    - --insecure-port=8080
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] Master Node - /etc/kubernetes/manifests/kube-apiserver.yaml</figcaption>
</figure>

kube-apiserver에 Insecure Option을 설정한다. /etc/kubernetes/manifests/kube-apiserver.yaml 파일의 command에 [파일 6]의 내용으로 수정한다.

~~~
(Master)# service kubelet restart
~~~

kubelet Service를 재시작한다.

{% highlight yaml %}
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
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 7] Master Node - ~/dashboard-admin.yaml</figcaption>
</figure>

Web UI Privilege 권한을 위한 config 파일을 생성한다. [파일 7]의 내용으로 ~/dashboard-admin.yaml 파일을 생성한다.

~~~
(Master)# kubectl create -f ~/dashboard-admin.yaml
(Master)# rm ~/dashboard-admin.yaml
~~~

Web UI에 Privilege 권한을 적용하고 접속하여 확인한다. Web UI 접속후 Skip을 누른다.
* http://192.168.0.150:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login

### 7. 참조

* Kubernetes 설치 : [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* Docker 설치 : [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* Calio, Flannel, Cilium 설치 : [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)
* Web UI 설치 : [https://github.com/kubernetes/dashboard/wiki/Access-control#basic](https://github.com/kubernetes/dashboard/wiki/Access-control#basic)
