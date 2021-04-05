---
title: AWS EKS Cluster 생성 / eksctl CLI 이용 / Ubuntu 18.04
category: Record
date: 2021-04-06T12:00:00Z
lastmod: 2021-04-06T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

* Ubuntu 18.04 LTS 64bit, root user
* EKS Cluster
  * Version 1.18
  * Subnet 10.0.0.0/16
* aws CLI
  * Region ap-northeast-2
  * Version2.1.34

### 2. aws CLI 설치

~~~console
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install
~~~

aws CLI를 설치한다.

~~~console
# aws configure
AWS Access Key ID [None]: <Access Key>
AWS Secret Access Key [None]: <Secret Access Key>
Default region name [None]: ap-northeast-2
Default output format [None]:
~~~

aws CLI에 인증정보를 설정한다.

### 3. SSH Key 생성

~~~console
# aws ec2 create-key-pair --key-name ssup2-eks-ssh --query 'KeyMaterial' --output text > ssup2-eks-ssh.pem
~~~

EKS Node에 SSH로 접근하기 위한 SSH Key를 생성한다.
