---
title: Kubernetes with OpenStack Octavia
category: Theory, Analysis
date: 2019-08-04T12:00:00Z
lastmod: 2019-08-04T12:00:00Z
comment: true
adsense: true
---

OpenStack의 LBaaS (Load Balancer as a Service)인 Octavia와 같이 동작하는 Kubernetes의 LoadBalancer Service를 분석한다.

### 1. Kubernetes with OpenStack Octavia

![[그림 1] Kubernetes with OpenStack Octavia 구성요소]({{site.baseurl}}/images/theory_analysis/Kubernetes_OpenStack_Octavia/Components.PNG)

[그림 1]은 OpenStack Octavia와 동작하는 Kubernetes를 나타내고 있다. [그림 1]에는 1개의 OpenStack Controller Node, 1개의 OpenStack Controller Node, 2개의 OpenStack Compute Node로 구성된 OpenStack이 위치한다. OpenStack 위에는 1개의 Kubernetes Master VM, 3개의 Kubernetes Slave VM으로 구성된 하나의 Kubernetes Cluster가 위치한다. Kubernetes Cluster에는 Service A,B 2개의 LoadBalancer Service가 설정되어 있다. 따라서 각 Service를 위한 Active-Standby 형태의 LB VM (Amphora VM)이 2 Set가 존재하게 된다.

[그림 1]에서는 3개의 Network를 포함하고 있다. External Network는 VM들이 외부와 통신을 위해 이용하는 Network이다. Octavia Network는 모든 Octavia의 LB VM이 연결되는 Network이다. Kubernetes Networks는 Kubernetes VM들이 Kubernetes Cluster를 구성하는데 이용하는 Network이다.

#### 1.1. Octavia

Octavia는 OpenStack의 LBaaS이다. Kubernetes는 Octavia를 통해서 LoadBalancer Service를 OpenStack 외부에 제공할 수 있다. Octavia는 OpenStack Controller에서 동작하는 Octavia Service와 Packet을 Load Balancing하는 LB VM으로 구성되어 있다. LB VM은 실제 Packet을 Load Balancing하는 HAProxy와 Octavia Service와 통신을 담당하는 Agent (Amphora Agent)로 구성되어 있다. Octavia Network는 Octavia Service와 Agent가 통신에 이용되는 Network 이다.

Agent는 Octavia Network를 통해서 LB VM의 Health 정보를 Octavia Service에게 전송하고, Octavia Service로부터 HAProxy 설정 정보를 받아 HAProxy를 설정하는 역활을 수행한다. 또한 [그림 1]에는 표현되지 않았지만 Agent는 LB을 통해서 Packet을 전달받을 Octavia Member VM의 Health 정보도 Octavia Service에게 전송한다. [그림 1]에서 Agent는 K8s Slave VM의 Health 정보도 Octavia Service에게 전송한다.

Active 상태의 LB VM에 장애가 발생한다면 HAProxy는 VRRP Protocol을 이용하여 Standby 상태의 HAProxy를 Active 상태로 변경하고 Load Balancing 동작을 지속한다. Octavia Service는 Agent의 Health 정보를 통해서 LB VM의 장애를 파악한뒤, 장애가 발생한 LB VM의 상태를 Error 상태로 변경하고, Standby 상태의 LB VM을 Active 상태로 변경한다. Octavia Member VM에 장애가 발생한다면 Octavia Service는 Agent의 Health 정보를 통해서 Octavia Member VM의 장애를 파악한뒤, 장애가 발생한 Octavia Member VM을 Member Pool에서 제외시킨다.

[그림 1]에서는 Octavia Service와 Agent가 Octavia Network와 External Network를 통하도록 구성되어 있지만, 반드시 External Network를 이용할 필요는 없다. Octavia Service와 Agent가 Octavia Network를 통해서 통신을 할 수 있는 환경만 구성되면 된다. [그림 1]에서 모든 LB VM은 Active-Standby 형태로 동작하도록 표현되어 있지만 설정에 따라서 Standalone으로 동작하도록 설정할 수 있다.

#### 1.2. Kubernetes

#### 1.3. LoadBalancer Service Packet Flow

### 2. 참조

* [https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/](https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/)
* [https://github.com/kubernetes/cloud-provider](https://github.com/kubernetes/cloud-provider)
