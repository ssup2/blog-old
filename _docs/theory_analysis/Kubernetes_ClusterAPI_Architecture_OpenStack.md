---
title: Kubernetes ClusterAPI Architecture on OpenStack
category: Theory, Analysis
date: 2020-11-26T12:00:00Z
lastmod: 2020-11-26T12:00:00Z
comment: true
adsense: true
---

OpenStack 환경에서 동작하는 Kubernetes Cluster API의 Architecture를 분석한다.

### 1. Kubernetes ClusterAPI Architecture on OpenStack

![[그림 1] Kubernetes ClusterAPI Architecture on OpenStack]({{site.baseurl}}/images/theory_analysis/Kubernetes_ClusterAPI_Architecture_OpenStack/Kubernetes_ClusterAPI_Architecture_OpenStack.PNG)

[그림 1]은 OpenStack 환경에서 Kubernetes ClusterAPI의 Architecture를 나타내고 있다. ClusterAPI User는 ClusterAPI Kubernetes Cluster에 Cluster 관련 Object(CRD)를 생성하여 Cluster를 생성한다. ClusterAPI Kubernetes Cluster에는 다양한 ClusterAPI Cluster가 존재한다. 크게 ClusterAPI Interface 역활을 수행하는 ClusterAPI Controller와 이 Interface를 통해서 실제로 OpenStack에 User Kubernetes Cluster를 생성하고 관리하는 ClusterAPI OpenStack Provider Controller로 분류할 수 있다.

Cluster 관련 Object는 Kubernetes의 CRD (Custom Resource Definition)을 통해서 정의되며, ClusterAPI Controller 및 ClusterAPI OpenStack Provider Controller에 의해서 관리된다. 다양한 종류의 Cluster 관련 Object가 존재하지만 크게 User Kubernetes Cluster의 Master Node에 해당하는 Control Plan 정보, User Kubernetes Cluster의 Worker Node에 해당하는 Machine 정보, User Kubernetes Cluster의 Root CA(certificate authority) Certificate/Key Object가 존재한다.

[그림 1]에는 ClusterAPI를 통해서 생성한 2개의 ClusterAPI User Kubernetes Cluster를 나타내고 있다. 각 User Kuberentes Cluster는 Master Node (Control Plain), Worker Node, Load Balancer, Bastion Node 4가지의 구성요소로 이루어져 있다. Master Node는 Kuberentes Cluster에서 Kubernetes API Server, Kubernetes Controller Manager를 동작시키는 Master 역활을 수행하는 Node를 의미하고, Worker Node는 Kubernetes Cluster에서 App Container가 동작하는 Node를 의미한다.

Load Balancer는 다수의 Master Node들을 묶어서 하나의 Master Node VIP(Endpoint)를 제공하는 역활을 수행한다. 여기서 Load Balancer가 생성하는 Master Node의 VIP는 **External Network의 VIP**이다. 따라서 External Network에 존재하는 Cluster User의 kubectl Client는 Load Balancer를 통해서 생성된 Master Node VIP를 통해서 Kubernetes API Server와 통신한다. User Cluster의 Worker Node들도 Load Balaner가 생성하는 External Network의 Master Node VIP를 이용하여 Master Node와 통신한다. 따라서 각 Cluster Network에서 안에서도 External Network의 Master Node VIP로 접근할 수 있도록 Network 설정이 되어있어야 한다.

ClusterAPI는 User Cluster의 각 Node들에게 Kubernetes Cluster 구성에 필요한 최소한의 Port만 열려있도록 Security Group을 설정한다. 따라서 기본적으로는 SSH를 통해서 User Cluster의 각 Node에게 접근할 수 없다. Bastion Node는 Cluster User가 User Cluster의 Node들에게 SSH로 접근하도록 도와주는 통로 역활을 수행한다. Cluster User는 Bastion Node로 SSH로 접근한 다음, Bastion Node에서 다시 SSH를 통해서 User Cluster의 Node로 접근할 수 있다.

### 2. 참조

* [https://cluster-api.sigs.k8s.io/](https://cluster-api.sigs.k8s.io/)
* [https://github.com/kubernetes-sigs/cluster-api-provider-openstack](https://github.com/kubernetes-sigs/cluster-api-provider-openstack)