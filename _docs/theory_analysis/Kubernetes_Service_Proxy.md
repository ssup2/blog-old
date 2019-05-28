---
title: Kubernetes Service Proxy
category: Theory, Analysis
date: 2019-05-06T12:00:00Z
lastmod: 2019-05-06T12:00:00Z
comment: true
adsense: true
---

Kubernetes는 iptables, IPVS, Userspace 3가지 Mode의 Service Proxy를 지원하고 있다. Service Proxy Mode에 따른 Service 요청 Packet의 경로를 분석한다.

### 1. Service, Pod Info

{% highlight text %}
# kubectl get pod -o wide
NAME                              READY   STATUS    RESTARTS   AGE   IP              NODE     NOMINATED NODE
my-nginx-756f645cd7-gh7sq         1/1     Running   14         15d   192.167.2.231   kube03   <none>
my-nginx-756f645cd7-hm7rg         1/1     Running   17         20d   192.167.2.206   kube03   <none>
my-nginx-756f645cd7-qfqbp         1/1     Running   16         20d   192.167.1.123   kube02   <none>

# kubectl get pod -o wide
NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                           AGE     SELECTOR
my-nginx-cluster        ClusterIP      10.103.1.234     <none>         80/TCP                            15d     run=my-nginx
my-nginx-loadbalancer   LoadBalancer   10.96.98.173     172.35.0.200   80:30781/TCP                      2d21h   run=my-nginx
my-nginx-nodeport       NodePort       10.97.229.148    <none>         80:30915/TCP                      15d     run=my-nginx
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Kubernetes Service Proxy 분석을 위한 Service, Pod 정보 </figcaption>
</figure>

[Shell 1]은 Kubernetes Service Proxy 분석을 위한 Service 및 Pod 정보를 나타내고 있다. Deployment로 3개의 nginx Pod을 생성하고 ClusterIP Type의 my-nginx-cluster Service, NodePort Type의 my-nginx-nodeport Service, LoadBalancer Type의 my-nginx-loadbalancer Service를 붙였다.

### 2. iptables Mode

![[그림 1] iptables Mode에서 Service 요청 Packet 경로]({{site.baseurl}}/images/theory_analysis/Kubernetes_Service_Proxy/iptables_Mode_Service_Packet_Path.PNG){: width="700px"}

{% highlight text %}
Chain KUBE-SERVICES (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  tcp  --  *      *      !192.167.0.0/16       10.96.98.173         /* default/my-nginx-loadbalancer: cluster IP */ tcp dpt:80
    0     0 KUBE-SVC-TNQCJ2KHUMKABQTD  tcp  --  *      *       0.0.0.0/0            10.96.98.173         /* default/my-nginx-loadbalancer: cluster IP */ tcp dpt:80
    0     0 KUBE-FW-TNQCJ2KHUMKABQTD  tcp  --  *      *       0.0.0.0/0            172.35.0.200         /* default/my-nginx-loadbalancer: loadbalancer IP */ tcp dpt:80
    0     0 KUBE-MARK-MASQ  tcp  --  *      *      !192.167.0.0/16       10.103.1.234         /* default/my-nginx-cluster: cluster IP */ tcp dpt:80
    0     0 KUBE-SVC-52FY5WPFTOHXARFK  tcp  --  *      *       0.0.0.0/0            10.103.1.234         /* default/my-nginx-cluster: cluster IP */ tcp dpt:80 
    0     0 KUBE-MARK-MASQ  tcp  --  *      *      !192.167.0.0/16       10.97.229.148        /* default/my-nginx-nodeport: cluster IP */ tcp dpt:80
    0     0 KUBE-SVC-6JXEEPSEELXY3JZG  tcp  --  *      *       0.0.0.0/0            10.97.229.148        /* default/my-nginx-nodeport: cluster IP */ tcp dpt:80
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 1] iptables Mode의 KUBE-SERVICES </figcaption>
</figure>

{% highlight text %}
Chain KUBE-NODEPORTS (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-loadbalancer: */ tcp dpt:30781
    0     0 KUBE-SVC-TNQCJ2KHUMKABQTD  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-loadbalancer: */ tcp dpt:30781
    0     0 KUBE-MARK-MASQ  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-nodeport: */ tcp dpt:30915
    0     0 KUBE-SVC-6JXEEPSEELXY3JZG  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-nodeport: */ tcp dpt:30915 
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 2] iptables Mode의 KUBE-NODEPORTS </figcaption>
</figure>

{% highlight text %}
Chain KUBE-FW-TNQCJ2KHUMKABQTD (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-loadbalancer: loadbalancer IP */
    0     0 KUBE-SVC-TNQCJ2KHUMKABQTD  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-loadbalancer: loadbalancer IP */
    0     0 KUBE-MARK-DROP  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-loadbalancer: loadbalancer IP */
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 3] iptables Mode의 KUBE-FW-XXX </figcaption>
</figure>

{% highlight text %}
Chain KUBE-SVC-6JXEEPSEELXY3JZG (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-SEP-6HM47TA5RTJFOZFJ  all  --  *      *       0.0.0.0/0            0.0.0.0/0            statistic mode random probability 0.33332999982
    0     0 KUBE-SEP-AHRDCNDYGFSFVA64  all  --  *      *       0.0.0.0/0            0.0.0.0/0            statistic mode random probability 0.50000000000
    0     0 KUBE-SEP-BK523K4AX5Y34OZL  all  --  *      *       0.0.0.0/0            0.0.0.0/0      
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 4] iptables Mode의 KUBE-SVC-XXX </figcaption>
</figure>

{% highlight text %}
Chain KUBE-SEP-QQATNRPNVZFKMY6D (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  all  --  *      *       192.167.1.138        0.0.0.0/0
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp to:192.167.1.138:53 
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 5] iptables Mode의 KUBE-SEP-XXX </figcaption>
</figure>

{% highlight text %}
Chain KUBE-POSTROUTING (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service traffic requiring SNAT */ mark match
0x4000/0x4000 
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 6] iptables Mode의 KUBE-POSTROUTING </figcaption>
</figure>

{% highlight text %}
Chain KUBE-MARK-MASQ (23 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x4000 
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 7] iptables Mode의 KUBE-MARK-MASQ </figcaption>
</figure>

{% highlight text %}
Chain KUBE-MARK-DROP (10 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x8000 
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 8] iptables Mode의 KUBE-MARK-DROP </figcaption>
</figure>

Service Proxy의 iptables Mode는 iptables를 이용하여 Service Proxy를 수행하는 Mode이다. 현재 Kubernetes가 이용하는 Default Proxy Mode이다. [그림 1]은 iptables Mode에서 Service 요청 Packet의 경로를 나타내고 있다. [NAT Table 1] ~ [NAT Table 8]는 [그림 1]의 주요 NAT Table의 실제 내용을 보여주고 있다. [그림 1]의 NAT Table들은 Kubernetes Cluster를 구성하는 모든 Node에 동일하게 설정된다. 따라서 Kubernetes Cluster를 구성하는 어느 Node에서도 Service 요청 Packet을 전송할 수 있다.

대부분의 Pod에서 전송된 요청 Packet은 Pod의 veth를 통해서 Host의 Network Namespace로 전달되기 때문에 요청 Packet은 PREROUTING Table에 의해서 KUBE-SERVICES Table로 전달된다. Host의 Network Namespace를 이용하는 Pod 또는 Host Process에서 전송한 요청 Packet은 OUTPUT Table에 의해서 KUBE-SERVICES Table로 전달된다. KUBE-SERVICES Table에서 요청 Packet의 Dest IP와 Dest Port가 ClusterIP Service의 IP와 Port와 일치한다면, 해당 요청 Packet은 일치하는 ClusterIP Service의 NAT Table인 KUBE-SVC-XXX Table로 전달된다.

KUBE-SERVICES Table에서 요청 Packet의 Dest IP가 Localhost인 경우에는 해당 요청 Packet은 KUBE-NODEPORTS Table로 전달된다. KUBE-NODEPORTS Table에서 요청 Packet의 Dest Port가 NodePort Service의 Port와 일치하는 경우 해당 요청 Packet은 NodePort Service의 NAT Table인 KUBE-SVC-XXX Table로 전달된다. KUBE-SERVICES Table에서 요청 Packet의 Dest IP와 Dest Port가 LoadBalancer Service의 External IP와 Port와 일치한다면 해당 요청 Packet은 일치하는 LoadBalancer Service의 NAT Table인 KUBE-FW-XXX Table로 전달된 다음, 다시 LoadBalancer Service의 NAT Table인 KUBE-SVC-XXX Table로 전달된다.

KUBE-SVC-XXX Table에서는 iptables의 statistic 기능을 이용하여 요청 Packet은 Service를 구성하는 Pod들로 랜덤하고 균등하게 Load Balancing하는 역활을 수행한다. [NAT Table 4]에서 Service는 3개의 Pod으로 구성되어 있기 때문에 3개의 KUBE-SEP-XXX Table로 요청 Packet이 랜덤하고 균등하게 Load Balancing 되도록 설정되어 있는것을 확인할 수 있다. KUBE-SEP-XXX Table에서 요청 Packet은 Pod의 IP 및 Service에서 설정한 Port로 DNAT를 수행한다. Pod의 IP로 **DNAT**된 요청 Packet은 CNI Plugin을 통해 구축된 Container Network를 통해서 해당 Pod에게 전달된다.

Service로 전달되는 요청 Packet은 iptables의 DNAT를 통해서 Pod에게 전달되기 때문에, Pod에서 전송한 응답 Packet의 Src IP는 Pod의 IP가 아닌 Service의 IP로 **SNAT**되어야 한다. iptables에는 Serivce를 위한 SNAT Rule이 명시되어 있지 않다. 하지만 iptables는 Linux Kernel의 **Conntrack** (Connection Tracking)의 TCP Connection 정보를 바탕으로 Service Pod으로부터 전달받은 응답 Packet을 SNAT한다.

#### 2.1. Hairpinning

![[그림 2] iptables Mode에서 Hairpinning 적용전 적용후의 Packet 경로]({{site.baseurl}}/images/theory_analysis/Kubernetes_Service_Proxy/iptables_Mode_Hairpinning.PNG){: width="650px"}

KUBE-MARK-MASQ Table은 요청 Packet의 Masquerade를 위해서 Packet에 Marking을 수행하는 Table이다. Marking된 Packet은 KUBE-POSTROUTING Table에서 Masquerade 된다. 즉 Packet의 Src IP가 Host의 IP로 SNAT 된다. Masquerade가 필요한 경우중 하나는 Pod에서 자신이 소속되어있는 Service의 IP로 요청 Packet을 전송하여 자기 자신에게 요청 Packet이 돌아올 경우이다. [그림 2]의 왼쪽은 이러한 경우를 나타내고 있다. 요청 Packet은 DNAT되어 Packet의 Src IP와 Dest IP는 모두 Pod의 IP가 된다. 따라서 Pod에서 돌아온 요청 Packet에 대한 응답 Packet을 보낼경우, Packet은 Host의 NAT Table을 거치지 않고 Pod안에서 처리되기 때문에 SNAT가 수행되지 않는다.

Masquerade를 이용하면 Pod에게 돌아온 요청 Packet을 강제로 Host에게 넘겨 SNAT가 수행되도록 만들 수 있다. 이처럼 Packet을 고의적으로 우회하여 받는 기법을 Hairpinning이라고 부른다. [그림 2]의 오른쪽은 Masqurade를 이용하여 Hairpinning을 적용한 경우를 나타내고 있다. KUBE-SEP-XXX Table에서 요청 Packet의 Src IP가 DNAT 하려는 IP와 동일한 경우, 즉 Pod이 Service로 전송한 Packet을 자기 자신이 받을경우 해당 요청 Packet은 KUBE-MARK-MASQ Table을 거쳐 Marking이 되고 KUBE-POSTROUTING Table에서 Masquerade 된다. Pod이 받은 Packet의 Src IP는 Host의 IP로 설정되어 있기 때문에 Pod의 응답은 Host의 NAT Table 전달되고, 다시 SNAT, DNAT 되어 Pod에게 전달된다.

### 3. Userspace Mode

![[그림 3] Userspace Mode에서 Service 요청 Packet 경로]({{site.baseurl}}/images/theory_analysis/Kubernetes_Service_Proxy/Userspace_Mode_Service_Packet_Path.PNG){: width="700px"}

{% highlight text %}
Chain KUBE-PORTALS-CONTAINER (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            10.96.98.173         /* default/my-nginx-loadbalancer: */ tcp dpt:80 redir ports 38023
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            172.35.0.200         /* default/my-nginx-loadbalancer: */ tcp dpt:80 redir ports 38023
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            10.103.1.234         /* default/my-nginx-cluster: */ tcp dpt:80 redir ports 36451
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            10.97.229.148        /* default/my-nginx-nodeport: */ tcp dpt:80 redir ports 44257
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 9] Userspace Mode의 KUBE-PORTALS-CONTAINER</figcaption>
</figure>

{% highlight text %}
Chain KUBE-NODEPORT-CONTAINER (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-loadbalancer: */ tcp dpt:30781 redir ports 38023
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-nodeport: */ tcp dpt:30915 redir ports 44257
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 10] Userspace Mode의 KUBE-NODEPORT-CONTAINER</figcaption>
</figure>

{% highlight text %}
Chain KUBE-PORTALS-HOST (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            10.96.98.173         /* default/my-nginx-loadbalancer: */ tcp dpt:80 to:172.35.0.100:38023
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            172.35.0.200         /* default/my-nginx-loadbalancer: */ tcp dpt:80 to:172.35.0.100:38023
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            10.103.1.234         /* default/my-nginx-cluster: */ tcp dpt:80 to:172.35.0.100:46635
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            10.97.229.148        /* default/my-nginx-nodeport: */ tcp dpt:80 to:172.35.0.100:32847
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 11] Userspace Mode의 KUBE-PORTALS-HOST</figcaption>
</figure>

{% highlight text %}
Chain KUBE-NODEPORT-HOST (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-loadbalancer: */ tcp dpt:30781 to:172.35.0.100:38023
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/my-nginx-nodeport: */ tcp dpt:30915 to:172.35.0.100:44257
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 12] Userspace Mode의 KUBE-NODEPORT-HOST</figcaption>
</figure>

Service Proxy의 iptables Mode는 Userspace에서 동작하는 kube-proxy가 Service Proxy 역활을 수행하는 Mode이다. Kubernetes가 처음으로 제공했던 Proxy Mode이다. 현재는 iptables Mode에 비해서 떨어지는 성능 때문에 잘 이용되지 않고 있다. [그림 3]은 Userspace Mode에서 Service 요청 Packet의 경로를 나타내고 있다. [NAT Table 9] ~ [NAT Table 12]은 [그림 3]의 주요 NAT Table의 실제 내용을 보여주고 있다. [그림 3]의 NAT Table과, kube-proxy는 Kubernetes Cluster를 구성하는 모든 Node에 동일하게 설정된다. 따라서 Kubernetes Cluster를 구성하는 어느 Node에서도 Service 요청 Packet을 전송할 수 있다.

대부분의 Pod에서 전송된 요청 Packet은 Pod의 veth를 통해서 Host의 Network Namespace로 전달되기 때문에 요청 Packet은 PREROUTING Table에 의해서 KUBE-PORTALS-CONTAINER Table로 전달된다. KUBE-PORTALS-CONTAINER Table에서 요청 Packet의 Dest IP와 Dest Port가 ClusterIP Service의 IP와 Port와 일치한다면, 해당 요청 Packet은 kube-proxy로 **Redirect**된다. 요청 Packet의 Dest IP가 Localhost인 경우에는 해당 Packet은 KUBE-NODEPORT-CONTAINER Table로 전달된다. KUBE-NODEPORT-CONTAINER Table에서 요청 Packet의 Dest Port가 NodePort Service의 Port와 일치하는 경우 해당 요청 Packet은 kube-proxy로 Redirect된다. 요청 Packet의 Dest IP와 Dest Port가 LoadBalancer Service의 External IP와 Port와 일치한다면 해당 요청의 Packet도 kube-proxy로 Redirect된다.

Host의 Network Namespace를 이용하는 Pod 또는 Host Process에서 전송한 요청 Packet은 OUTPUT Table에 의해서 KUBE-PORTALS-HOST Table로 전달된다. 이후의 KUBE-PORTALS-HOST, KUBE-NODEPORT-HOST Table에서의 요청 Packet 처리과정은 KUBE-PORTALS-CONTAINER, KUBE-NODEPORT-CONTAINER Table에서의 요청 Packet 처리와 유사하다. 차이점은 요청 Packet을 Redirect하지 않고 **DNAT**를 수행한다는 점이다.

**Redirect, DNAT를 통해서 Service로 전송한 모든 요청 Packet은 kube-proxy로 전달된다.** kube-proxy가 받는 요청 Packet의 Dest Port 하나당 하나의 Service가 Mapping 되어있다. 따라서 kube-proxy는 Redirect, NAT된 요청 Packet의 Dest Port를 통해서 해당 요청 Packet이 어느 Service로 전달되어야 하는지 파악할 수 있다. kube-proxy는 전달받은 요청 Packet을 요청 Packet이 전송되어야하는 Service에 속한 다수의 Pod에게 균등하게 Load Balancing하여 다시 전송한다.

kube-proxy는 Host의 Network Namespace에서 동작하기 때문에 kube-proxy가 전송한 요청 Packet 또한 Service NAT Table들을 거친다. 하지만 kube-proxy가 전송한 요청 Packet의 Dest IP는 Pod의 IP이기 때문에 해당 요청 Packet은 Service NAT Table에 의해서 변경되지 않고, CNI Plugin을 통해 구축된 Container Network를 통해서 해당 Pod에게 전달된다.

### 4. IPVS Mode

![[그림 4] IPVS Mode에서 Service 요청 Packet 경로]({{site.baseurl}}/images/theory_analysis/Kubernetes_Service_Proxy/IPVS_Mode_Service_Packet_Path.PNG){: width="700px"}

{% highlight text %}
Chain KUBE-SERVICES (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-LOAD-BALANCER  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Kubernetes service lb portal */ match-set KUBE-LOAD-BALANCER dst,dst
    0     0 KUBE-MARK-MASQ  all  --  *      *      !192.167.0.0/16       0.0.0.0/0            /* Kubernetes service cluster ip + port for masquerade purpose */ match-set KUBE-CLUSTER-IP dst,dst
    8   483 KUBE-NODE-PORT  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            match-set KUBE-CLUSTER-IP dst,dst
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            match-set KUBE-LOAD-BALANCER dst,dst
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 13] IPVS Mode의 KUBE-SERVICES </figcaption>
</figure>

{% highlight text %}
Chain KUBE-NODE-PORT (1 references)
 pkts bytes target     prot opt in     out     source               destination
    6   360 KUBE-MARK-MASQ  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Kubernetes nodeport TCP port for masquerade purpose */ match-set KUBE-NODE-PORT-TCP dst
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 12] IPVS Mode의 KUBE-POSTROUTING </figcaption>
</figure>

{% highlight text %}
Chain KUBE-LOAD-BALANCER (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  all  --  *      *       0.0.0.0/0            0.0.0.0/0 
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 13] IPVS Mode의 KUBE-LOAD-BALANCER </figcaption>
</figure>

{% highlight text %}
Chain KUBE-POSTROUTING (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service traffic requiring SNAT */ mark match 0x4000/0x4000
    1    60 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* Kubernetes endpoints dst ip:port, source ip for solving hairpinpurpose */ match-set KUBE-LOOP-BACK dst,dst,src
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 14] IPVS Mode의 KUBE-POSTROUTING </figcaption>
</figure>

{% highlight text %}
Chain KUBE-MARK-MASQ (3 references)
 pkts bytes target     prot opt in     out     source               destination         
    2   120 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x4000
{% endhighlight %}
<figure>
<figcaption class="caption">[NAT Table 15] IPVS Mode의 KUBE-MARK-MASQ </figcaption>
</figure>

{% highlight text %}
Name: KUBE-CLUSTER-IP
Type: hash:ip,port
Revision: 5
Header: family inet hashsize 1024 maxelem 65536
Size in memory: 600
References: 2
Number of entries: 1
Members:
10.96.98.173,tcp:80 
10.97.229.148,tcp:80
10.103.1.234,tcp:80 

Name: KUBE-LOOP-BACK
Type: hash:ip,port,ip
Revision: 5
Header: family inet hashsize 1024 maxelem 65536
Size in memory: 896
References: 1
Number of entries: 3
Members:
192.167.2.231,tcp:80,192.167.2.231
192.167.1.123,tcp:80,192.167.1.123
192.167.2.206,tcp:80,192.167.2.206

Name: KUBE-NODE-PORT-TCP
Type: bitmap:port
Revision: 3
Header: range 0-65535
Size in memory: 8268
References: 1
Number of entries: 2
Members:
30781
30915

Name: KUBE-LOAD-BALANCER
Type: hash:ip,port
Revision: 5
Header: family inet hashsize 1024 maxelem 65536
Size in memory: 152
References: 2
Number of entries: 1
Members:
172.35.0.200,tcp:80 
{% endhighlight %}
<figure>
<figcaption class="caption">[IPset List 1] IPVS Mode의 IPset List </figcaption>
</figure>

{% highlight text %}
TCP  172.35.0.100:30781 rr
  -> 192.167.1.123:80             Masq    1      0          0
  -> 192.167.2.206:80             Masq    1      0          0
  -> 192.167.2.231:80             Masq    1      0          0
TCP  172.35.0.100:30915 rr
  -> 192.167.1.123:80             Masq    1      0          0
  -> 192.167.2.206:80             Masq    1      0          0
  -> 192.167.2.231:80             Masq    1      0          0
TCP  172.35.0.200:80 rr
  -> 192.167.1.123:80             Masq    1      0          0
  -> 192.167.2.206:80             Masq    1      0          0
  -> 192.167.2.231:80             Masq    1      0          0    
TCP  10.96.98.173:80 rr
  -> 192.167.1.123:80             Masq    1      0          0
  -> 192.167.2.206:80             Masq    1      0          0
  -> 192.167.2.231:80             Masq    1      0          0
TCP  10.97.229.148:80 rr
  -> 192.167.1.123:80             Masq    1      0          0
  -> 192.167.2.206:80             Masq    1      0          0
  -> 192.167.2.231:80             Masq    1      0          0   
TCP  10.103.1.234:80 rr
  -> 192.167.1.123:80             Masq    1      0          0
  -> 192.167.2.206:80             Masq    1      0          0
  -> 192.167.2.231:80             Masq    1      0          0         
{% endhighlight %}
<figure>
<figcaption class="caption">[IPVS List 1] IPVS Mode의 IPVS List </figcaption>
</figure>

Service Proxy의 IPVS Mode는 Linue Kernel에서 제공하는 L4 Load Balacner인 IPVS가 Service Proxy 역활을 수행하는 Mode이다. Packet Load Balancing 수행시 IPVS가 iptables보다 높은 성능을 보이기 때문에 IPVS Mode는 iptables Mode보다 높은 성능을 보여준다. [그림 4]는 IPVS Mode에서 Service로 전송되는 요청 Packet의 경로를 나타내고 있다. [NAT Table 13] ~ [NAT Table 15]는 [그림 4]의 주요 NAT Table의 실제 내용을 보여주고 있다. [IPset List 1]는 IPVS Mode의 주요 IPset 목록을 보여주고 있다. [IPVS List 1]는 [그림 4]의 IPVS의 실제 내용을 보여주고 있다. [그림 4]의 NAT Table, IPset, IPVS는 Kubernetes Cluster를 구성하는 모든 Node에 동일하게 설정된다. 따라서 Kubernetes Cluster를 구성하는 어느 Node에서도 Service 요청 Packet을 전송할 수 있다.

대부분의 Pod에서 전송된 요청 Packet은 Pod의 veth를 통해서 Host의 Network Namespace로 전달되기 때문에 요청 Packet은 PREROUTING Table에 의해서 KUBE-SERVICES Table로 전달된다. Host의 Network Namespace를 이용하는 Pod 또는 Host Process에서 전송한 요청 Packet은 OUTPUT Table에 의해서 KUBE-SERVICES Table로 전달된다. KUBE-SERVICES Table에서 요청 Packet의 Dest IP와 Dest Port가 ClusterIP Service의 IP와 Port와 일치한다면, 해당 요청 Packet은 INPUT Table을 거쳐 IPVS로 전달된다. 요청 Packet의 Dest IP가 Localhost인 경우에는 해당 요청 Packet은 KUBE-NODE-PORT Table과 INPUT Table을 거쳐 IPVS로 전달된다. 요청 Packet의 Dest IP와 Dest Port가 LoadBalancer Service의 External IP와 Port와 일치한다면 해당 요청의 Packet은 KUBE-LOAD-BALANCER Table과 INPUT Table을 거쳐 IPVS로 전달된다.

IPVS는 요청 Packet의 Dest IP, Dest Port가 Service의 Cluster-IP와 Port와 일치하는 경우, 요청 Packet의 Dest IP가 LocalHost이고 Dest Port가 NodePort Service의 NodePort와 일치하는 경우, 요청 Packet의 Dest IP, Dest Port가 LoadBalancer Service의 External IP와 Port와 일치하는 경우, 해당 요청 Packet을 Load Balancing 및 Pod의 IP와 Service에서 설정한 Port로 **DNAT**를 수행한다. Pod의 IP로 DNAT된 요청 Packet은 CNI Plugin을 통해 구축된 Container Network를 통해서 해당 Pod에게 전달된다. [IPVS List 1]에서 Service들과 연관된 모든 IP를 대상으로 Load Balancing 및 DNAT를 수행하는 것을 확인할 수 있다.

IPVS도 iptables와 동일하게 Linux Kernel의 Contrack의 TCP Connection 정보를 이용한다. 따라서 IPVS로 인하여 DNAT되어 전송된 Service Packet의 응답 Packet은 IPVS가 다시 SNAT하여 Service를 요청한 Pod 또는 Host Process에게 전달된다. IPVS Mode에서도 iptables Mode 처럼 Service 응답 Packet의 SNAT 문제를 해결하기 위해서 Hairpinning이 적용되어 있다. KUBE-POSTROUTING Table에서 KUBE-LOOP-BACK IPset 규칙에 부합하면 Masquerade를 수행하는 것을 알수 있다. KUBE-LOOP-BACK IPset에 Packet의 Src IP, Dest IP가 동일한 Pod의 IP일수 있는 모든 경우의 수가 포함되어 있는것을 확인할 수 있다.

### 5. 참조

* [https://www.slideshare.net/Docker/deep-dive-in-container-service-discovery](https://www.slideshare.net/Docker/deep-dive-in-container-service-discovery)
* [http://www.system-rescue-cd.org/networking/Load-balancing-using-iptables-with-connmark/](http://www.system-rescue-cd.org/networking/Load-balancing-using-iptables-with-connmark/)
* [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)