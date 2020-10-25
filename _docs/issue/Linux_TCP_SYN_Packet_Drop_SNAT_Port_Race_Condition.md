---
title: Linux TCP SYN Packet Drop with SNAT Port Race Condition
category: Issue
date: 2020-10-25T12:00:00Z
lastmod: 2020-10-25T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

TCP Connection을 맺기 위해서 TCP SYN Packet을 SNAT하여 전송시, SNAT를 진행하면서 TCP SYN Packet에 설정되는 Src Port 번호를 선택하는 과정에서 발생하는 Race Condition에 의해서 TCP SYN Packet이 Drop 되는 Issue가 존재한다. TCP SYN Packet이 Drop되면 TCP Connection이 최소 1초 이상 지연되어 맺어지게 되어, Client는 Timeout을 경험할 수 있다.

대부분의 Docker Container 내부에서 Docker Host 외부의 Server와 TCP Connection을 맺는 경우, Docker Container가 전송한 TCP SYN Packet은 Docker Host에서 SNAT 되어 외부로 전송되기 때문에 본 Issue로 인해서 TCP SYN Packet이 Drop 될 수 있다. 이와 유사하게 대부분의 Kubernetes Pod의 Container 내부에서 Kubernetes Cluster 외부의 Server와 TCP Connection을 맺는 경우, Kubernetes Pod의 Container가 전송한 TCP SYN Packet은 SNAT 되어 외부로 전송되기 때문에 본 Issue로 인해서 TCP SYN Packet이 Drop 될 수 있다.

### 2. 원인, 해결 방안

Linux에서는 iptables 명령어를 통해서 Packet을 외부로 전송시, Packet의 Src IP를 Packet이 전송되는 Interface의 IP로 변경해주는 SNAT 기법인 Masquerade 기법을 제공한다. 이때 Src Port 번호도 Host에서 이용되고 있지 않는 임의의 Port 번호로 변경된다.

하나의 Process 내부에서 다수의 Thread가 동시에 Masquerade 기법을 통해서 동일한 외부 Server(동일한 IP, Port)로 TCP Connection을 맺으려는 경우에, 다수의 TCP SYN Packet은 Masquerade 기법을 통해서 SNAT 된다. 이때 **각 TCP SYN Packet의 Src Port 번호는 서로 다른 Port 번호로 변경**되어야 한다. 그래야 외부 Server로부터 응답이 왔을경우 어느 TCP Connection에 대한 응답인지 파악할 수 있기 때문이다.

하지만 **Kernel Bug로 인해서 동시에 TCP SYN Packet을 전송할 경우, 각 TCP SYN Packet은 동일한 Src Port 번호로 변경** 될 수 있다. 동일한 Src Port 번호로 SNAT된 TCP SYN Packet들 중에서 가장 먼저 처리되는 TCP SYN Packet을 제외한 나머지 TCP SYN Packet은 Linux conntrack의 중복 Connection 방지 Logic에 의해서 Drop된다.

현재까지 본 이슈 관련 Kernel Bug는 해결하지 못한 상태이다. 따라서 현재는 Masquerade 기법으로 인해서 할당되는 Src Port 번호가 최대한 중복되지 않도록 설정하는 방법밖에 없다. Masquerade 기법으로 인해서 할당되는 Src Port 번호는 NF_NAT_RANGE_PROTO_RANDOM 방법과 NF_NAT_RANGE_PROTO_RANDOM_FULLY 방법 2가지가 존재한다.

### 3. with Kubernetes

### 4. 참조

* [https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02](https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02)
* [https://github.com/kubernetes/kubernetes/pull/78547](https://github.com/kubernetes/kubernetes/pull/78547)
