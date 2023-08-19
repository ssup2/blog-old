---
title: AWS Spark on EKS
category: Theory, Analysis
date: 2023-07-22T12:00:00Z
lastmod: 2023-07-22T12:00:00Z
comment: true
adsense: true
---

AWS EKS Cluster에서 Spark Application 동작을 분석한다. AWS EKS Cluster에서 Spark Application을 동작시키기 위해서는 Spark에서 제공하는 spark-submit CLI 및 Spark Operator를 이용하는 방식과 EMR on EKS에서 제공하는 StartJobRun API를 이용하는 방식 2가지가 존재한다.

### 1. spark-submit CLI & Spark Operator

AWS EKS에서도 일반적인 Kubernetes Cluster처럼 spark-submit CLI 및 Spark Operator를 이용하여 Spark Application을 동작시킬 수 있다. 이 경우 Architecture 및 동작 방식은 다음의 [링크](https://ssup2.github.io/theory_analysis/Spark_Kubernetes/)의 내용처럼 일반적인 Kubernetes Cluster에서 spark-submit CLI 및 Spark Operator를 이용하는 방식과 동일하다.

다만 AWS EKS에서는 Driver, Executor Pod의 Container Image를 **EMR on EKS Spark Container Image**로 이용하는 것을 권장한다. EMR on EKS Spark Container Image에는 아래에 명시된 AWS와 Spark와 연관된 Library 및 Spark Connector가 포함되어 있기 때문이다.

* EMRFS S3-optimized comitter
* AWS Redshift용 Spark Connector : Spark Application에서 AWS Redshift 접근시 이용
* AWS SageMaker용 Spark Library : Spark Application의 DataFrame에 저장되어 있는 Data를 바로 AWS SageMaker를 통해서 Training 수행 가능

EMR on EKS Spark Container Image는 [Public AWS ECR](https://gallery.ecr.aws/emr-on-eks)에 공개되어 있다. Spark Application에서 고유한 Library 및 Spark Connector를 이용하는 경우 Custom Container Image를 구축해야 하는데, 이 경우에도 EMR on EKS Spark Container Image를 Base Image로 이용하는 것을 권장한다.

### 2. StartJobRun API

![[그림 1] Spark on EKS Architecture with StartJobRun API]({{site.baseurl}}/images/theory_analysis/AWS_Spark_on_EKS/Spark_EKS_Architecture_StartJobRun_API.PNG)

### 3. 참조

* EMR on EKS Container Image : [https://gallery.ecr.aws/emr-on-eks](https://gallery.ecr.aws/emr-on-eks)