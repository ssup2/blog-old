---
title: AWS Spark on EKS
category: Theory, Analysis
date: 2023-08-20T12:00:00Z
lastmod: 2023-08-20T12:00:00Z
comment: true
adsense: true
---

AWS EKS Cluster에서 Spark Application 동작을 분석한다. AWS EKS Cluster에서 Spark Application을 동작시키기 위해서는 Spark에서 제공하는 spark-submit CLI 및 Spark Operator를 이용하는 방식과 EMR on EKS에서 제공하는 StartJobRun API를 이용하는 방식 2가지가 존재한다.

### 1. spark-submit CLI & Spark Operator

AWS EKS에서도 일반적인 Kubernetes Cluster처럼 spark-submit CLI 및 Spark Operator를 이용하여 Spark Application을 동작시킬 수 있다. 이 경우 Architecture 및 동작 방식은 다음의 [Link](https://ssup2.github.io/theory_analysis/Spark_Kubernetes/)의 내용처럼 일반적인 Kubernetes Cluster에서 spark-submit CLI 및 Spark Operator를 이용하는 방식과 동일하다.

다만 AWS EKS에서는 Driver, Executor Pod의 Container Image를 **EMR on EKS Spark Container Image**로 이용하는 것을 권장한다. EMR on EKS Spark Container Image에는 아래에 명시된 AWS와 Spark와 연관된 Library 및 Spark Connector가 포함되어 있기 때문이다.

* EMRFS S3-optimized comitter
* AWS Redshift용 Spark Connector : Spark Application에서 AWS Redshift 접근시 이용
* AWS SageMaker용 Spark Library : Spark Application의 DataFrame에 저장되어 있는 Data를 바로 AWS SageMaker를 통해서 Training 수행 가능

EMR on EKS Spark Container Image는 [Public AWS ECR](https://gallery.ecr.aws/emr-on-eks)에 공개되어 있다. Spark Application에서 고유한 Library 및 Spark Connector를 이용하는 경우 Custom Container Image를 구축해야 하는데, 이 경우에도 EMR on EKS Spark Container Image를 Base Image로 이용하는 것을 권장한다.

### 2. StartJobRun API

StartJobRun API는 EMR on EKS 환경에서 Spark Job을 제출하는 API이다. StartJobRun API를 이용하기 위해서는 AWS EMR에서 관리하는 가상의 Resource인 **Virtual Cluster**를 생성해야 한다. Virtual Cluster를 생성하기 위해서는 EKS Cluster에 존재하는 하나의 Namespace가 필요하다. 하나의 EKS Cluster에 다수의 Namespace를 생성하고 다수의 Virtual Cluster를 각 Namespace에 Mapping하여 하나의 EKS Cluster에서 다수의 Virtual Cluster를 운영할 수 있다.

![[그림 1] Spark on EKS Architecture with StartJobRun API]({{site.baseurl}}/images/theory_analysis/AWS_Spark_on_EKS/Spark_EKS_Architecture_StartJobRun_API.PNG)

[그림 1]은 하나의 Virtual Cluster가 있는 EKS Cluster에 StartJobRun API를 통해서 Spark Job을 제출할 경우의 Architecture를 나타내고 있다. StartJobRun API를 호출하면 Virtual Cluster와 Mapping 되어 있는 Namespace에 job-runner Pod가 생성되며, job-runner Pod 내부에서 spark-submit CLI가 동작한다. 즉 **StartJobRun API 방식도 내부적으로는 spark-submit CLI를 이용**하여 Spark Job을 제춣하는 방식이다.

![[그림 2] Spark on EKS Architecture with ACK Controller]({{site.baseurl}}/images/theory_analysis/AWS_Spark_on_EKS/Spark_EKS_Architecture_ACK_Controller.PNG)

### 3. 참조

* EMR on EKS Container Image : [https://gallery.ecr.aws/emr-on-eks](https://gallery.ecr.aws/emr-on-eks)
* StartJobRun Parameter : [https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/emr-eks-jobs-CLI.html#emr-eks-jobs-parameters](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/emr-eks-jobs-CLI.html#emr-eks-jobs-parameters)