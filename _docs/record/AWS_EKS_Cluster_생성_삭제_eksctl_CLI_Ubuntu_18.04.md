---
title: AWS EKS Cluster 생성 / aws CLI 이용 / Ubuntu 18.04
category: Record
date: 2021-04-06T12:00:00Z
lastmod: 2021-04-06T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

* Ubuntu 18.04 LTS 64bit, root user
* EKS Cluster
* aws CLI, ap-northeast-2 Zone

### 2. SSH Key 생성

~~~console
# aws ec2 create-key-pair --key-name ssup2-eks-ssh --query 'KeyMaterial' --output text > ssup2-eks-ssh.pem
~~~

EKS Node에 SSH로 접근하기 위한 SSH Key를 생성한다.
