---
title: Kubernetes Service Network
category: Theory, Analysis
date: 2019-05-06T12:00:00Z
lastmod: 2019-05-06T12:00:00Z
comment: true
adsense: true
---

Kubernetes는 iptables, IPVS, Userspace 3 가지 Proxy Mode를 지원하고 있다. 각 Mode에 따른 Service Network를 분석한다.

### 1. iptables Proxy Mode

![[그림 1] iptables Proxy Mode에서 Service Packet의 NAT Table 경로]({{site.baseurl}}/images/theory_analysis/Kubernetes_Service_Network/Kubernetes_iptables_Service_NAT_Table.PNG)

{% highlight text %}
Chain KUBE-SERVICES (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  tcp  --  *      *      !192.167.0.0/16       10.103.1.234         /* default/my-nginx-cluster: cluster IP */ tcp dpt:80
    0     0 KUBE-SVC-52FY5WPFTOHXARFK  tcp  --  *      *       0.0.0.0/0            10.103.1.234         /* default/my-nginx-cluster: cluster IP */ tcp dpt:80
    0     0 KUBE-MARK-MASQ  tcp  --  *      *      !192.167.0.0/16       10.97.229.148        /* default/my-nginx-nodeport: cluster IP */ tcp dpt:80
    0     0 KUBE-SVC-6JXEEPSEELXY3JZG  tcp  --  *      *       0.0.0.0/0            10.97.229.148        /* default/my-nginx-nodeport: cluster IP */ tcp dpt:80
    0     0 KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service nodeports; NOTE: this must be the last rule in this chain */ ADDRTYPE match dst-type LOCAL
{% endhighlight %}
<figure>
<figcaption class="caption">[Table 1] KUBE-SERVICE </figcaption>
</figure>

{% highlight text %}
Chain KUBE-NODEPORTS (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-nodeport: */ tcp dpt:30915
    0     0 KUBE-SVC-6JXEEPSEELXY3JZG  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-nodeport: */ tcp dpt:30915 
{% endhighlight %}
<figure>
<figcaption class="caption">[Table 2] KUBE-NODEPORTS </figcaption>
</figure>

{% highlight text %}
Chain KUBE-SVC-6JXEEPSEELXY3JZG (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-SEP-6HM47TA5RTJFOZFJ  all  --  *      *       0.0.0.0/0            0.0.0.0/0            statistic mode random probability 0.33332999982
    0     0 KUBE-SEP-AHRDCNDYGFSFVA64  all  --  *      *       0.0.0.0/0            0.0.0.0/0            statistic mode random probability 0.50000000000
    0     0 KUBE-SEP-BK523K4AX5Y34OZL  all  --  *      *       0.0.0.0/0            0.0.0.0/0      
{% endhighlight %}
<figure>
<figcaption class="caption">[Table 3] KUBE-SVC-XXX </figcaption>
</figure>

{% highlight text %}
Chain KUBE-SEP-QQATNRPNVZFKMY6D (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  all  --  *      *       192.167.1.138        0.0.0.0/0
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp to:192.167.1.138:53 
{% endhighlight %}
<figure>
<figcaption class="caption">[Table 4] KUBE-SEP-XXX </figcaption>
</figure>

{% highlight text %}
Chain KUBE-POSTROUTING (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service traffic requiring SNAT */ mark match
0x4000/0x4000 
{% endhighlight %}
<figure>
<figcaption class="caption">[Table 5] KUBE-POSTROUTING </figcaption>
</figure>

iptables Proxy Mode는 Kubernetes가 이용하는 Default Proxy Mode이다. [그림 1]은 Service로 전송되는 Packet이 지나는 NAT Table 경로를 나타내고 있다. [Table 1] ~ [Table 5]는 [그림 1]의 각 NAT Table의 실제 내용을 보여주고 있다. [그림 1]의 NAT Table들은 Kubernetes Cluster를 구성하는 모든 Node에 동일하게 설정된다. 따라서 Kubernetes Cluster를 구성하는 어느 Node에서도 Service로 Packet을 전송할 수 있다.

대부분의 Pod에서 전송된 Packet은 Pod의 veth를 통해서 Host의 Network Namespace로 전달되기 때문에 Packet은 PREROUTING Table에 의해서 KUBE-SERVICE Table로 전달된다. Host의 Network Namespace를 이용하는 Pod 또는 Host Process에서 전송한 Packet은 OUTPUT Table에 의해서 KUBE-SERVICE Table로 전달된다. KUBE-SERVICE Table에서 Packet의 Dest IP와 Dest Port가 ClusterIP Service의 IP와 Port와 일치한다면, 해당 Packet은 일치하는 ClusterIP Service의 NAT Table인 KUBE-SVC-XXX Table로 전달된다. Packet의 Dest IP가 Localhost인 경우에는 해당 Packet은 KUBE-NODEPORTS Table로 전달된다.

KUBE-NODEPORTS Table에서 Packet의 Dest Port가 NodePort Service의 Port와 일치하는 경우 해당 Packet은 NodePort Service의 NAT Table인 KUBE-SVC-XXX Table로 전달된다. KUBE-SVC-XXX Table에서는 iptables의 statistic 기능을 이용하여 Packet은 Service를 구성하는 Pod들로 랜덤하고 균등하게 분배하는 역활을 수행한다. [Table 3]에서는 Service는 3개의 Pod으로 구성되어 있기 때문에 3개의 KUBE-SEP-XXX Table로 Packet이 랜덤하고 균등하게 분배되도록 설정되어 있다. KUBE-SEP-XXX Table에서 Packet은 Container IP 및 Service에서 설정한 Port로 DNAT를 수행한다. Container IP로 **DNAT**를 수행한 Packet은 해당 CNI Plugin을 통해 구축된 Container Netwokr를 통해서 Container에게 전달된다.

Service로 전달되는 Packet은 iptables의 DNAT를 통해서 Pod에게 전달되기 때문에, Pod에서 전송한 응답 Packet의 Src IP는 Pod의 IP가 아닌 Service의 IP로 **SNAT**되어야 한다. iptables에는 Serivce를 위한 SNAT Rule이 명시되어 있지 않다. 하지만 iptables는 Linux Kernel의 **Conntrack** (Connection Tracking)의 TCP Connection 정보를 바탕으로 Service Pod으로부터 전달받은 Packet을 SNAT한다. 


### 2. IPVS Proxy Mode

### 3. Userspace Proxy Mode

### 4. 참조

* [http://www.system-rescue-cd.org/networking/Load-balancing-using-iptables-with-connmark/](http://www.system-rescue-cd.org/networking/Load-balancing-using-iptables-with-connmark/)
* [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)