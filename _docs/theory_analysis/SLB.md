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

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB.PNG){: width="500px"}

SLB는 의미 그대로 Server의 부하를 조절하는 기법을 의미한다. 위의 그림은 SLB의 구성을 간략하게 나타낸 그림이다. SLB는 **LB(Load Balancer)**와 **VIP(Virtual IP)**로 구성된다. LB는 Server에 전달되야 하는 Client의 요청을 대신 받아 적절한 Server에게 전달하는 역활을 수행한다. VIP(Virtual IP)는 Load Balancing의 대상이 되는 여러 Server들을 대표하는 하나의 가상 IP이다. Client는 각 Server의 IP가 아닌 LB가 갖고 있는 VIP(Virtual IP)를 대상으로 요청한다. 따라서 Client는 여러 Server들의 존재를 알지 못하고 하나의 Server와 통신한다고 생각한다.

SLB의 핵심은 LB의 역활이다. LB는 어떻게 Load Balancing을 수행할지 결정해야한다. Load Balancing 기법은 다음과 같은 기법들이 존재한다. 
* Round Robin - Round Robin 알고리즘을 바탕으로 Server를 선택한다.
* Least Connection - 현재 Connection의 개수가 가장 적은 Server를 선택한다.
* RTT - RTT(Round Trip Time)이 가장 작은 Server를 선택한다.
* Priority - 우선순위가 높은 Server 선택한다. 만약 우선순위가 높은 서버의 상태가 비정상이라면, 그 다음 우선순위가 높은 서버를 선택한다.

또한 Load Balancing시에 고려할 중요 요소 중 하나는 Session이다. 같은 Session아래 발생한 여러 Connection들이 서로 다른 Server에 전달된다면 Session은 유지되지 못한다. LB가 Session을 파악하기 위해서는 전달받은 Packet들이 동일한 Client로부터 전송됬다는 사실을 파악 할 수 있어야 한다. 일반적으로 Packet의 Source IP Address와 Source Port 번호가 같다면 동일한 Client의 Packet이라고 간주한다. 따라서 LB는 최소 L4 Layer Stack을 인지하고 있어야 한다. 마지막으로 LB는 주기적으로 Server들의 상태를 파악하여 Load Balancing시 비정상 상태의 Server에게 Client의 요청이 전달되지 않도록 해야한다.

#### 1.1. Inline

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_Inline.PNG)

Inline 기법은 SLB 구성시 가장 많이 이용되는 기법이다. Server에 전달되는 Packet과 Server가 전송하는 Packet 모두 LB를 거친다. Packet은 LB에서 총 2번의 NAT 과정을 거친다. 모든 Packet은 LB를 거치기 때문에 Packet Monitoring 및 Filtering에 유리하지만, 그만큼 LB에 큰 부하가 발생한다는 단점이 존재한다.

#### 1.2. DSR

##### 1.2.1. L2DSR

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_L2DSR.PNG)

##### 1.2.2. L3DSR

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_L3DSR_DSCP.PNG)

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_L3DSR_Tunnel.PNG)

### 2. GSLB (Global Server Load Balancing)

![]({{site.baseurl}}/images/theory_analysis/SLB/GSLB.PNG)

### 3. 참조

* SLB - [https://www.slideshare.net/ryuichitakashima3/ss-72343772](https://www.slideshare.net/ryuichitakashima3/ss-72343772)

* GSLB - [https://www.netmanias.com/ko/post/blog/5620/dns-data-center-gslb-network-protocol/global-server-load-balancing-for-enterprise-part-1-concept-workflow](https://www.netmanias.com/ko/post/blog/5620/dns-data-center-gslb-network-protocol/global-server-load-balancing-for-enterprise-part-1-concept-workflow)
