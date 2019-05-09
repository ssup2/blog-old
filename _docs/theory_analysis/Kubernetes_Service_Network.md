---
title: Kubernetes Service Network
category: Theory, Analysis
date: 2019-05-06T12:00:00Z
lastmod: 2019-05-06T12:00:00Z
comment: true
adsense: true
---

Kubernetes Service Type별 Network를 분석한다.

### 1. Proxy Mode - iptables

![[그림 1] Kubernetes Architecture]({{site.baseurl}}/images/theory_analysis/Kubernetes_Service_Network/Kubernetes_Service_NAT_Table.PNG){: width="700px"}

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

#### 1.1. ClusterIP

#### 1.2. NodePort

#### 1.3. LoadBalancer

#### 1.4. Headless

### 2. Proxy Mode - IPVS

### 3. Proxy Mode - Userspace

### 4. 참조

* [http://www.system-rescue-cd.org/networking/Load-balancing-using-iptables-with-connmark/](http://www.system-rescue-cd.org/networking/Load-balancing-using-iptables-with-connmark/)
* [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)