---
title: Kubernetes MetalLB 설치 / Ubuntu_18.04
category: Record
date: 2019-05-21T12:00:00Z
lastmod: 2019-05-21T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설치 환경은 다음과 같다.
* Kubernetes 1.12
  * Network Addon : cilium 이용
* Helm
  * Client : v2.13.1
  * Server : v2.13.1
* MetalLB 0.7.3

### 2. Network 설정

![[그림 1] Kubernetes Network]({{site.baseurl}}/images/record/Kubernetes_MetalLB_Install_Ubuntu_18.04/Kubernetes_Network.PNG)

Network는 다음과 같다.
* Node Network : 10.0.0.0/24
* LoadBalancer Service IP : 10.0.0.200 ~ 10.0.0.220

### 3. MetalLB 설치

~~~
# git clone https://github.com/helm/charts.git
# cd charts/stable/metallb
~~~

Helm의 Offical Stable Chart를 받는다. MetalLB는 현재 Helm의 Offical Stable Chart에 포함되어 있다.

{% highlight text %}
...
configInline:
  address-pools:
  - name: default
    protocol: layer2
    addresses:
    - 10.0.0.200-10.0.0.220    
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] MetalLB Chart의 values.yaml</figcaption>
</figure>

MetalLB를 설정한다.MetalLB Chart의 value.yaml 파일을 [파일 1]과 같이 수정한다. MetalLB를 ARP Mode로 설정하고, LoadBalancer Service IP의 범위를 설정한다.

~~~
# helm install --name metallb --namespace metallb .
~~~

MetalLB를 설치한다.

### 4. MetalLB 검증

~~~
# root@kube01:~/charts/stable/metallb# kubectl get service --all-namespaces
NAMESPACE     NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                           AGE
default       my-nginx-loadbalancer   LoadBalancer   10.96.98.173     10.0.0.200   80:30781/TCP                      34m
...                                                                             
~~~

LoadBalancer Service를 생성하여 External IP가 제대로 할당되는지 확인한다.

### 5. 참조

* [https://istio.io/docs/setup/kubernetes/install/helm/](https://istio.io/docs/setup/kubernetes/install/helm/)