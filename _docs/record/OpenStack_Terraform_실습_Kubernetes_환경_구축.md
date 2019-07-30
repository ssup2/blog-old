---
title: OpenStack Terraform 실습 / Kubernetes 환경 구축
category: Record
date: 2019-07-30T12:00:00Z
lastmod: 2019-07-30T12:00:00Z
comment: true
adsense: true
---

### 1. 실습, 구축 환경

![[그림 1] OpenStack Terraform 실습, 구축 환경]({{site.baseurl}}/images/record/OpenStack_Terraform_Practice_Kubernetes/Environment.PNG)

[그림 1]은 Terraform을 이용하여 OpenStack 위에 구축하려는 Kubernetes 환경을 나타내고 있다. Externel-Router는 미리 생성되어 있다고 가정하고 진행한다.

* OpenStack : Stein
* Network :
  * Internal Network : Kubernetes Network, 30.0.0.0/24
* Flavor :
  * Standard : 4vCPU, 4GB RAM, 30GB Disk

### 2. 참조