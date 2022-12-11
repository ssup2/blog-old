---
title: AWS EFS (Elastic File System)
category: Theory, Analysis
date: 2022-07-30T12:00:00Z
lastmod: 2022-07-30T12:00:00Z
comment: true
adsense: true
---

AWS의 EFS (Elastic File System) Service를 정리힌다. EFS Service는 AWS에서 제공하는 Managed NFS Server Service이다.

### 1. Storage Class

#### 1.1. Standard

#### 1.2. Standard-IA (Infrequent Access)

#### 1.3. One-Zone

#### 1.4. One-Zone-IA (Infrequent Access)

### 2. Architecture

#### 2.1. Standard

![[그림 1] Amazon EKS Standard]({{site.baseurl}}/images/theory_analysis/AWS_EFS/AWS_EFS_Standard.PNG){: width="700px"}

#### 2.2. One-Zone

![[그림 2] Amazon EKS One-Zone]({{site.baseurl}}/images/theory_analysis/AWS_EFS/AWS_EFS_One-Zone.PNG){: width="700px"}

### 3. Performance

TODO

### 4. Replication

### 5. Backup

TODO

### 6. 참고

* [https://docs.aws.amazon.com/efs/latest/ug/how-it-works.html](https://docs.aws.amazon.com/efs/latest/ug/how-it-works.html)