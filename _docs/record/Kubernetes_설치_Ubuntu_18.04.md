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

![[그림 1] Kubernetes 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Kubernetes_Install_Ubuntu_18.04/Node_Setting.PNG)

* VirtualBox를 이용하여 위의 그림과 같이 가상의 Master, Worker Node (VM)을 생성한다.
* Hostname : Master Node - node1, Worker Node1 - node2, Worker Node2 - node3
* NAT : Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* Router : 공유기를 이용하여 192.168.0.0/24 Network를 구축한다. (NAT)

#### 2.1. Master Node

* Master Node의 /etc/netplan/50-cloud-init.yaml 파일을 아래와 같이 설정한다.

<figure>
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
<figcaption class="caption">[파일 1] Master Node의 /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

#### 2.2. Worker Node

* Worker Node 01의 /etc/netplan/50-cloud-init.yaml 파일을 아래와 같이 설정한다.

<figure>
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
<figcaption class="caption">[파일 2] Worker Node 01의 /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

* Worker Node 02의 /etc/netplan/50-cloud-init.yaml 파일을 아래와 같이 설정한다.

<figure>
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
<figcaption class="caption">[파일 3] Worker Node 02의 /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

### 3. Package 설치

* 모든 Node에서 수행 Kubernetes를 위한 Package를 설치한다.

* Swap을 Off한다.
  * /etc/fstab 파일에서 아래와 같이 swap.img 주석 처리한다.

~~~
# /swap.img       none    swap    sw      0       0
~~~

* Docker를 설치한다.

~~~
# apt-get update
# apt-get install -y docker.io
~~~

* kubelet, kubeadm를 설치한다.

~~~
# apt-get update && apt-get install -y apt-transport-https curl
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
# apt-get update
# apt-get install -y kubeadm=1.12.3-00 kubelet=1.12.3-00
~~~

### 4. Cluster 구축

#### 4.1. Master Node

* kubeadm를 초기화 한다.
  * Docker Version으로 인한 Error가 발생하면 kubeadm init 마지막에 '--ignore-preflight-errors=SystemVerification'를 붙인다.

~~~
# swapoff -a
# kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=192.167.0.0/16 --kubernetes-version=v1.12.0
...
kubeadm join 10.0.0.10:6443 --token x7tk20.4hp9x2x43g46ara5 --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

* kubectl config를 설정한다.

~~~
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~

* kubectl autocomplete를 설정한다.
  * /root/.bashrc에 다음의 내용 추가한다.

~~~
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

source <(kubectl completion bash)
~~~

#### 4.2. Worker Node

* Cluster를 구성한다.
  * kubeadm init 결과로 나온 **kubeadm join ~~** 명령어를 모든 Worker Node에서 수행한다.
  * Docker Version으로 인한 Error가 발생하면 kubeadm join 마지막에 '--ignore-preflight-errors=SystemVerification'를 붙인다.

~~~
# swapoff -a
# kubeadm join 10.0.0.10:6443 --token 46i2fg.yoidccf4k485z74u --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

#### 4.3. 검증

* Master Node에서 Cluster를 확인한다.
  * 모든 Node가 List에서 보여야 한다.
  * Network 설정이 안되어 있기 때문에 NotReady 상태로 유지된다. Network Plugin 설치후 Ready 상태를 확인 가능하다.

~~~
# kubectl get nodes
NAME    STATUS     ROLES    AGE   VERSION
node1   NotReady   master   84s   v1.12.3
node2   NotReady   <none>   31s   v1.12.3
node3   NotReady   <none>   27s   v1.12.3
~~~

### 5. Network Plugin 설치

* Calico, Flannel, Cilium 3개의 Network Plugin인 중에서 하나를 선택하여 설치한다.
* 만약 다른 Network Plugin으로 교체할 경우 모든 Node에서 kubeadm reset 명령어로 초기화를 진행한다.

#### 5.1. Master Node

##### 5.1.1. Calico 설치

* Calico를 설치한다.

~~~
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
~~~

##### 5.1.2. Flannel 설치

* Flannel를 설치한다.

~~~
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
~~~

##### 5.1.3. Cilium 설치

* bpffs mount 및 설정을 진행한다.

~~~
# mount bpffs /sys/fs/bpf -t bpf
# echo "bpffs                      /sys/fs/bpf             bpf     defaults 0 0" >> /etc/fstab
~~~

* Cilium Download 및 Cilium 구동을 위한 etcd를 설치한다.

~~~
# wget https://github.com/cilium/cilium/archive/v1.3.0.zip
# unzip v1.3.0.zip
# kubectl apply -f cilium-1.3.0/examples/kubernetes/addons/etcd/standalone-etcd.yaml
~~~

* Cilium 설정을 변경하여 Prefilter 기능을 활성화 한다.
  * prefilter Interface는 Kubernets Cluster Network를 구성하는 NIC의 Interface를 지정해야한다.
  * Kubernets Cluster Network를 구성하는 NIC의 Device Driver가 XDP를 지원하지 않으면 --prefilter-mode에 generic 설정을 추가해야 한다.

<figure>
{% highlight yaml %}
# vim cilium-1.3.0/examples/kubernetes/1.12/cilium.yaml
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
<figcaption class="caption">[파일 4] cilium-1.3.0/examples/kubernetes/1.12/cilium.yaml</figcaption>
</figure>

* Cilium을 설치한다.

~~~
# kubectl apply -f cilium-1.3.0/examples/kubernetes/1.12/cilium.yaml
~~~

#### 5.2. Worker Node

##### 5.2.1. Cilium 설치

* bpffs mount 및 설정을 진행한다.

~~~
# mount bpffs /sys/fs/bpf -t bpf
# echo "bpffs                      /sys/fs/bpf             bpf     defaults 0 0" >> /etc/fstab
~~~

### 6. Web UI (Dashboard) 설치

#### 6.1 Master Node

* Web UI 설치를 진행한다.

~~~
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
~~~

* kube-apiserver Insecure 설정
  * /etc/kubernetes/manifests/kube-apiserver.yaml 파일의 command에 아래의 내용을 수정 및 추가한다.

<figure>
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
<figcaption class="caption">[파일 5] /etc/kubernetes/manifests/kube-apiserver.yaml</figcaption>
</figure>

* kubelet Service를 재시작한다.

~~~
# service kubelet restart
~~~

* Web UI Privilege 권한을 위한 config 파일을 생성한다.
  * 아래의 내용으로 ~/dashboard-admin.yaml 파일을 생성한다. 

<figure>
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
<figcaption class="caption">[파일 6] ~/dashboard-admin.yaml</figcaption>
</figure>

* Web UI에 Privilege 권한을 적용한다.

~~~
# kubectl create -f ~/dashboard-admin.yaml
# rm ~/dashboard-admin.yaml
~~~

* Web UI 접속
  * http://192.168.0.150:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login
  * 접속 후 Skip Click

### 7. Ceph RDB 연동

#### 7.1 Master Node

* Ceph 정보
  * Monitor IP - 10.0.0.10:6789
  * Pool Name - kube

* Ceph Admin secret을 생성한다.

~~~
# ceph auth get client.admin 2>&1 |grep "key = " |awk '{print  $3'} |xargs echo -n > /tmp/secret
# kubectl create secret generic ceph-admin-secret --from-file=/tmp/secret --namespace=kube-system
~~~

* Ceph Pool 및 User secret을 생성한다.

~~~
# ceph osd pool create kube 8 8
# ceph auth add client.kube mon 'allow r' osd 'allow rwx pool=kube'
# ceph auth get-key client.kube > /tmp/secret
# kubectl create secret generic ceph-secret --from-file=/tmp/secret --namespace=kube-system
~~~

* rbd-provisioner, role, cluster role yaml을 Download 한다.

~~~
# git clone https://github.com/kubernetes-incubator/external-storage.git
# cd external-storage/ceph/rbd/deploy
~~~

* rbac/clusterrole.yaml 파일에 아래의 내용 추가한다. (Secret Role)

<figure>
{% highlight yaml %}
...
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "create", "delete"]
{% endhighlight %}
<figcaption class="caption">[파일 7] rbac/clusterrole.yaml</figcaption>
</figure>

* rbd-provisioner, role, cluster role을 설정한다.

~~~
# NAMESPACE=default
# sed -r -i "s/namespace: [^ ]+/namespace: $NAMESPACE/g" ./rbac/clusterrolebinding.yaml ./rbac/rolebinding.yaml
# kubectl -n $NAMESPACE apply -f ./rbac 
~~~

* storage_class.yaml 파일 생성 및 아래의 내용으로 저장한다.

<figure>
{% highlight yaml %}
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: kube
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ceph.com/rbd
parameters:
  monitors: 10.0.0.10:6789
  pool: kube
  adminId: admin
  adminSecretNamespace: kube-system
  adminSecretName: ceph-admin-secret
  userId: kube
  userSecretNamespace: kube-system
  userSecretName: ceph-secret
  imageFormat: "2"
  imageFeatures: layering
{% endhighlight %}
<figcaption class="caption">[파일 8] storage_class.yaml</figcaption>
</figure>

* Storage Class 생성 및 확인한다.

~~~
# kubectl create -f ./storage_class.yaml
# kubectl get storageclasses.storage.k8s.io
NAME            PROVISIONER    AGE
rbd (default)   ceph.com/rbd   19m
~~~

### 8. 참조

* Kubernetes 설치 - [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* Docker 설치 - [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* Calio, Flannel, Cilium 설치 - [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)
* Web UI 설치 - [https://github.com/kubernetes/dashboard/wiki/Access-control#basic](https://github.com/kubernetes/dashboard/wiki/Access-control#basic)
* Ceph RDB 연동 - [https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd](https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd)
* Ceph RDB 연동 - [http://blog.51cto.com/ygqygq2/2163656](http://blog.51cto.com/ygqygq2/2163656)
