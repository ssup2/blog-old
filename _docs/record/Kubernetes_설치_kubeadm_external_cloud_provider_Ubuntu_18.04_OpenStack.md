---
title: Kubernetes 설치 / kubeadm, External Cloud Provider 이용 / Ubuntu 18.04, OpenStack 환경
category: Record
date: 2019-08-19T12:00:00Z
lastmod: 2019-08-19T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] Kubernetes 설치 환경]({{site.baseurl}}/images/record/Kubernetes_Install_kubeadm_External_Cloud_Provider_Ubuntu_18.04_OpenStack/Environment.PNG)

[그림 1]은 Kubernetes 설치 환경을 나타내고 있다. 설치 환경은 다음과 같다.
* VM : Ubuntu 18.04 (Cloud Version), 4 vCPU, 4GB Memory
  * ETCD Node * 1
  * Master Node * 1
  * Slave Node * 3
* Network
  * NAT Network : 192.168.0.0/24
  * Octavia Network : 20.0.0.0/24
  * Tenant Network : 30.0.0.0/24
* OpenStack : Stein
  * API Server : 192.168.0.40:5000
  * Octavia
* Kubernetes : 1.15.3
  * CNI : Cilium 1.5.6 Plugin
* External Cloud Provider
  * Octavia 연동 O
  * Cinder 연동 X

### 2. Ubuntu Package 설치

#### 2.1. All Node

모든 Node에서 Kubernetes를 위한 Package를 설치한다.

~~~
(All)# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
(All)# apt-get update
(All)# apt-get install -y docker-ce
~~~

Docker를 설치한다.

~~~
(All)# apt-get update && apt-get install -y apt-transport-https curl
(All)# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
(All)# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
(All)# apt-get update
(All)# apt-get install -y kubeadm=1.15.3-00 kubelet=1.15.3-00
~~~

kubelet, kubeadm를 설치한다.

### 3. Kubernetes Cluster 구축

#### 3.1. All Node

{% highlight text %}
...
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--cloud-provider=external --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] All Node - /etc/systemd/system/kubelet.service.d/10-kubeadm.conf</figcaption>
</figure>

모든 Node에서 /etc/systemd/system/kubelet.service.d/10-kubeadm.conf 파일의 내용을 [파일 1]의 내용처럼 수정하여 kubelet이 External Provider를 이용하도록 설정한다.

#### 3.2. Master Node

~~~
(Master)# kubeadm init --apiserver-advertise-address=30.0.0.11 --pod-network-cidr=192.167.0.0/16 --kubernetes-version=v1.15.3
...
kubeadm join 30.0.0.11:6443 --token x7tk20.4hp9x2x43g46ara5 --discovery-token-ca-cert-hash sha256:cab2cc0a4912164f45f502ad31f5d038974cf98ed10a6064d6632a07097fad79
~~~

kubeadm를 초기화 한다. --pod-network-cidr는 --pod-network-cidr와 중복만 되지 않으면 된다. 위에서는 --pod-network-cidr를 192.167.0.0/16으로 설정하였다.

~~~
(Master)# mkdir -p $HOME/.kube 
(Master)# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
(Master)# sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~

kubernetes config 파일을 설정한다.

#### 3.3. Worker Node

~~~
(Worker)# kubeadm join 30.0.0.11:6443 --token v40peg.uyrgkkmiu1rl6dmn --discovery-token-ca-cert-hash sha256:1474a36cdae4b45da503fd48b4a516e72040ad35fa8f0456edfcacf9cd954522
~~~

kubeadm init 결과로 나온 **kubeadm join ~~** 명령어를 모든 Worker Node에서 수행한다.

### 4. Kubernetes Cluster 설정

#### 4.1. Master Node

{% highlight text %}
[Global]
auth-url="http://192.168.0.40:5000/v3"
username="admin"
password="admin"
region="RegionOne"
tenant-id="b21b68637237488bbb5f33ac8d86b848"
domain-name="Default"

[LoadBalancer]
subnet-id=67ca5cfd-0c3f-434d-a16c-c709d1ab37fb
floating-network-id=00a8e738-c81e-45f6-9788-3e58186076b6
use-octavia=True
lb-method=ROUND_ROBIN

create-monitor=yes
monitor-delay=1m
monitor-timeout=30s
monitor-max-retries=3
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Master Node - /etc/kubernetes/cloud-config</figcaption>
</figure>

Master Node에 /etc/kubernetes/cloud-config 파일을 [파일 2]의 내용으로 생성한다. [파일 2]의 Global 영역에는 Kubernetes VM의 User ID/PW, Tenant, Region 정보등이 저장되어 있다. LoadBalancer 영역에는 Load Balancer 관련 설정 정보가 저장되어 있다. subnet-id는 Kubernetes Network의 Subnet ID를 의미한다. floating-network-id는 External Network ID를 의미한다. lb-method는 Load Balancing 알고리즘을 의미한다. monitor 관련 설정은 Octavia Member VM Monitoring 정책을 결정한다.

{% highlight yaml %}
...
    volumeMounts:
    - mountPath: /etc/kubernetes/cloud-config
      name: cloud-config
      readOnly: true
...
  volumes:
  - hostPath:
      path: /etc/kubernetes/cloud-config
      type: FileOrCreate
    name: cloud-config
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Master Node - /etc/kubernetes/manifests/kube-controller-manager.yaml</figcaption>
</figure>

Master Node의 /etc/kubernetes/manifests/kube-controller-manager.yaml 파일을 [파일 3]의 내용으로 수정하여 Kubernetes Controller Manager가 cloud-config 파일을 이용할 수 있도록 설정한다. kube-controller-manager.yaml 파일을 수정하면 Kubernetes는 자동으로 Controller Manager를 재시작한다.

~~~
(Master)# kubectl create secret -n kube-system generic cloud-config --from-literal=cloud.conf="$(cat /etc/kubernetes/cloud-config)" --dry-run -o yaml > cloud-config-secret.yaml
(Master)# kubectl -f cloud-config-secret.yaml apply
~~~

cloud-config 파일을 secret으로 생성하여 cloud-controller-manager가 cloud-config를 이용할 수 있도록 설정한다.

### 5. OpenStack External Cloud Provider 설치

#### 5.1. Master Node

~~~
(Master)# kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/cluster/addons/rbac/cloud-controller-manager-roles.yaml
(Master)# kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/cluster/addons/rbac/cloud-controller-manager-role-bindings.yaml
(Master)# kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml
~~~

OpenStack External Cloud Provider를 설치한다.

### 6. Cilium 설치

#### 6.1. All Node

~~~
(All)# mount bpffs /sys/fs/bpf -t bpf
(All)# echo "bpffs                      /sys/fs/bpf             bpf     defaults 0 0" >> /etc/fstab
~~~

모든 Node에서 bpffs를 Mount하도록 설정한다. 

#### 6.2. Master Node

~~~
(Master)# wget https://github.com/cilium/cilium/archive/v1.5.6.zip
(Master)# unzip v1.5.6.zip
(Master)# kubectl apply -f cilium-1.5.6/examples/kubernetes/1.15/cilium.yaml
~~~

Cilium을 설치한다.

### 7. 참조

* [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)
* [https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-controller-manager-with-kubeadm.md](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-controller-manager-with-kubeadm.md)
* [https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/](https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/)