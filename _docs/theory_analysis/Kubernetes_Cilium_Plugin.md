---
title: Kubernetes Cilium Plugin
category: Theory, Analysis
date: 2019-02-06T12:00:00Z
lastmod: 2019-02-06T12:00:00Z
comment: true
adsense: true
---

Kubernetes Network Plugin인 Cilium을 분석한다.

### 1. Cilium

![[그림 1] Cilium 구성요소]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Components.PNG){: width="600px"}

Cilium은 **BPF (Berkeley Packet Filter)**를 기반으로 Pod Network를 구축하는 CNI Plugin이다. Kubernetes의 Network Plugin으로 많이 이용되고 있다. [그림 1]은 Kubernetes의 Plugin으로 동작하는 Cilium의 구성요소를 나타내고 있다. 크게 **etcd, cilium-agent, BPF** 3가지로 구성되어 있다. cilium-agent는 모든 Kubernetes Host 위에서 동작하는 cilium Pod안에서 동작한다. cilium Pod은 Host(Node)의 Network Namespace를 이용하기 때문에 cilium Pod안에서 동작하는 App은 Host의 Network 설정을 조회하거나 제어 할 수 있다.

* etcd : etcd는 분산 Key-Value store이다. Cilium 구동에 필요한 Network 구성/설정 정보, Cilium 설정 정보 등 다양한 정보를 저장한다. 또한 저장한 key-value값이 변경될 경우 cilium-agent에게 변경 정보를 전달하는 Communication Bus 역할도 수행한다.

* cilium-agent : cilium-agent는 Host의 Network를 설정 및 Monitoring을 하는 Daemon이다. 필요에 따라 BPF를 Linux Kernel에 삽입하고 제어한다. 또한 cilium-agent는 cilium-node-monitor 및 cilium-health 실행한다. cilium-node-monitor는 BPF의 Event를 수신하고 전달한다. cilium-health는 cilium-agent의 상태를 외부의 Host에게 전달하거나, 외부 Host의 cilium-agent의 상태 정보를 얻는다. cilium-agent는 API 또는 cilium CLI를 통해서 제어가 가능하다.

* BPF : BPF는 Linux Kernel 안에서 Packet Routing 및 Filtering을 수행한다. 일반적으로 BPF는 기존의 Linux Netfilter Framework 기반의 iptables 및 Routing Table에 비해서 낮은 Network Stack에서 동작하기 때문에 높은 성능이 가장 큰 장점이다. Cilium은 BPF 이용을 통해서 Netfilter Framework 및 Routing Table의 사용을 최소화하여 Network 성능을 끌어올린다.

#### 1.1. Pod Network

Cilium은 Pod Network를 구축하는 방법으로 VXLAN 기반의 기법과 Host Network를 그대로 이용하는 기법 2가지를 제공한다.

##### 1.1.1. with VXLAN

![[그림 2] Cilium VXLAN Pod Network]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Network_VXLAN.PNG)

[그림 2]는 Cilium과 VXLAN을 이용하여 구축한 Pod Network를 나타낸다. Host의 Network는 10.0.0.0/24이고, Pod Network는 10.244.0.0/16이다. Cilium은 etcd에 저장된 정보를 바탕으로 각 Host에 Pod Network를 할당한다. 그림에서 Host 1은 192.167.2.0/24 Network가 할당되었다. 따라서 Host 1에 생긴 Pod A의 IP는 192.167.2.0/24 Network에 속한 IP인 192.167.2.10을 이용한다. Host 2에는 192.167.3.0/24 Network가 할당되었기 때문에 Host 2에 생긴 Pod C의 IP는 192.167.3.0/24 Network에 속한 IP인 192.167.3.10를 이용한다.

{% highlight text %}
# cilium map get cilium_lxc
Key               Value                                                                               State   Error
30.0.0.160:0      (localhost)                                                                         sync
192.167.1.138:0   (localhost)                                                                         sync
192.167.1.235:0   id=829   flags=0x0000 ifindex=8   mac=F2:EC:03:FC:7A:BF nodemac=FA:7D:9E:AF:1E:01   sync
192.167.1.139:0   id=53    flags=0x0000 ifindex=10  mac=DE:B8:9A:BA:37:5E nodemac=D6:EB:D8:44:E9:AD   sync    
# cilium endpoint list
ENDPOINT   POLICY (ingress)   POLICY (egress)   IDENTITY   LABELS (source:key[=value])                       IPv6   IPv4            STATUS
           ENFORCEMENT        ENFORCEMENT
691        Disabled           Disabled          32535      k8s:io.cilium.k8s.policy.cluster=default                 192.167.2.176   ready
                                                           k8s:io.cilium.k8s.policy.serviceaccount=default
                                                           k8s:io.kubernetes.pod.namespace=default
                                                           k8s:run=my-nginx
2296       Disabled           Disabled          104        k8s:io.cilium.k8s.policy.cluster=default                 192.167.2.194   ready
                                                           k8s:io.cilium.k8s.policy.serviceaccount=coredns
                                                           k8s:io.kubernetes.pod.namespace=kube-system
                                                           k8s:k8s-app=kube-dns
3424       Disabled           Disabled          104        k8s:io.cilium.k8s.policy.cluster=default                 192.167.2.32    ready
                                                           k8s:io.cilium.k8s.policy.serviceaccount=coredns
                                                           k8s:io.kubernetes.pod.namespace=kube-system
                                                           k8s:k8s-app=kube-dns
3787       Disabled           Disabled          4          reserved:health                                          192.167.2.88    ready 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Cilium Endpoint</figcaption>
</figure>

Pod Network 구축시 이용하는 주요 BPF는 VXLAN Interface에 붙는 tc action ingress BPF, Pod의 veth Interface에 붙는 tc action ingress BPF, Cilium을 위해 Host에 생성한 veth Inteface인 cilium_host에 붙는 tc action engress BPF, 3가지 BPF가 이용된다. 모든 BPF는 Packet의 Dest IP가 Pod의 IP라면, Packet을 Pod으로 바로 **Routing**한다. Cilium이 이용하는 etcd에는 **Endpoint**라는 이름으로 Cilium이 관리하는 모든 Pod의 IP, MAC을 저장하고 관리하고 있다. cilium-agent는 자신이 동작하고 있는 Host의 Pod의 IP를 etcd로부터 얻어와 BPF Map에 저장한다. [Shell 1]은 'cilium map get cilium_lxc' 또는 'cilium endpoint list' 명령어를 이용하여 특정 Host에 있는 모든 Pod의 IP를 조회하는 Shell의 모습을 나타내고 있다. BPF는 BPF Map에 저장한 Pod의 IP 정보를 바탕으로 Packet을 Pod으로 Routing한다.

특정 Pod에서 같은 Host에 있는 Pod으로 Packet을 전송하는 경우, Packet은 Routing Table을 거치지 않고, Pod의 veth Interface에 붙는 tc action ingress BPF만을 이용하여 Packet을 주고 받는다. [그림 2]의 Pod A/B 또는 Pod C/D의 Packet 경로가 예가 될 수 있다. 특정 Pod에서 다른 Host에 있는 Pod에 Packet을 전송하는 경우, Packet은 Routing Table로 전달되고 Routing Table의 Rule에 따라서 Packet은 다시 cilium_host의 tc action engress BPF로 전달된다. cilium_host의 tc action engress BPF은 전달 받은 Packet의 Dest IP가 유효한지 검사한 다음, 유효하다면 cilium_vxlan으로 Routing한다. cilium_vxlan으로 전달된 Packet은 Packet의 Dest Pod이 있는 Host의 cilium_vxlan의 tc action ingress으로 전달되고, 다시 Routing되어 해당 Pod으로 전달된다. [그림 2]의 Pod A/B와 Pod C/D의 경로가 예가 될 수 있다.

특정 Pod에서 Pod이 아닌 외부로 Packet을 전송하게 되면 Packet을 Routing Table에 전달되고, Routing Table의 Rule에 따라서 Packet은 Routing Table의 Rule에 따라서 전달된다. [그림 2]에서 Pod이 외부로 전송한 Packet은 Routing Table에 의해서 바로 eth0로 전달되어 외부로 전달된다. Pod Network NS에 존재하는 Process가 아닌 Host의 Network NS에 존재하는 Process도 Pod의 IP로 Packet을 전달할 경우 Routing Table에 의해서 Packet은 cilium_host의 tc action engress BPF로 전달되기 때문에 해당 Pod과 Packet을 주고 받을 수 있다.

##### 1.1.2. with Host L3

![[그림 3] Cilium Host L3 Pod Network]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Network_Host.PNG)

[그림 3]은 Cilium과 Host L3 Network를 이용하여 구축한 Pod Network를 나타낸다. 각 Host에 할당된 Pod Network, Host IP, Pod IP는 VXLAN 기법의 예제와 동일하다. VXLAN 기법과의 차이점은 VXLAN Interface 및 VXLAN Interface에 붙는 tc action ingress BPF가 존재하지 않는다. Host의 Routing Table에는 각 Host에게 할당된 Pod Network 관련 Rule만 있다. [그림 3]에서 Host 1의 Routing Table에는 Host 1에 할당된 Pod Network인 192.167.2.0/24 관련 Rule만 있지 Host 2에 할당된 Pod Network인 192.167.3.0/24 관련 Rule은 없다. 마지막으로 Host 사이에는 반드시 L3 Router가 존재한다. L3 Router는 각 Host에 할당된 Pod Network 정보를 바탕으로 Pod으로 전달해야할 Packet을 적절한 Host로 Routing 해야한다.

특정 Pod에서 같은 Host에 있는 Pod으로 Packet을 전송하는 경우에는 VXLAN을 이용할 경우와 동일하다. 특정 Pod에서 다른 Host에 있는 Pod에 Packet을 전송하는 경우, Packet은 Routing Table에 따라서 외부의 L3 Router에 전달된다. L3 Router는 Packet을 Pod이 존재하는 Host로 전송하고, Packet을 받은 Host는 Routing Table에 따라서 해당 Pod으로 전달한다. [그림 2]의 Pod A/B와 Pod C/D의 경로가 예가 될 수 있다. Pod Network NS에 존재하는 Process가 아닌 Host의 Network NS에 존재하는 Process도 Pod의 IP로 Packet을 전달할 경우에도 VXLAN을 이용할 경우와 동일하다.

#### 1.2. Connection Tracking

{% highlight text %}
# cilium bpf ct list global
TCP IN 192.167.0.113:58044 -> 192.167.0.175:8080 expires=247809 RxPackets=6 RxBytes=525 RxFlagsSeen=0x1b LastRxReport=247799 TxPackets=4 TxBytes=409 TxFlagsSeen=0x1b LastTxReport=247799 Flags=0x0013 [ RxClosing TxClosing SeenNonSyn ] RevNAT=0 SourceSecurityID=1
TCP OUT 30.0.0.34:59050 -> 192.168.0.40:8774 expires=246703 RxPackets=4 RxBytes=2436 RxFlagsSeen=0x13 LastRxReport=246693 TxPackets=5 TxBytes=761 TxFlagsSeen=0x1b LastTxReport=246693 Flags=0x0013 [ RxClosing TxClosing SeenNonSyn ] RevNAT=0 SourceSecurityID=0
ICMP OUT 30.0.0.34:49527 -> 30.0.0.79:0 expires=258603 RxPackets=1 RxBytes=50 RxFlagsSeen=0x00 LastRxReport=258543 TxPackets=1 TxBytes=50 TxFlagsSeen=0x00 LastTxReport=258543 Flags=0x0000 [ ] RevNAT=0 SourceSecurityID=0
ICMP IN 192.167.1.109:25170 -> 192.167.0.76:0 expires=256931 RxPackets=1 RxBytes=50 RxFlagsSeen=0x00 LastRxReport=256871 TxPackets=1 TxBytes=50 TxFlagsSeen=0x00 LastTxReport=256871 Flags=0x0000 [ ] RevNAT=0 SourceSecurityID=1
ICMP IN 30.0.0.160:0 -> 30.0.0.34:58168 expires=250323 RxPackets=1 RxBytes=50 RxFlagsSeen=0x00 LastRxReport=250263 TxPackets=0 TxBytes=0 TxFlagsSeen=0x00 LastTxReport=0 Flags=0x0000 [ ] RevNAT=0 SourceSecurityID=0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Cilium Connection Info</figcaption>
</figure>

Cilium은 Pod의 Connection 정보를 Linux conntrack을 이용하지 않고 BPF와 BPF MAP을 이용하여 직접 관리한다. [Shell 2]는 'cilium bpf ct list global' 명령어를 이용하여 BPF Map에 저장되어 있는 Connection 정보를 출력하는 Shell을 나타내고 있다.

#### 1.3. Service Load Balancing

{% highlight text %}
# cilium service list
ID   Frontend           Backend
1    10.96.0.10:53      1 => 192.167.2.194:53
                        2 => 192.167.2.32:53
2    10.96.0.10:9153    1 => 192.167.2.194:9153
                        2 => 192.167.2.32:9153
3    10.96.0.1:443      1 => 30.0.0.34:6443
4    10.97.188.211:80   1 => 192.167.1.139:80
                        2 => 192.167.2.176:80
5    10.109.68.251:80   1 => 30.0.0.160:80
                        2 => 30.0.0.79:80  
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Cilium Service</figcaption>
</figure>

Cilium에서 제공하는 추가적인 기능중 하나는 Service Load Balancing을 지원한다는 점이다. Cilium은 Kubernetes API Server로부터 Service 정보를 얻어 BPF에 저장한다. [Shell 3]은 'cilium service list' 명령어를 이용하여 BPF Map에 저장되어 있는 Service 정보를 출력하는 Shell을 나타내고 있다. Frontent는 Kubernetes Service의 Cluster IP를 의미하고, Backend는 해당 Service에 소속되어 있는 Pod의 IP를 의미한다. Cilium은 BPF Map의 Service 정보를 바탕으로 전달 받은 Packet의 Src IP가 Service IP인 경우, 해당 Packet의 Dest IP를 Service에 소속된 임의의 Pod의 IP로 **DNAT**하여 Load Balancing을 수행한다.

Load Balancing Algorithm은 **Random 방식**과 Cilium이 저장하는 Connection 정보를 기반으로 하는 **Affinity 방식을** 혼용한다. Cilium은 Pod에서 Service로 전송시 BPF Map에 출발지 Pod과 목적지 Service에 소속된 임의의 Pod 사이의 Connection 정보가 있는지 확인한다. 관련 Connection 정보가 없다면 Cilium은 목적지 Service에 소속된 임의의 Pod을 선택하여 Packet을 전송하고 관련 Connection 정보를 BPF MAP에 추가한다. 관련 Connection 정보가 있다면 Connection 정보가 가리키는 기존에 보냈던 목적지 Service의 Pod으로 Packet을 다시 전송한다.

##### 1.3.1. with VXLAN

![[그림 3] Cilium Service Load Balancing with VXLAN]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Service_VXLAN.PNG)

[그림 3]은 VXLAN을 이용할 경우 특정 Pod 또는 Host Network NS에 존재하는 Host Process가 Service IP (Cluster IP)에게 Packet을 전송할 경우 발생하는 DNAT/SNAT를 나타내고 있다. Pod에서 전송한 Packet은 Pod의 veth Interface에 붙는 tc action ingress BPF에서 DNAT되고, 이에 대한 응답은 응답을 준 Pod의 위치에 따라서 veth Interface의 tc action ingress BPF 또는 cilium_vxlan의 tc action ingress BPF에서 SNAT 된다.

cilium 16.xx 이전 Version의 경우에 Host Process의 경우 BPF를 이용하지 않고, kube-proxy가 설정하는 iptables 또는 IPVS를 이용하여 DNAT/SNAT를 수행한다. cilium 16.xx 이후 Version에서는 cgroup BPF를 이용하여 DNAT/SNAT를 수행할 수 있는 기능이 추가 되었다. 물론 cgroup BPF를 지원하는 Kernel Version에서만 이용할 수 있다.

##### 1.3.2. with Host L3

![[그림 4] Cilium Service Load Balancing with Host L3]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Service_Host.PNG)

[그림 4]는 Host L3 Network을 이용할 경우 특정 Pod 또는 Host Network NS에 존재하는 Host Process가 Service IP (Cluster IP)에게 Packet을 전송할 경우 발생하는 DNAT/SNAT를 나타내고 있다. Service와 연결된 Pod이 외부에 있을경우 SNAT가 cilium_host의 tc action engress BPF에서 수행된다는 점을 제외하고는 VXLAN을 이용할때와 크게 다르지 않다.

#### 1.4. Filtering

Cilium에서 제공하는 추가적인 기능중 하나는 Packet Filtering이다. Cilium의 Filtering 기법은 Cilium에서 제공하는 CiliumNetworkPolicy CRD를 통해서 정의하는 Network Policy 기법과 XDP를 이용하는 Prefileter 기법 두가지가 존재한다.

##### 1.4.1. Network Policy

{% highlight text %}
# cilium policy get
[
  {
    "endpointSelector": {
      "matchLabels": {
        "any:org": "ssup2",
        "k8s:io.kubernetes.pod.namespace": "default"
      }
    },
    "ingress": [
      {
        "fromEndpoints": [
          {
            "matchLabels": {
              "any:org": "ssup2",
              "k8s:io.kubernetes.pod.namespace": "default"
            }
          }
        ],
        "toPorts": [
          {
            "ports": [
              {
                "port": "80",
                "protocol": "TCP"
...  
]
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Cilium Network Policy</figcaption>
</figure>

Cilium이 설치되면 **CiliumNetworkPolicy** CRD를 이용하여 Network Policy를 정의할 수 있다. Network Policy을 통해서 L3, L4, L7 Level Packet Filtering Rule을 정의할 수 있다. [Shell 4]는 정의된 Network Policy를 'cilium policy get' 명령어를 통해서 확인하는 Shell의 모습을 나타내고 있다. 정의된 Network Policy는 [그림 1] 또는 [그림 2]에 나타난 모든 BPF에서 Packet을 전송할때 적용된다.

##### 1.4.2. Prefilter

![[그림 5] Cilium Prefilter]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Prefilter.PNG)

Cilium은 XDP (eXpress Data Path)를 이용한 Packet Filteirng 기능도 제공한다. Cilium에서는 Prefilter라고 호칭한다. Kubernets Cluster Network를 구성하는 NIC의 Interface에 XDP BPF를 삽입시켜 동작한다. Generic XDP, Native XDP 2가지 방식 모두 제공한다. prefilter를 통해서 CIDR로 설정한 특정 Network의 Packet만 받도록 설정할 수 있다. prefilter 설정은 cilium-agent의 Config를 통해서 진행이 가능하다.

### 2. 참조

* [https://docs.cilium.io/en/v1.4/concepts/](https://docs.cilium.io/en/v1.4/concepts/) 
* [https://docs.cilium.io/en/v1.4/architecture/](https://docs.cilium.io/en/v1.4/architecture/)
* [https://github.com/cilium/cilium/commit/5e3e420f7927647b780c01d986ecaeff1bf32846#diff-9c45a228401ffc83c5c6ad50c7cc825b](https://github.com/cilium/cilium/commit/5e3e420f7927647b780c01d986ecaeff1bf32846#diff-9c45a228401ffc83c5c6ad50c7cc825b)
* [https://github.com/cilium/cilium/tree/master/monitor](https://github.com/cilium/cilium/tree/master/monitor)
* [https://ddiiwoong.github.io/2018/cilium-1/](https://ddiiwoong.github.io/2018/cilium-1/)
* [https://github.com/cilium/cilium/commit/b52130c55ee68a3de08125d29a91953de092338f#diff-01a7217c02bf211c22c4c232517f2dfb](https://github.com/cilium/cilium/commit/b52130c55ee68a3de08125d29a91953de092338f#diff-01a7217c02bf211c22c4c232517f2dfb)
* [https://kccncna19.sched.com/event/Uae7](https://kccncna19.sched.com/event/Uae7)
* [https://docs.cilium.io/en/v1.6/gettingstarted/host-services/](https://docs.cilium.io/en/v1.6/gettingstarted/host-services/)