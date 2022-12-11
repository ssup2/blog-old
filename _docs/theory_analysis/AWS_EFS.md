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

AWS EFS는 다양한 Usecase에 대비하여 비용 효율적으로 AWS EFS를 이용할 수 있도록 Storage Class를 제공한다. 크게 Standard와 One Zone으로 분류되며 각각 IA (Infrequent Access) Storage Class가 존재한다.

#### 1.1. Standard

표준 Storage Class이다. AWS EFS의 Meta Data 및 Data는 다수의 AZ에 동기 방식으로 복제된다. 따라서 하나 또는 두개의 AZ 장애가 발생하더라도 Data Loss가 발생하지 않는다. AWS EFS에 저장된 Data의 크기에 비례하여 비용이 발생한다.

#### 1.2. Standard-IA (Infrequent Access)

Data 저장 비용은 Standard Class에 비해 낮지만 Data Read 수행시 추가 비용이 발생한다. 따라서 Data 접근 빈도가 낮을경우 이용을 권장한다. Standard Class와 동일하게 AWS EFS의 Meta Data 및 Data는 다수의 AZ에 동기 방식으로 복제된다.

#### 1.3. One Zone

One Zone Class는 의미 그대로 하나의 Zone에만 AWS EFS의 Meta Data 및 Data를 저장하는 Class이다. 따라서 Meta Data 및 Data가 저장된 AZ 장애시 Data를 접근할 수 없거나 Data Loss가 발생할 수 있지만, Data 저장 비용은 Standard, Standard-IA Class에 비해서 낮다. 어느 AZ에 AWS EFS의 Meta Data 및 Data를 저장할지 User가 생성시에 지정 가능하다.

#### 1.4. One Zone-IA (Infrequent Access)

Data 저장 비용은 One Zone Class에 비해 낮지만 Data Read 수행시 추가 비용이 발생한다. 따라서 Data 접근 빈도가 낮을경우 이용을 권장한다. One Zone Class와 동일하게 AWS EFS의 Meta Data 및 Data는 하나의 AZ에만 저장된다.

### 2. Architecture

#### 2.1. Standard

![[그림 1] Amazon EKS Standard]({{site.baseurl}}/images/theory_analysis/AWS_EFS/AWS_EFS_Standard.PNG){: width="700px"}

#### 2.2. One-Zone

![[그림 2] Amazon EKS One Zone]({{site.baseurl}}/images/theory_analysis/AWS_EFS/AWS_EFS_One-Zone.PNG){: width="700px"}

### 3. Performance

TODO

### 4. Replication

### 5. Backup

TODO

### 6. 참고

* [https://docs.aws.amazon.com/efs/latest/ug/how-it-works.html](https://docs.aws.amazon.com/efs/latest/ug/how-it-works.html)