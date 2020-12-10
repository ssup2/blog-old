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

Kubernetes v1.16 Version부터 VXLAN을 기반으로 하는 CNI Plugin 이용시 Kubernetes Cluster 내부에서 TCP Connection이 Delay되는 현상이 Issue가 존재한다. 주로 Host 또는 Host Network Namespace를 이용하는 Pod에서 다른 Pod으로 TCP Connection을 맺을시에 본 Issue가 발생한다.

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

[Shell 1]은 Kubernetes Cluster Node의 iptabes nat Table의 일부를 나타내고 있다. Kubernetes는 Pod이 전송하는 Packet이 Masquerade를 통해서 SNAT가 필요하다고 판단되는 부분에 KUBE-MARK-MASQ Chain을 통해서 해당 Packet을 Marking하고, KUBE-POSTROUTING Chain에서 Marking된 Packet을 Masquerade Rule을 통해서 SNAT를 수행한다. Masquerade Rule을 보면 "\-\-random-fully" Option이 들어가 있는걸 확인할 수 있는데, SNAT 수행시 Packet에 할당하는 Source Port가 Race Condtion에 의해서 중복되어 할당하는 것을 방지하기 위해서 들어간 Option이다.

VXLAN 기반의 CNI (Container Network Interface) Plugin을 이용하는 Kubernetes Cluster의 내부에서 Packet을 VXLAN Tunnel Interface를 통해서 Pod에게 전송하는 경우, 해당 Packet은 Kernel의 Network Stack을 총 2번 지나게 되고 iptables Table도 2번 지나게 된다. Packet이 첫번째로 Network Stack을 지날때는 Pod이 전송한 원본 Packet 상태로 지나가고, Packet이 두번째로 Network Stack을 지날때는 VXLAN 기법에 의해서 UDP로 Encapsulation되어 지나간다.

문제는 Packet이 VXLAN Tunnel Interface를 지나면서 KUBE-MARK-MASQ, KUBE-POSTROUTING Chain의 Masquerade Rule에 의해서 VXLAN Tunnel Interface의 IP로 SNAT 될때 발생한다. Packet은 첫번째로 iptables Table을 지나면서 KUBE-MARK-MASQ Chain과 KUBE-POSTROUTING Chain을 통해서 VXLAN Tunnel Interface의 IP로 한번 SNAT가 된다. 이때 KUBE-MARK-MASQ Chain에 의해서 Packet에 남긴 Mark는 Packet이 두번째로 iptables Table을 지날때도 남아 있있다. 따라서 Packet은 두번째로 iptables Table을 지날때 KUBE-POSTROUTING Chain의 Masquerade Rule에 의해서 한번더 SNAT된다.

한번더 SNAT가 되었다면 한번더 TCP/UDP Checksum을 계산해야 하지만 Kernel Bug에 의해서 한번더 TCP/UDP Checksum을 계산하지 않는 문제가 있다. Masquerade Rule에 "\-\-random-fully" Option이 적용되어 있지 않다면 VXLAN Tunnel Interface의 IP로 SNAT된 Packet을 한번더 VXLAN Tunnel Interface의 IP로 SNAT 하여도 Packet의 Src IP와 Src Port는 변경되지 않기 때문에 Kernel의 TCP/UDP Checksum Bug는 치명적이지 않는다. 하지만 Masquerade Rule에 "\-\-random-fully" Option이 적용되어 있다면 두번째 SNAT 수행시 Src IP는 변경되지 않지만 Src Port는 변경되기 때문에 Kernel의 TCP/UDP Checksum Bug는 치명적인 Bug가 된다. TCP/UDP Checksum이 맞지 않는 Packet은 해당 Packet을 수신한 NIC에서 Drop된다.

대부분의 VXLAN을 기반으로하는 CNI Plugin에서는 Pod에서 VXLAN Tunnel Interface를 통해서 Pod으로 Packet 전송시, Packet은 VXLAN Tunnel Interface의 IP로 SNAT 되지 않고 Pod의 IP를 Src IP로 갖고 전송된다. Packet이 VXLAN Tunnel Interface의 IP로 SNAT 되는 경우는 Host에서 VXLAN Tunnel Interface를 통해서 Pod으로 Packet을 전송하거나, Host Network Namespace를 이용하는 Pod에서 VXLAN Tunnel Interface를 통해서 Pod으로 Packet을 전송할 때이다. **따라서 본 Issue는 Host 또는 Host Network Namespace를 이용하는 경우에 주로 발생한다.** Masquerade Rule에 "\-\-random-fully" Option은 Kubernetes v1.16 Version 이후부터 적용되었다. 따라서 v1.16 이전 Version에서는 본 이슈가 발생하지 않는다.

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

Kubernetes의 KUBE-POSTROUTING Chain의 Rule이 하나의 Packet이 두번 SNAT 되지 않도록 Patch 되었다. [Shell 2]는 Patch가 적용된 Kubernetes Cluster Node의 iptabes nat Table의 일부를 나타내고 있다. KUBE-POSTROUTING Chain에서 Packet에 Masquerade Rule을 적용하기 전에 "xor 0x4000" Option을 통해서 Packet의 Mark를 제거하는것을 확인 할 수 있다. 따라서 Packet이 두번째로 iptables Table을 지날때는 KUBE-POSTROUTING Chain의 Masquerade Rule을 적용받지 않게되고, Packet은 처음 iptables Table을 지날때 KUBE-POSTROUTING Chain의 Masquerade Rule에 의해서 한번만 SNAT된다. 

한번만 SNAT를 수행하기 때문에 Kernel의 TCP/UDP Checksum Bug가 존재하는 Kernel을 이용하더라도, 실제로 TCP/UDP Checksum Bug가 발생하지는 않게된다. 따라서 Patch가 적용된 Kubernetes를 이용할 경우에는 Kernel Patch가 필요없다. Patch가 적용된 Kubernetes Version은 다음과 같다.

* v1.16.13+
* v1.17.9+
* v1.18.6+

#### 3.2. Kernel Patch

다음의 Bug를 수정한 Kernel을 적용하면 된다.

* netfilter: nat: never update the UDP checksum when it's 0
  * [https://www.spinics.net/lists/netdev/msg648256.html](https://www.spinics.net/lists/netdev/msg648256.html)

UDP Checksum Bug를 수정한 Kernel Version은 다음과 같다.

* Linux Longterm
  * 4.14.181+
  * 4.19.123+
  * 5.4.41+
* Distro Linux Kernel
  * Ubuntu : 4.15.0-107.108, 5.4.0-32.36+

#### 3.3. Checksum Offload Disable

NIC에서 TCP/UDP Checksum을 수행하지 않도록 TCP/UDP Checksum Offload를 기능을 끈다. Cluster의 모든 Node에서 TCP/UDP Checksum Offload 기능을 꺼야한다. Linux에서 TCP/UDP Checksum Offload 기능을 끄는 방법은 다음과 같다. `ethtool --offload eth0 rx off tx off` 명령어를 통해서 TCP/UDP Checksum Offload 기능을 끌 수 있다.

### 4. 참조

* [https://github.com/kubernetes/kubernetes/pull/92035](https://github.com/kubernetes/kubernetes/pull/92035)
* [https://github.com/kubernetes/kubernetes/issues/88986#issuecomment-640929804](https://github.com/kubernetes/kubernetes/issues/88986#issuecomment-640929804)
* [https://github.com/kubernetes/kubernetes/issues/90854](https://github.com/kubernetes/kubernetes/issues/90854)
* [https://github.com/kubernetes/kubernetes/pull/78547](https://github.com/kubernetes/kubernetes/pull/78547)
* [https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02](https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02)
* [https://www.spinics.net/lists/netdev/msg648256.html](https://www.spinics.net/lists/netdev/msg648256.html)
* [https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG](https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG)
