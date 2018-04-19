---
title: SLB (Server Load Balancing)
category: Theory, Analysis
date: 2017-10-05T12:00:00Z
lastmod: 2017-10-05T12:00:00Z
comment: true
adsense: true
---

SLB(Server Load Balancing) 기법을 분석한다.

### 1. SLB (Server Load Balancing)

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB.PNG){: width="450px"}

SLB는 의미 그대로 Server의 부하를 조절하는 기법을 의미한다. SLB는 **LB(Load Balancer)**와 **VIP(Virtual IP)**로 구성된다. LB는 Server에 전달되야 하는 Client의 요청을 대신 받아 적절한 Server에게 전달하는 역활을 수행한다. VIP(Virtual IP)는 Load Balancing의 대상이 되는 여러 Server들을 대표하는 하나의 가상 IP이다. Client는 각 Server의 IP가 아닌 LB가 갖고 있는 VIP(Virtual IP)를 대상으로 요청한다. 따라서 Client는 여러 Server들의 존재를 알지 못하고 하나의 Server와 통신한다고 생각한다.

SLB의 핵심은 LB의 역활이다. LB는 어떻게 Load Balancing을 수행할지 결정해야한다. Load Balancing 기법은 다음과 같은 기법들이 존재한다.
* Round Robin - Round Robin 알고리즘을 바탕으로 Server를 선택한다.
* Least Connection - 현재 Connection의 개수가 가장 적은 Server를 선택한다.
* RTT - RTT(Round Trip Time)이 가장 작은 Server를 선택한다.
* Priority - 우선순위가 높은 Server 선택한다. 만약 우선순위가 높은 서버의 상태가 비정상이라면, 그 다음 우선순위가 높은 서버를 선택한다.

또한 Load Balancing시에 고려할 중요 요소 중 하나는 Session이다. 같은 Session아래 발생한 여러 Connection들이 서로 다른 Server에 전달된다면 Session은 유지되지 못한다. LB가 Session을 파악하기 위해서는 전달받은 Packet들이 동일한 Client로부터 전송됬다는 사실을 파악 할 수 있어야 한다. 일반적으로 Packet의 Source IP Address와 Source Port 번호가 같다면 동일한 Client의 Packet이라고 간주한다. 따라서 LB는 최소 L4 Layer Stack을 인지하고 있어야 한다. 마지막으로 LB는 주기적으로 Server들의 상태를 파악하여 Load Balancing시 비정상 상태의 Server에게 Client의 요청이 전달되지 않도록 해야한다.

#### 1.1. Proxy

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_Proxy.PNG)

Server가 Client로부터 받는 Inbound Packet과 Server가 Client에게 전달하는 Outbound Packet 모두 LB를 거친다. LB에서 Inbound Packet의 Source IP는 SNAT(Src NAT)를 통해 LB의 VIP로 바뀌고, Destination IP는 DNAT(Dst NAT)를 통해 실제 Server의 IP로 바뀐다. 그 후 Inbound Packet은 실제 Server에게 전달된다. 실제 Server는 LB가 Client라고 생각하고 받은 Packet의 Src IP와 Dst IP를 바꾸어 LB에게 응답 Packet을 전송한다. LB는 다시 SNAT,DNAT를 수행하여 원래의 IP로 바꾸어 Client에게 응답을 전달한다.

모든 Inbound, Outbound Packet은 Proxy를 지나기 때문에 LB 수행뿐 아니라 Packet Filtering 수행에도 유리한 기법이다. 또한 Proxy기법은 별도의 Network 설정없이 구현 가능한 기법이다. 따라서 Software LB는 Proxy 기법을 이용하여 구현된다. Proxy 기법은 실제 Client의 IP가 Server에 전달되지 않기 때문에 Server가 실제 Client의 IP를 이용해야 할 경우 부적합한 기법이다.

#### 1.2. Inline (Transparent)

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_Inline.PNG)

Proxy 기법처럼 Inbound Packet과 Outbound Packet 모두 LB를 거친다. LB에서 Inbound Packet은 실제 Server에 전달하기 위해 DNAT(Dst NAT)만을 수행한뒤 실제 Server에게 전달된다. Server의 Default Gateway는 LB로 설정되어 있기 때문에 Outbound Packet은 LB로 전달된다. Outbound Packet은 LB에서 다시 SNAT(Src NAT)를 통해서 Src IP를 LB의 VIP로 변환한다.

Proxy 기법과 다르게 Client의 IP가 Server에게 전달된다. 하지만 실제 Server의 Gateway로 LB가 이용되기 때문에 LB와 Server가 같은 Network에 있어야한다.

#### 1.3. DSR (Direct Server Routing)

Proxy, Inline 기법은 모든 Inbound, Outbound Packet을 처리해야하기 때문에 LB에 많은 부하가 발생한다. DSR 기법은 이러한 LB 부하를 줄일 수 있는 기법이다. 대부분의 Service들은 Inbound Packet보다 Outbound Packet의 양이 더 많다. DSR 기법은 Outbound Packet이 LB를 거치지 않고 바로 Client에게 전달하게 만들어 LB 부하를 줄인다.

##### 1.3.1. L2DSR

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_L2DSR.PNG)

L2DSR은 Inbound의 Packet의 Dst Mac을 바꾸는 기법이다. LB는 Inbound Packet의 Mac Address를 Server의 Mac Address로 변환한 후 실제 Server에게 전달한다. 그 후 실제 Server는 VIP 주소를 갖고 있는 Loopback Interface를 통해 Src IP를 변환하여 Client에게 바로 Outbound Packet을 전달한다. Inbound Packet의 Mac Address만 바꾸기 때문에 LB와 Server들은 반드시 같은 Network에 속해야 한다.

##### 1.3.2. L3DSR

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_L3DSR_DSCP.PNG)

L3DSR은 L2DSR의 LB와 Server들이 반드시 같은 Network에 속해야 하는 한계점을 극복하기 위해 나온 기법이다. L3DSR은 Inbound Packet의 Dst IP를 바꾸는 기법이다. 이와 더불어 Server가 VIP 정보를 알 수 있게 Inbound Packet의 DSCP Field를 변경하거나, Inbound Packet을 Tunneling한다. 위의 그림은 DSCP Field를 이용하는 L3DSR을 나타내고 있다. LB와 모든 Server는 DSCP/VIP Mapping Table을 알고 있다. LB는 Inbound Packet의 Dst IP를 실제 Server의 IP로 변환하고, Packet의 Dst IP 정보와 Mapaping Table 정보를 바탕으로 DSCP 값도 변경한다. 그 후 실제 Server에게 전달한다. Packet을 받은 Server는 Mapaping Table과 Loopback Interface를 통해 Src IP를 변경하고 DSCP 값을 0으로 만들어 Client에게 바로 전달한다.

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_L3DSR_Tunnel.PNG)

Packet을 Tunneling 하는 기법도 DSCP 기법과 유사하다. LB와 Server들은 Tunnel/VIP Mapping 정보를 갖는다. 이 Mapping Table을 바탕으로 LB와 각 Server들은 L3DSR기법을 수행한다.

### 2. GSLB (Global Server Load Balancing)

![]({{site.baseurl}}/images/theory_analysis/SLB/GSLB.PNG){: width="650px"}

GSLB는 SLB와 이름은 유사하지만 VIP기반이 아닌 **DNS**기반의 Load Balancing 기법이다. Service를 제공하는 Server들이 여러 지역에 분리되어 완전히 다른 네트워크에서 운용 될 때 이용하는 기법이다. 따라서 GSLB + SLB 형태로 Load Balancing을 수행 할 수 있다.

일반적인 DNS는 Server나 Network의 상태를 전혀 고려하지 않지만 GSLB는 아래와 같은 순으로 Server를 선택하기 때문에 지능형 DNS라고 이해하면 쉽다.
* Server Health
* SLB Session / Network Capacity Threashold
* Network Proximity
* Geographic Proximity
* SLB Connection Load
* Site Preference
* Least Selected
* Static Load Balancing

### 3. 참조

* SLB - [https://www.slideshare.net/ryuichitakashima3/ss-72343772](https://www.slideshare.net/ryuichitakashima3/ss-72343772)
* SLB - [https://vzealand.com/2016/10/04/vcap6-nv-3v0-643-study-guide-part-8/](https://vzealand.com/2016/10/04/vcap6-nv-3v0-643-study-guide-part-8/)
* GSLB - [https://www.netmanias.com/ko/post/blog/5620/dns-data-center-gslb-network-protocol/global-server-load-balancing-for-enterprise-part-1-concept-workflow](https://www.netmanias.com/ko/post/blog/5620/dns-data-center-gslb-network-protocol/global-server-load-balancing-for-enterprise-part-1-concept-workflow)
