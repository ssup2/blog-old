---
title: Kubernetes 설치 - Ubuntu 16.04
category: Record
date: 2018-07-15T12:00:00Z
lastmod: 2018-07-15T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* VirtualBox 5.0.14r
  * Master Node - Ubuntu Desktop 18.04 64bit - 1대
  * Worker Node - Ubuntu Server 18.04 64bit - 1대
* Kubernetes
  * Network Addon - calico 이용
  * Dashboard Addon - Dashboard 이용
* kubeadm
  * VM을 이용하여 Cluster 환경을 구축하는 경우 kubeadm을 이용하여 쉽게 Kubernetes를 설치 할 수 있다.
* Docker 1.12.6
  * Kubernetes에서 1.12.x Version을 권장하고 있다.
* Password
  * Kubernetes 설치에 필요한 Password는 간편한 설치를 위해 **root**로 통일한다.
* 모든 Node에서 root User로 설치를 진행한다.

### 2. Node 설정

![]({{site.baseurl}}/images/record/Kubernetes_Install_Ubuntu18.04/Node_Setting.PNG){: width="500px"}

* VirtualBox를 이용하여 위의 그림과 같이 가상의 Master, Worker Node (VM)을 생성한다.
* Kubernetes의 Dashboard는 기본적으로 Master의 Web Browser에서만 이용할 수 있다. 따라서 Master Node에는 Ubuntu Desktop Version 또는 X Server를 이용한다.
* NAT - Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* Router - 공유기를 이용하여 192.168.0.0/24 Network를 구축한다. (NAT)