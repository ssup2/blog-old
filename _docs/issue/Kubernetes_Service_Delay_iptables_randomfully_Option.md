---
title: Kubernetes Service Delay with iptables "--random-fully" Option
category: Issue
date: 2020-10-25T12:00:00Z
lastmod: 2020-10-25T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

Kubernetes 1.16부터 KUBE-POSTROUTING NAT Chain에 추가된 iptables의 "--random-fully" Option으로 인해서, Kubernetes Cluster가 VXLAN을 이용하는 CNI Plugin을 이용하는 경우 Service의 ClusterIP로 전송하는 Packet이 Delay가 발생하는 Issue가 존재한다.

### 2. 원인

{% highlight console %}
# iptables -t nat -nvL
...
Chain KUBE-MARK-MASQ (5 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x4000
...
Chain KUBE-POSTROUTING (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service traffic requiring SNAT */ mark match 0x4000/0x4000 random-fully
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Kubernetes iptables nat Table</figcaption>
</figure>

### 3. 해결 방안

#### 3.1 Kubernetes Patch

{% highlight console %}
# iptables -t nat -nvL
...
Chain KUBE-MARK-MASQ (11 references)
 pkts bytes target     prot opt in     out     source               destination
   12   720 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x4000
...
Chain KUBE-POSTROUTING (1 references)
 pkts bytes target     prot opt in     out     source               destination
   38  2512 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            mark match ! 0x4000/0x4000
    6   360 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK xor 0x4000
    6   360 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service traffic requiring SNAT */ random-fully
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Patch가 적용된 Kubernetes iptables nat Table</figcaption>
</figure>

#### 3.2. Kernel Patch

#### 3.3. Checksum Disable

### 4. 참조

* [https://github.com/kubernetes/kubernetes/pull/92035](https://github.com/kubernetes/kubernetes/pull/92035)
* [https://github.com/kubernetes/kubernetes/issues/90854](https://github.com/kubernetes/kubernetes/issues/90854)
* [https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02](https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02)
* [https://github.com/kubernetes/kubernetes/pull/78547](https://github.com/kubernetes/kubernetes/pull/78547)

