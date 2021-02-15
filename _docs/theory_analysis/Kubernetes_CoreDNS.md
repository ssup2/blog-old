---
title: Kubernetes CoreDNS
category: Theory, Analysis
date: 2020-09-24T12:00:00Z
lastmod: 2020-09-24T12:00:00Z
comment: true
adsense: true
---

Kubernetes에서 동작하는 CoreDNS를 분석한다.

### 1. Kubernetes CoreDNS

![[그림 1] Kubernetes CoreDNS Architecture]({{site.baseurl}}/images/theory_analysis/Kubernetes_CoreDNS/Kubernetes_CoreDNS_Architecture.PNG){: width="700px"}

CoreDNS는 일반적으로 Kubernetes Cluster 내부에서 이용되는 DNS Server이다. 주로 Kubernetes Cluster 내부에서 Domain을 통해서 Service나 Pod의 IP를 찾는 용도로 많이 이용된다. [그림 1]은 Kubernetes Cluster에서 동작하는 CoreDNS의 Architecture를 나타내고 있다. CoreDNS는 일반적으로 Worker Node에서 Deployment로 배포되어 다수의 Pod으로 구동된다. 그리고 다수의 CoreDNS Pod들은 CoreDNS Service를 통해서 VIP (ClusterIP)로 묶이게 된다. Kubernetes Cluster의 Pod들은 CoreDNS Service의 VIP를 통해서 CoreDNS에 접근하게 된다. 다수의 CoreDNS Pod와 CoreDNS Service를 이용하는 이유는 HA(High Availability) 때문이다.

{% highlight console %}
# kubectl -n kube-system get deployment coredns
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
coredns   2/2     2            2           13d
# kubectl -n kube-system get service kube-dns
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   13d
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] CoreDNS Deployment, Pod</figcaption>
</figure>

{% highlight console %}
# kubectl run my-shell --rm -i --tty --image nicolaka/netshoot -- bash
(container)# cat /etc/resolv.conf
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] CoreDNS Deployment, Pod</figcaption>
</figure>

[Shell 1]은 kube-system Namespace에 설정되어 있는 CoreDNS의 Deployment, Service의 모습을 나타내고 있다. [Shell 2]는 임의의 Shell Pod을 만들고 Shell Pod안에서 /etc/resolv.conf 파일에 설정된 DNS Server를 확인하는 과정이다. CoreDNS Service의 VIP (ClusterIP)가 설정되어 있는걸 확인할 수 있다. [그림 1]에서도 Pod의 /etc/resolve.conf 파일에 CoreDNS Service의 VIP가 설정되어 있는것을 나타내고 있다.

{% highlight text %}
.:53 {
    log
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] CoreDNS Config</figcaption>
</figure>

CoreDNS는 Kubernetes API 서버로부터 Service와 Pod를 Watch하여 **Service와 Pod의 Event를 수신**한다. Kubernetes API 서버로부터 Service 생성/삭제 또는 Pod의 생성/삭제 Event를 받은 CoreDNS는 Service, Pod의 Domain을 생성/삭제한다. 이러한 CoreDNS의 Kubernetes 관련 동작은 CoreDNS의 Config 파일을 통해서 설정할 수 있다. [파일 1]은 CoreDNS의 Config 파일을 나타내고 있다. kubernetes 설정 부분이 있는걸 확인할 수 있다.

CoreDNS의 설정파일에서 한가지더 주목해야하는 설정은 forward 설정이다. forward 설정은 CoreDNS의 Upstream DNS Server를 지정하는 역할을 수행한다. forward 설정에 /etc/resolv.conf 파일이 지정되어 있는것을 알 수 있다. CoreDNS Pod의 dnsPolicy는 "Default"이다. "Default"는 Pod가 떠있는 Node의 /etc/resolv.conf 파일의 내용을 상속받아 Pod의 /etc/resolv.conf 파일을 생성하는 설정이다. 따라서 CoreDNS Pod의 /etc/resolve.conf는 Node의 DNS Server 정보가 저장되어 있다. **즉 CoreDNS는 Node의 DNS Server를 Upstream으로 설정한다.**

### 2. 참조

* [https://jonnung.dev/kubernetes/2020/05/11/kubernetes-dns-about-coredns/](https://jonnung.dev/kubernetes/2020/05/11/kubernetes-dns-about-coredns/)
* [https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
* [https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
* [https://coredns.io/plugins/kubernetes/](https://coredns.io/plugins/kubernetes/)