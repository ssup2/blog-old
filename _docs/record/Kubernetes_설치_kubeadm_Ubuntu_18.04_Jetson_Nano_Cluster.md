---
title: Kubernetes 설치 / kubeadm 이용 / Ubuntu 18.04, Jetson Nano Cluster 환경
category: Record
date: 2020-04-19T12:00:00Z
lastmod: 2020-04-19T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

![[그림 1] Kubernetes 설치 환경 (Jetson Nano Cluster)]({{site.baseurl}}/images/record/Kubernetes_Install_kubeadm_Ubuntu_18.04_Jetson_Nano_Cluster/Environment.PNG)

[그림 1]은 Jetson Nano Cluster 기반 Kubernetes 설치 환경을 나타내고 있다. 상세한 환경 정보는 다음과 같다.

* Kubernetes 1.16
  * Network Plugin : calico or flannel or cilium 이용
  * Dashboard Addon : Dashboard 이용
* kubeadm 1.16
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* Node : Ubuntu 18.04, root user
  * Jetson Nano
    * Node 01 : Master Node
    * Node 02, 03, 04 : Worker Node
