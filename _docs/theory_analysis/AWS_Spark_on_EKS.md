---
title: AWS Spark on EKS
category: Theory, Analysis
date: 2023-07-22T12:00:00Z
lastmod: 2023-07-22T12:00:00Z
comment: true
adsense: true
---

AWS EKS Cluster에서 Spark Application 동작을 분석한다. AWS EKS Cluster에서 Spark Application을 동작시키기 위해서는 
Spark에서 제공하는 spark-submit CLI를 이용하는 방식과 EMR on EKS에서 제공하는 StartJobRun API를 이용하는 방식 2가지가 존재한다.

### 1. spark-submit CLI

### 2. StartJobRun API

![[그림 1] Spark on EKS Architecture with StartJobRun API]({{site.baseurl}}/images/theory_analysis/AWS_Spark_on_EKS/Spark_EKS_Architecture_StartJobRun_API.PNG)

### 3. 참조
