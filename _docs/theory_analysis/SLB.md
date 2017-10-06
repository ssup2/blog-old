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
* Round Robin - Round Robin 알고리즘을 바탕으로 각 Server에게 Client의 요청을 전달하는 방식이다.
* Least Connection - 현재

#### 1.1. Inline

![]({{site.baseurl}}/images/theory_analysis/SLB/SLB_Inline.PNG)



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
