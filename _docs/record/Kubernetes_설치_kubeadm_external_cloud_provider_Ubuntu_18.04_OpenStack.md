---
title: Kubernetes 설치 / kubeadm, External Cloud Provider 이용 / Ubuntu 18.04, OpenStack 환경
category: Record
date: 2019-08-14T12:00:00Z
lastmod: 2019-08-14T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] Kubernetes 설치 환경]({{site.baseurl}}/images/record/Kubernetes_kubeadm_external_cloud_provider_Ubuntu_18.04_OpenStack/Environment.PNG)

[그림 1]은 Kubernetes 설치 환경을 나타내고 있다. 설치 환경은 다음과 같다.
* VM : Ubuntu 18.04, 4 vCPU, 4GB Memory
  * ETCD Node * 1
  * Master Node * 1
  * Slave Node * 3
  * Deploy Node * 1
* Network
  * NAT Network : 192.168.0.0/24
  * Octavia Network : 20.0.0.0/24
  * Tenant Network : 30.0.0.0/24
* OpenStack : Stein
  * API Server : 192.168.0.40:5000
  * Octavia
* Kubernetes
  * CNI : Cilium Plugin

### 2. 참조

* [https://kubernetes.io/docs/setup/independent/install-kubeadm/](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* [https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)
* [https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-controller-manager-with-kubeadm.md](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-controller-manager-with-kubeadm.md)
* [https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/](https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/)