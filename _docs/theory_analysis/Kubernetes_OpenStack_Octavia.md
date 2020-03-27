---
title: Kubernetes with OpenStack Octavia
category: Theory, Analysis
date: 2019-08-04T12:00:00Z
lastmod: 2019-08-04T12:00:00Z
comment: true
adsense: true
---

OpenStack의 LBaaS (Load Balancer as a Service)인 Octavia와 같이 동작하는 Kubernetes의 Load Balancer Service를 분석한다.

### 1. Kubernetes with OpenStack Octavia

![[그림 1] Kubernetes with OpenStack Octavia]({{site.baseurl}}/images/theory_analysis/Kubernetes_OpenStack_Octavia/Kubernetes_OpenStack_Octavia.PNG)

[그림 1]은 OpenStack Octavia와 동작하는 Kubernetes를 나타내고 있다. [그림 1]에는 1개의 OpenStack Controller Node, 1개의 OpenStack Controller Node, 2개의 OpenStack Compute Node로 구성된 OpenStack이 위치한다. OpenStack 위에는 1개의 Kubernetes Master VM, 3개의 Kubernetes Slave VM으로 구성된 하나의 Kubernetes Cluster가 위치한다. Kubernetes Cluster에는 Service A,B 2개의 Load Balancer Service가 설정되어 있다. 따라서 각 Service를 위한 Active-Standby 형태의 LB VM (Amphora VM)이 2 Set가 존재하게 된다.

[그림 1]에서는 3개의 Network를 포함하고 있다. External Network는 VM들이 외부와 통신을 위해 이용하는 Network이다. Octavia Network는 모든 Octavia의 LB VM이 연결되는 Network이다. Kubernetes Networks는 Kubernetes VM들이 Kubernetes Cluster를 구성하는데 이용하는 Network이다.

#### 1.1. Octavia 동작

Octavia는 OpenStack의 LBaaS이다. Kubernetes는 Octavia를 통해서 Load Balancer Service를 OpenStack 외부에 제공할 수 있다. Octavia는 OpenStack Controller에서 동작하는 Octavia Service와 Packet을 Load Balancing하는 LB VM으로 구성되어 있다. LB VM은 실제 Packet을 Load Balancing하는 HAProxy와 Octavia Service와 통신을 담당하는 Agent (Amphora Agent)로 구성되어 있다. Octavia Network는 Octavia Service와 Agent가 통신에 이용되는 Network 이다.

Agent는 Octavia Network를 통해서 HAProxy (LB VM)의 Health 정보를 Octavia Service에게 전송하고, Octavia Service로부터 HAProxy 설정 정보를 받아 HAProxy를 설정하는 역할을 수행한다. 또한 Agent는 Load Balancing을 통해서 Packet이 전달되는 VM인 Octavia Member VM의 Health 정보를 Octavia Service에게 전송하는 역활도 수행한다. Agent는 Octavia Member VM의 Health 정보를 HAProxy가 제공하는 stats Domain Socket을 통해서 얻는다. HAProxy는 Agent가 설정한 IP:Port들을 Health Check하고, Health가 정상이라면 해당 IP:Port로 Packet을 전송한다. Kubernetes 환경이라면 Agent는 Kubernetes Cluster의 Slave IP들과 Kubernetes Service의 NodePort를 Port를 이용하여 HAProxy를 설정한다.

Active 상태의 HAProxy (LB VM)에 장애가 발생한다면 VRRP Protocol을 통해서 Standby 상태의 HAProxy는 Active 상태로 변경되고 Load Balancing 동작을 지속한다. 이러한 HAProxy의 Active/Standby 동작은 Octvia Service의 간섭없이 진행된다. Octvia Service는 Agent로부터 전송되는 HAProxy의 상태 정보를 바탕으로 자신이 관리하는 HAProxy의 상태 정보만 갱신한다. Octavia Member VM에 장애가 발생한다면 HAProxy의 Health Check에 의해서 장애가 발생한 Octavia Member VM은 Load Balancing의 대상에서 제외된다. 이러한 동작 또한 Octvia Service의 간섭없이 진행된다. Octavia Service는 Agent가 HAProxy로 얻은 Octavia Member VM의 상태 정보를 바탕으로 자신이 관리하는 Member Pool에서 Octavia Member VM을 추가/삭제하는 동작만 수행한다.

[그림 1]에서는 Octavia Service와 Agent가 Octavia Network와 External Network를 동시에 이용하도록 구성되어 있지만, 반드시 External Network를 같이 이용할 필요는 없다. Octavia Service와 Agent가 LB VM에 연결되어 있는 Octavia Network를 통해서 통신을 할 수 있는 환경만 구성되면 된다. [그림 1]에서 모든 LB VM은 Active-Standby 형태로 동작하도록 표현되어 있지만 Octavia의 설정을 통해서 Standalone으로 동작하도록 설정할 수 있다.

#### 1.2. Kubernetes 동작

Kubernetes가 Octavia와 같이 연동되어 동작할 경우, Kubernetes Controller Manager가 Octavia Service에게 Load Balancer를 직접 요청하여 필요한 Load Balancer를 할당 받는 구조이다. 따라서 Octavia Service는 Kubernetes의 존재를 알지 못하고 Kubernetes Controller Manager의 요청대로 Load Balancer를 할당하고 설정하는 역할만 수행한다.

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

Kubernetes Controller Manager가 Octavia Service에게 Load Balancer를 요청하기 위해서는 Octavia Service의 URL, Octavia Service를 위한 User ID/PW, Kubernetes VM이 소속된 OpenStack의 Tanant ID, Kubernetes Network의 Subnet ID, Load Balancer Option 등의 다양한 정보가 필요한데, 이러한 필요한 정보들은 모두 Kubernetes Master VM의 cloud_config 파일에 저장되어 있다. [파일 1]은 실제 cloud_config 파일을 나타내고 있다.

[파일 1]의 Global 영역에는 Kubernetes VM의 User ID/PW, Tenant, Region 정보등이 저장되어 있다. Load Balancer 영역에는 Load Balancer 관련 설정 정보가 저장되어 있다. subnet-id는 Kubernetes Network의 Subnet ID를 의미한다. floating-network-id는 External Network ID를 의미한다. lb-method는 Load Balancing 알고리즘을 의미한다. monitor 관련 설정은 Octavia Member VM Monitoring 정책을 결정한다.

Kubernetes Controller Manager는 [파일 1]의 Global 영역에 있는 auth-url를 통해서 인증/인가를 수행하고, Octavia Service의 URL을 알아내어 Octavia Service에게 Load Balancer 요청을 전송한다. 따라서 Kubernetes Controller Manager가 있는 Kubernetes Master VM은 auth-url을 통해서 Octavia Service에 접근할 수 있도록 Network가 설정되어야 한다. [그림 1]에서 Kubernetes Master VM은 Kubernetes Network와 External Network를 통해서 Octavia Service에 접근할 수 있도록 설정된 상태를 나타고 있다. 하지만 반드시 Kubernetes Network와 External Network를 이용할 필요는 없다. Kubernetes Master VM에서 auth-url을 통해서 Octavia Service에 접근할 수 있는 Network 환경만 있으면 된다.

Kubernetes는 Load Balancer Service 생성시 NodePort를 반드시 생성하고, Kubernetes Cluster를 구성하는 모든 VM (Master, Slave)에 NodePort를 Dest Port로 갖고 있는 Packet을 수신시 Load Balancer Service로 Packet을 전달하도록 iptables/IPVS를 설정한다. NodePort 생성 및 iptables/IPVS 설정이 끝난뒤 Kubernetes Controller Manager는 Octvia Service에게 생성한 NodePort와 cloud_config 파일을 바탕으로 Load Balancer 생성을 요청한다. 이때 Kubernetes Controller Manager는 Octvia Member VM으로 Master Role이 할당된 Master VM은 제외하고 Slave VM만 포함시킨다. Load Balancer 생성이 완료되면 Kubernetes Controller Manager는 생성된 Load Balancer의 External Network IP를 받아 저장한다.

#### 1.3. Load Balancer Service의 Packet Flow

Dest IP가 Load Balancer Service의 IP인 Packet이 External Network에 전달되면, OpenStack Network Node에 있는 Virtual Router는 해당 Packet을 DNAT하여 Kubernetes Network로 Routing한다. Packet은 Active 상태의 LB VM에게 전달되고, HAProxy에 의해서 Packet은 SlaveIP:NodePort로 DNAT되어 Octavia Member인 임의의 Kubernetes Slave VM에게 전달된다. Kubernetes Slave VM은 iptables/IPVS Rule에 따라서 다시한번 DNAT 및 Load Balancing되어 Load Balancer Service에 소속된 Pod에 Packet을 전달한다.

Packet이 외부로부터 Pod까지 전달되는 과정을 보면 LB VM안의 Haproxy에 의해서 한번 Load Balancing이 되고 Slave VM의 iptables/IPVS Rule에 의해서 다시 한번더 Load Balancing이 된다. Slave VM의 iptables/IPVS Rule에 의한 Load Balancing을 제거하고 HAProxy에 의한 Load Balancing만 수행하기 위해서는 Kubernetes에서 LoadBalancer Service 생성시 'externalTrafficPolicy Local' Option을 설정하면 된다. 

'externalTrafficPolicy Local' Option을 설정하면 Slave VM에서는 iptables/IPVS Rule에 의한 Load Balancing 수행하지 않는다. 또한 Packet의 목적지 Pod이 동작하고 있는 Slave VM의 NodePort만 정상 동작한다. 따라서 HAProxy가 Health Check 수행시 Packet의 목적지 Pod이 동작하는 Slave VM만 Health Check에 성공하고, Packet의 목적지 Pod이 동작하지 않는 Slave VM의 경우 Health Check에 실패한다. HAProxy는 Healt Check에 성공한 Packet의 목적지 Pod이 위치하는 Slave VM을 대상으로만 Load Balancing을 수행하여 Pod에게 Packet을 전달한다. 'externalTrafficPolicy Local' Option은 Packet의 Src IP:Port를 유지시키는 역활도 수행한다.

### 2. Kubernetes with OpenStack Octavia and OpenStack CCM

![[그림 2] Kubernetes with OpenStack Octavia and OpenStack CCM]({{site.baseurl}}/images/theory_analysis/Kubernetes_OpenStack_Octavia/Kubernetes_OpenStack_Octavia_CCM.PNG)

현재 Kubernetes는 기존의 Cloud Provider에 종속적인 부분들을 별도의 Controller로 분리하는 작업을 진행중이다. Openstack에 종속적인 부분들은 Openstack CCM(Cloud Controller Manager)를 이용하도록 Kubernetes를 설정할 수 있다. [그림 2]는 OpenStack CCM을 이용할 경우 Octavia와 동작하는 Kubernetes를 나타내고 있다. Kubernetes Controller Manager 대신 OpenStack CCM이 Octavia Service에게 Load Balancer를 요청한다는 부분을 제외하고는 [그림 1]과 동일하다.

### 3. 참조

* [https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/](https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/)
* [https://github.com/kubernetes/cloud-provider](https://github.com/kubernetes/cloud-provider)
