---
title: Kubernetes 설치 / kubeadm, IPv6 DualStack 이용 / Ubuntu 18.04 환경
category: Record
date: 2020-09-10T12:00:00Z
lastmod: 2020-09-10T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] Kubernetes 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Kubernetes_Install_kubeadm_IPv6_Ubuntu_18.04/Node_Setting.PNG)

[그림 1]은 Kubernetes 설치를 위한 Node의 구성도를 나타내고 있다. 설치 환경은 다음과 같다.

* VM : 4 vCPU, 4GB Memory
  * Master Node * 1
  * Worker Node * 2
* Network
  * Node Network : 192.168.0.0/24, fdaa::/64
  * Pod Network : 192.167.0.0/16, fdbb::/64
  * Service Network : 10.96.0.0/12, fdcc::/112
* Kubernetes : 1.18.3
  * CNI : Calico 3.14 Plugin

### 2. Ubuntu Package 설치

#### 2.1. All Node

모든 Node에서 Kubernetes를 위한 Package를 설치한다.

~~~console
(All)# sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
(All)# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
(All)# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
(All)# apt-get update
(All)# apt-get install docker-ce docker-ce-cli containerd.io
~~~

Docker를 설치한다.

~~~console
(All)# apt-get update && apt-get install -y apt-transport-https curl
(All)# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
(All)# echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
(All)# apt-get update
(All)# apt-get install -y kubeadm=1.18.3-00 kubelet=1.18.3-00
~~~

kubelet, kubeadm를 설치한다.

~~~
(ALL)# sysctl -w net.ipv6.conf.all.forwarding=1
(ALL)# echo net.ipv6.conf.all.forwarding=1 >> /etc/sysctl.conf
~~~

IPv6 Forwarding을 설정한다.

### 3. Kubernetes Cluster 구축

#### 3.1. Master Node

~~~console
(Master)# kubeadm init --apiserver-advertise-address=192.168.0.61 --kubernetes-version=v1.18.3 --feature-gates=IPv6DualStack=true --pod-network-cidr=192.167.0.0/16,fdbb::0/64 --service-cidr=10.96.0.0/12,fdcc::0/112
...
kubeadm join 192.168.0.61:6443 --token 6gu1o3.dwhguhu651x137eq --discovery-token-ca-cert-hash sha256:2ab0fa9f6f8c3c49c263bc0a0edc19ddf973bf7fdf5e464c807df45e8bf49ab8
~~~

kubeadm를 초기화 한다. --pod-network-cidr, --service-cidr 각각 IPv6 CIDR도 설정한다.

~~~console
(Master)# mkdir -p $HOME/.kube 
(Master)# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
(Master)# sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~

kubernetes config 파일을 설정한다.

#### 3.2. Worker Node

~~~console
(Worker)# kubeadm join 192.168.0.61:6443 --token 6gu1o3.dwhguhu651x137eq --discovery-token-ca-cert-hash sha256:2ab0fa9f6f8c3c49c263bc0a0edc19ddf973bf7fdf5e464c807df45e8bf49ab8
~~~

kubeadm init 결과로 나온 **kubeadm join ~~** 명령어를 모든 Worker Node에서 수행한다.

### 4. Calico 설치

~~~console
(Master)# wget https://docs.projectcalico.org/v3.14/manifests/calico.yaml
~~~

Calico Manifest 파일을 Download한다.

{% highlight text %}
...
          "mtu": __CNI_MTU__,
          "ipam": {
              "type": "calico-ipam",
              "assign_ipv4": "true",
              "assign_ipv6": "true"
          },
...
            # The default IPv4 pool to create on startup if none exists. Pod IPs will be
            # chosen from this range. Changing this value after installation will have
            # no effect. This should fall within `--cluster-cidr`.
            - name: CALICO_IPV4POOL_CIDR
              value: "192.167.0.0/16"
            - name: IP6
              value: "autodetect"
            - name: CALICO_IPV6POOL_CIDR
              value: "fdbb::0/64"
...
            - name: FELIX_DEFAULTENDPOINTTOHOSTACTION
              value: "ACCEPT"
            - name: FELIX_IPV6SUPPORT
              value: true
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] calico.yaml</figcaption>
</figure>

Calico Manifest 파일을 [파일 1]의 내용으로 수정한다.

~~~console
(Master)# kubectl apply -f calico.yaml
~~~

Calico를 설치한다.

### 5. 참조

* [https://medium.com/@elfakharany/how-to-enable-ipv6-on-kubernetes-aka-dual-stack-cluster-ac0fe294e4cf](https://medium.com/@elfakharany/how-to-enable-ipv6-on-kubernetes-aka-dual-stack-cluster-ac0fe294e4cf)
* [https://kubernetes.io/docs/concepts/services-networking/dual-stack/](https://kubernetes.io/docs/concepts/services-networking/dual-stack/)
* [https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises)
* [https://docs.projectcalico.org/networking/dual-stack](https://docs.projectcalico.org/networking/dual-stack)