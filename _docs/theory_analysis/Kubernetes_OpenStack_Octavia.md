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

#### 1.1. Octavia 동작

Octavia는 OpenStack의 LBaaS이다. Kubernetes는 Octavia를 통해서 LoadBalancer Service를 OpenStack 외부에 제공할 수 있다. Octavia는 OpenStack Controller에서 동작하는 Octavia Service와 Packet을 Load Balancing하는 LB VM으로 구성되어 있다. LB VM은 실제 Packet을 Load Balancing하는 HAProxy와 Octavia Service와 통신을 담당하는 Agent (Amphora Agent)로 구성되어 있다. Octavia Network는 Octavia Service와 Agent가 통신에 이용되는 Network 이다.

Agent는 Octavia Network를 통해서 LB VM의 Health 정보를 Octavia Service에게 전송하고, Octavia Service로부터 HAProxy 설정 정보를 받아 HAProxy를 설정하는 역활을 수행한다. 또한 [그림 1]에는 표현되지 않았지만 Agent는 Load Balancing을 통해서 Packet을 전달받을 Octavia Member VM의 Health 정보도 Octavia Service에게 전송한다. [그림 1]에서 Agent는 K8s Slave VM의 Health 정보도 Octavia Service에게 전송한다.

Active 상태의 LB VM에 장애가 발생한다면 HAProxy는 VRRP Protocol을 이용하여 Standby 상태의 HAProxy를 Active 상태로 변경하고 Load Balancing 동작을 지속한다. Octavia Service는 Agent의 Health 정보를 통해서 LB VM의 장애를 파악한뒤, 장애가 발생한 LB VM의 상태를 Error 상태로 변경하고, Standby 상태의 LB VM을 Active 상태로 변경한다. Octavia Member VM에 장애가 발생한다면 Octavia Service는 Agent의 Health 정보를 통해서 Octavia Member VM의 장애를 파악한뒤, 장애가 발생한 Octavia Member VM을 Member Pool에서 제외시킨다.

[그림 1]에서는 Octavia Service와 Agent가 Octavia Network와 External Network를 동시에 이용하도록 구성되어 있지만, 반드시 External Network를 같이 이용할 필요는 없다. Octavia Service와 Agent가 LB VM에 연결되어 있는 Octavia Network를 통해서 통신을 할 수 있는 환경만 구성되면 된다. [그림 1]에서 모든 LB VM은 Active-Standby 형태로 동작하도록 표현되어 있지만 Octavia의 설정을 통해서 Standalone으로 동작하도록 설정할 수 있다.

#### 1.2. Kubernetes 동작

Kubernetes가 Octavia와 같이 연동되어 동작할 경우, Kubernetes API Server가 Octavia Service에게 Load Balancer를 직접 요청하여 필요한 Load Balancer를 할당 받는 구조이다. 따라서 Octavia Service는 Kubernetes의 존재를 알지 못하고 Kubernetes API Server의 요청대로 Load Balancer를 할당하고 설정하는 역활만 수행한다.

{% highlight text %}
[Global]
auth-url="http://192.168.0.40:5000/v3"
username="admin"
password="admin"
region="RegionOne"
tenant-id="b21b68637237488bbb5f33ac8d86b848"
domain-name="Default"

[LoadBalancer]
subnet-id=67ca5cfd-0c3f-434d-a16c-c709d1ab37fb
floating-network-id=00a8e738-c81e-45f6-9788-3e58186076b6
use-octavia=True
lb-method=ROUND_ROBIN

create-monitor=yes
monitor-delay=1m
monitor-timeout=30s
monitor-max-retries=3
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] cloud_config</figcaption>
</figure>

Kubernetes API Server가 Octavia Service에게 Load Balancer를 요청하기 위해서는 Octavia Service의 URL, Octavia Service를 위한 User ID/PW, Kubernetes VM이 소속된 OpenStack의 Tanant ID, Kubernetes Network의 Subnet ID, Load Balancer Option 등의 다양한 정보가 필요한데, 이러한 필요한 정보들은 모두 Kubernetes Master VM의 cloud_config 파일에 저장되어 있다. [파일 1]은 실제 cloud_config 파일을 나타내고 있다.

[파일 1]의 Global 영역에는 Kubernetes VM의 User ID/PW, Tenant, Region 정보등이 저장되어 있다. LoadBalancer 영역에는 Load Balacner 관련 설정 정보가 저장되어 있다. subnet-id는 Kubernetes Network의 Subnet ID를 의미한다. floating-network-id는 External Network ID를 의미한다. lb-method는 Load Balancing 알고리즘을 의미한다. monitor 관련 설정은 Octavia Member VM을 어떻게 Monitoring 할지를 설정한다.

Kubernetes API Server는 [파일 1]의 Global 영역에 있는 auth-url를 통해서 인증/인가를 수행하고, Octavia Service의 URL을 알아내어 Octavia Service에게 Load Balancer 요청을 전송한다. 따라서 Kubernetes API Server가 있는 Kubernetes Master VM은 auth-url을 통해서 Octavia Service에 접근할 수 있도록 Network가 설정되어야 한다. [그림 1]에서 Kubernetes Master VM은 Kubernetes Network와 External Network를 통해서 Octavia Service에 접근할 수 있도록 설정된 상태를 나타고 있다. 하지만 반드시 Kubernetes Network와 External Network를 이용할 필요는 없다. Kubernetes Master VM에서 auth-url을 통해서 Octavia Service에 접근할 수 있는 Network 환경만 있으면 된다.

#### 1.3. LoadBalancer Service의 Packet Flow

### 2. 참조

* [https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/](https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/)
* [https://github.com/kubernetes/cloud-provider](https://github.com/kubernetes/cloud-provider)
