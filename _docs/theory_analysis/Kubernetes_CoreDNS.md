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

![[그림 1] Kubernetes Architecture]({{site.baseurl}}/images/theory_analysis/Kubernetes_CoreDNS/Kubernetes_CoreDNS_Architecture.PNG){: width="700px"}

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

### 2. 참조

* [https://jonnung.dev/kubernetes/2020/05/11/kubernetes-dns-about-coredns/](https://jonnung.dev/kubernetes/2020/05/11/kubernetes-dns-about-coredns/)
* [https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
* [https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
* [https://coredns.io/plugins/kubernetes/](https://coredns.io/plugins/kubernetes/)