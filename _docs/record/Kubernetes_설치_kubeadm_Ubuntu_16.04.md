---
title: Kubernetes 설치 / kubeadm 이용 / Ubuntu 16.04 환경
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

설치 환경은 다음과 같다.
* VirtualBox 5.0.14r
  * Master Node : Ubuntu Desktop 16.04.2 64bit 1대
  * Worker Node : Ubuntu Server 16.04.2 64bit 2대
* Kubernetes 1.7.1
  * Network Plugin : flannel 이용
  * Dashboard Addon : Dashboard 이용
* kubeadm
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* Docker 1.12.6
  * Kubernetes에서 1.12.x Version을 권장하고 있다.
* Password
  * Kubernetes 설치에 필요한 Password는 간편한 설치를 위해 **root**로 통일한다.
* 모든 Node에서 root User로 설치를 진행한다.

### 2. Node 설정

![[그림 1] Kubernetes 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Kubernetes_kubeadm_Install_Ubuntu_16.04/Node_Setting.PNG)

VirtualBox를 이용하여 [그림 1]과 같이 가상의 Master, Worker Node (VM)을 생성한다.
* Hostname : Master Node - ubuntu01, Worker Node1 - ubuntu02, Worker Node2 - ubuntu03
* NAT : Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* Router : 공유기를 이용하여 192.168.77.0/24 Network를 구축한다. (NAT)

#### 2.1. Master Node

{% highlight text %}
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
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Master Node의 /etc/network/interfaces</figcaption>
</figure>

/etc/network/interfaces을 [파일 1]과 같이 수정한다.

#### 2.2. Worker Node

{% highlight text %}
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
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Worker Node 01의 /etc/network/interfaces</figcaption>
</figure>

Worker Node 01의 /etc/network/interfaces을 [파일 2]와 같이 수정한다.

{% highlight text %}
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
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Worker Node 02의 /etc/network/interfaces</figcaption>
</figure>

Worker Node 02의 /etc/network/interfaces을 [파일 3]과 같이 수정한다.

### 3. Package 설치

#### 3.1. 모든 Node

~~~
(All)# sudo apt-get update
(All)# sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
(All)# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
(All)# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
(All)# sudo apt-get update
(All)# sudo apt-get install docker.io=1.12.6-0ubuntu1~16.04.1
~~~

Docker를 설치한다.

~~~
(All)# apt-get update && apt-get install -y apt-transport-https curl
(All)# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
(All)# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
(All)# apt-get update
(All)# apt-get install -y kubelet kubeadm
~~~

kubelet, kubeadm을 설치한다.

#### 3.2. Master Node

~~~
(Master)# sudo snap install kubectl --classic
~~~

kubectl를 설치한다.

### 4. Cluster 구축

#### 4.1. Master Node

~~~
(Master)# kubeadm init --apiserver-advertise-address=10.0.0.11 --pod-network-cidr=10.244.0.0/16
...
kubeadm join --token 76f75a.6fbcc5e0e6e74c89 10.0.0.11:6443
~~~

kubeadm 초기화를 진행한다. 실행 후 Key 값을 얻을 수 있다. 10.0.0.11는 NAT Network의 Master IP이다.

~~~
(Master)# mkdir -p $HOME/.kube
(Master)# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
(Master)# sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~

kubectl config 설정을 진행한다.

{% highlight text %}
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

source <(kubectl completion bash)
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] Master Node의 ~/.bashrc</figcaption>
</figure>

kubectl autocomplete 설정을 진행한다. ~/.bashrc에 [파일 4]의 내용을 추가한다.

~~~
(Master)# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
(Master)# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
~~~

Network Addon (flannel)을 설치한다.

~~~
(Master)# kubectl create -f https://git.io/kube-dashboard
~~~

Dashboard Addon (Dashboard)을 설치한다.

#### 4.2. Worker Node

~~~
(Worker)# kubeadm join --token 76f75a.6fbcc5e0e6e74c89 10.0.0.11:6443
~~~

Cluster를 구성한다. kubeadm init 결과로 나온 **kubeadm join ~~** 명령어를 모든 Worker Node에서 수행한다.

#### 4.3. 검증

~~~
(Master)# kubectl get nodes
NAME       STATUS     AGE       VERSION
ubuntu01   Ready      41m       v1.7.1
ubuntu02   Ready      49s       v1.7.1
ubuntu03   Ready      55s       v1.7.1
~~~

Master Node에서 Cluster를 확인한다. 

~~~
(Master)# kubectl proxy
~~~

kubectl proxy 명령어 실행 후 Master Node에서 Web Brower를 통해 **http://localhost:8001/ui**에 접속한다.

### 5. 참조

* Kubernetes 설치 : [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* Docker 설치 : [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* flannel Issue :  [https://github.com/coreos/flannel/issues/671](https://github.com/coreos/flannel/issues/671)
