---
title: Kubernetes Connection Delay with VXLAN CNI Plugin
category: Issue
date: 2020-10-25T12:00:00Z
lastmod: 2020-10-25T12:00:00Z
comment: true
adsense: true
---

https://github.com/kubernetes/kubernetes/pull/92035 글의 내용을 바탕으로 정리하였습니다.

### 1. Issue

Kubernetes v1.16 Version부터 VXLAN을 기반으로 하는 CNI 이용시 Kubernetes Cluster 내부에서 TCP Connection이 Delay되는 현상이 Issue가 존재한다. 주로 Host 또는 Host Network Namespace를 이용하는 Pod에서 다른 Pod으로 TCP Connection을 맺을시에 본 Issue가 발생한다.

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

[Shell 1]은 Kubernetes Cluster를 구성하는 Node의 iptabes nat Table의 일부를 나타내고 있다. Kubernetes는 Pod이 전송하는 Packet이 Masquerade를 통해서 SNAT가 필요하다고 판단되는 부분에 KUBE-MARK-MASQ Chain을 통해서 해당 Packet을 Marking하고, KUBE-POSTROUTING Chain에서 Marking된 Packet을 Masquerade Rule을 통해서 SNAT를 수행한다. Masquerade Rule을 보면 random-fully Option이 들어가 있는걸 확인할 수 있는데, SNAT 수행시 Packet에 할당하는 Source Port가 Race Condtion에 의해서 중복되어 할당하는 것을 방지하기 위해서 들어간 Option이다.

VXLAN 기반의 CNI (Container Network Interface) Plugin을 이용하는 Kubernetes Cluster의 내부에서 Packet을 VXLAN Tunnel Interface를 통해서 Pod에게 전송하는 경우, 해당 Packet은 Kernel의 Network Stack을 총 2번 지나게 되고 iptables Table도 2번 지나게 된다. Packet이 첫번째로 Network Stack을 지날때는 Pod이 전송한 원본 Packet 상태로 지나가고, Packet이 두번째로 Network Stack을 지날때는 VXLAN 기법에 의해서 UDP로 Encapsulation되어 지나간다.

문제는 Packet이 Masquerade 되면서 KUBE-MARK-MASQ, KUBE-POSTROUTING Chain에 의해서 SNAT될때 발생한다. Packet이 첫번째로 iptables Table을 지나면서 KUBE-MARK-MASQ Chain과 KUBE-POSTROUTING Chain을 통해서 한번 SNAT가 된다. 이후 두번째로 iptables Table을 지날때 첫번째 iptables Table을 지나면서 KUBE-MARK-MASQ Chain에 의해서 남겨진 Packet의 Mark는 그대로 남아있는다. 따라서 Packet은 두번째로 iptables Table을 지날때 KUBE-POSTROUTING Chain을 통해서 한번더 SNAT가 된다. 즉 Packet은 총 두번 SNAT된다.

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

#### 3.3. Checksum Offload Disable

### 4. 참조

* [https://github.com/kubernetes/kubernetes/pull/92035](https://github.com/kubernetes/kubernetes/pull/92035)
* [https://github.com/kubernetes/kubernetes/issues/88986#issuecomment-640929804](https://github.com/kubernetes/kubernetes/issues/88986#issuecomment-640929804)
* [https://github.com/kubernetes/kubernetes/issues/90854](https://github.com/kubernetes/kubernetes/issues/90854)
* [https://github.com/kubernetes/kubernetes/pull/78547](https://github.com/kubernetes/kubernetes/pull/78547)
* [https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02](https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02)


