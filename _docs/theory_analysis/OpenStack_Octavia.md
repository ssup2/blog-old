---
title: OpenStack Octavia
category: Theory, Analysis
date: 2020-03-28T12:00:00Z
lastmod: 2020-03-28T12:00:00Z
comment: true
adsense: true
---

OpenStack의 Octavia를 분석한다.

### 1. OpenStack Octavia

![[그림 1] OpenStack Octavia Concept]({{site.baseurl}}/images/theory_analysis/OpenStack_Octavia/Octavia_Concept.PNG){: width="700px"}

Octavia는 LBaaS (Load Balancer as a Service)를 제공하는 OpenStack의 Service이다. [그림 1]은 Octavia의 Concept을 나타내고 있다. Load Balancer는 하나의 VIP (Virtual IP)를 의미한다. Listener는 하나의 Port를 의미한다. [그림 1]에서는 Port A, Port B를 담당하는 Listener가 하나씩 존재하는걸 확인할 수 있다. Pool은 Packet의 목적지가 되는 Server를 의미하는 Member들의 집합을 의미하며, 각 Listener들은 특정 Pool과 Mapping된다. [그림 1]에서는 Listener과 Pool은 1:1로 Mapping되어 있지만, 여러개의 Listener가 하나의 Pool을 공유할 수도 있다. Health Monitor는 Pool의 Member의 Health Check를 담당하며, Health Check에 실패한 Member로 Packet이 Load Balancing이 되지 않도록 하는 역활을 수행한다.

{% highlight console %}
# openstack loadbalancer show b13ce3b9-381f-4d33-9443-b7fc30619350
+---------------------+-------------------------------------------------------------------+
| Field               | Value                                                             |
+---------------------+-------------------------------------------------------------------+
| admin_state_up      | True                                                              |
| created_at          | 2020-03-27T13:36:28                                               |
| description         | Kubernetes external service default/a-svc from cluster kubernetes |
| flavor_id           | None                                                              |
| id                  | b13ce3b9-381f-4d33-9443-b7fc30619350                              |
| listeners           | e69d05f9-87cf-4952-b090-6ff9a78f6420                              |
| name                | kube_service_kubernetes_default_a-svc                             |
| operating_status    | DEGRADED                                                          |
| pools               | d335f906-01c3-4d25-ae6b-77a21e72fe2f                              |
| project_id          | b21b68637237488bbb5f33ac8d86b848                                  |
| provider            | amphora                                                           |
| provisioning_status | ACTIVE                                                            |
| updated_at          | 2020-03-29T12:06:32                                               |
| vip_address         | 30.0.0.117                                                        |
| vip_network_id      | e1427325-87d0-4478-a6a3-301b8fdf15a3                              |
| vip_port_id         | 3cb932d3-7ae8-4e27-a8ea-66583eee2f37                              |
| vip_qos_policy_id   | None                                                              |
| vip_subnet_id       | 67ca5cfd-0c3f-434d-a16c-c709d1ab37fb                              |
+---------------------+-------------------------------------------------------------------+

# openstack loadbalancer listener show e69d05f9-87cf-4952-b090-6ff9a78f6420
+-----------------------------+--------------------------------------------------+
| Field                       | Value                                            |
+-----------------------------+--------------------------------------------------+
| admin_state_up              | True                                             |
| connection_limit            | -1                                               |
| created_at                  | 2020-03-27T13:39:34                              |
| default_pool_id             | d335f906-01c3-4d25-ae6b-77a21e72fe2f             |
| default_tls_container_ref   | None                                             |
| description                 |                                                  |
| id                          | e69d05f9-87cf-4952-b090-6ff9a78f6420             |
| insert_headers              | None                                             |
| l7policies                  |                                                  |
| loadbalancers               | b13ce3b9-381f-4d33-9443-b7fc30619350             |
| name                        | listener_0_kube_service_kubernetes_default_a-svc |
| operating_status            | ONLINE                                           |
| project_id                  | b21b68637237488bbb5f33ac8d86b848                 |
| protocol                    | TCP                                              |
| protocol_port               | 80                                               |
| provisioning_status         | ACTIVE                                           |
| sni_container_refs          | []                                               |
| timeout_client_data         | 50000                                            |
| timeout_member_connect      | 5000                                             |
| timeout_member_data         | 50000                                            |
| timeout_tcp_inspect         | 0                                                |
| updated_at                  | 2020-03-27T13:39:54                              |
| client_ca_tls_container_ref | None                                             |
| client_authentication       | NONE                                             |
| client_crl_container_ref    | None                                             |
+-----------------------------+--------------------------------------------------+

# openstack loadbalancer pool show d335f906-01c3-4d25-ae6b-77a21e72fe2f
+----------------------+----------------------------------------------+
| Field                | Value                                        |
+----------------------+----------------------------------------------+
| admin_state_up       | True                                         |
| created_at           | 2020-03-27T13:39:40                          |
| description          |                                              |
| healthmonitor_id     | 9eea2d84-6e65-471b-ac86-bbf5f7e849ed         |
| id                   | d335f906-01c3-4d25-ae6b-77a21e72fe2f         |
| lb_algorithm         | ROUND_ROBIN                                  |
| listeners            | e69d05f9-87cf-4952-b090-6ff9a78f6420         |
| loadbalancers        | b13ce3b9-381f-4d33-9443-b7fc30619350         |
| members              | 9e5d179f-8b89-4ede-af5b-70560e6775d3         |
|                      | 642665e0-9552-4afd-bcde-9dcd769ad225         |
| name                 | pool_0_kube_service_kubernetes_default_a-svc |
| operating_status     | DEGRADED                                     |
| project_id           | b21b68637237488bbb5f33ac8d86b848             |
| protocol             | TCP                                          |
| provisioning_status  | ACTIVE                                       |
| session_persistence  | None                                         |
| updated_at           | 2020-03-29T12:11:43                          |
| tls_container_ref    | None                                         |
| ca_tls_container_ref | None                                         |
| crl_container_ref    | None                                         |
| tls_enabled          | False                                        |
+----------------------+----------------------------------------------+

# openstack loadbalancer healthmonitor show 9eea2d84-6e65-471b-ac86-bbf5f7e849ed
+---------------------+--------------------------------------------------+
| Field               | Value                                            |
+---------------------+--------------------------------------------------+
| project_id          | b21b68637237488bbb5f33ac8d86b848                 |
| name                | monitor_0_kube_service_kubernetes_default_a-svc) |
| admin_state_up      | True                                             |
| pools               | d335f906-01c3-4d25-ae6b-77a21e72fe2f             |
| created_at          | 2020-03-27T13:39:51                              |
| provisioning_status | ACTIVE                                           |
| updated_at          | 2020-03-27T13:39:54                              |
| delay               | 60                                               |
| expected_codes      | None                                             |
| max_retries         | 3                                                |
| http_method         | None                                             |
| timeout             | 30                                               |
| max_retries_down    | 3                                                |
| url_path            | None                                             |
| type                | TCP                                              |
| id                  | 9eea2d84-6e65-471b-ac86-bbf5f7e849ed             |
| operating_status    | ONLINE                                           |
| http_version        | None                                             |
| domain_name         | None                                             |
+---------------------+--------------------------------------------------+
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] OpenStack Octavia Resource</figcaption>
</figure>

이러한 Octavia의 Concept Component는 Octavia의 Resource로 관리된다. [Shell 1]은 openstack CLI를 이용여 Octavia의 Resource를 조회하는 Shell을 나타내고 있다. 이러한 Octavia Concept은 Neutron LBaaS V2와 동일하며, Octavia는 Neutron LBaaS V2 API를 그대로 지원한다는 특징도 갖고 있다.

#### 1.1. Architecture

![[그림 2] OpenStack Octavia Architecture]({{site.baseurl}}/images/theory_analysis/OpenStack_Octavia/Octavia_Architecture.PNG)

[그림 2]는 Octavia의 Architecture를 나타내고 있다. Controller Node에는 Octavia Service가 동작하고 있고, Octavia의 Load Balancer Instance인 Amphora는 Compute Node에서 동작한다. Amphora는 VM, PM, Container로 구성 가능하다. Octavia Service와 Amphora 사이의 통신은 일반적으로 Provider가 생성하는 Octvia 전용 Network를 통해서 이루어진다.

Octavia Client는 Octavia Service의 API Controller에게 LB 생성을 요청하면 API Controller는 Nova, Neutron 같은 다른 OpenStack Service의 도움을 받아 Amphora를 생성한다. Amphora 생성이 완료되면 Octavia Service의 Controller Worker는 Amphora의 Agent를 통해서 HAProxy의 Config 파일을 생성하고 HAProxy를 구동한다. Member의 Health Check는 Agent의 설정에 따라서 HAProxy가 수행한다. HAProxy가 수집한 Member의 Health 상태는 Unix Socket을 통해서 Agent에 전달되며, Agent는 다시 Controller Worker에게 전달한다.

Controller Worker는 전달 받은 Member의 Health 상태를 Octavia의 Member Resource에 반영한다. Housekeeping Manager는 삭제된 Resource를 Octavia DB에서 완전히 지우는 역활 및 Amphora의 Certificate를 관리하는 역활을 수행한다. Amphora는 Standalone 또는 HA를 위한 Active-Standby로 동작한다. [그림 1]에서는 Active-Standby 형태로 동작하는 Amphora를 나타내고 있다.

{% highlight text %}
[DEFAULT]
debug = False

[haproxy_amphora]
base_cert_dir = /var/lib/octavia/certs
base_path = /var/lib/octavia
bind_host = ::
bind_port = 9443
haproxy_cmd = /usr/sbin/haproxy
respawn_count = 2
respawn_interval = 2
use_upstart = True

[health_manager]
controller_ip_port_list = 192.168.0.31:5555
heartbeat_interval = 10
heartbeat_key = insecure

[amphora_agent]
agent_server_ca = /etc/octavia/certs/client_ca.pem
agent_server_cert = /etc/octavia/certs/server.pem
agent_request_read_timeout = 180
amphora_id = c7e877d5-f1c6-4fb2-a9fb-214cb7cc793a
amphora_udp_driver = keepalived_lvs

[controller_worker]
loadbalancer_topology = ACTIVE_STANDBY
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] amphora-agent.conf</figcaption>
</figure>

[파일 1]은 Agent의 Config 파일을 나타내고 있다. HAProxy 설정, Health Manager 설정, Amphora 동작 모드 설정들을 찾아볼수 있다. 

{% highlight console %}
# ip netns list
amphora-haproxy

# ip netns exec amphora-haproxy ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:f0:b8:43 brd ff:ff:ff:ff:ff:ff
    inet 30.0.0.123/24 brd 30.0.0.255 scope global eth1
       valid_lft forever preferred_lft forever
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] HAProxy Network Namespace in Amphora</figcaption>
</figure>

HAProxy는 Amphora의 Network Namespace가 아닌 HAProxy 전용 Network Namespace를 이용한다. [Shell 2]는 HAProxy Network Namespace에서 VIP를 갖고 있는 Interface를 나타내고 있다.

### 2. 참조

* [https://www.slideshare.net/openstack_kr/openinfra-days-korea-2018-track-2-neutron-lbaas-octavia](https://www.slideshare.net/openstack_kr/openinfra-days-korea-2018-track-2-neutron-lbaas-octavia)
* [https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html](https://docs.openstack.org/mitaka/networking-guide/config-lbaas.html)
* [https://docs.openstack.org/octavia/queens/reference/introduction.html](https://docs.openstack.org/octavia/queens/reference/introduction.html)
* [https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/13/html/networking_guide/sec-octavia](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/13/html/networking_guide/sec-octavia)

