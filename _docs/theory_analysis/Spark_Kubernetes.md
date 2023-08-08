---
title: Spark on Kubernetes
category: Theory, Analysis
date: 2023-06-16T12:00:00Zpus
lastmod: 2023-06-16T12:00:00Z
comment: true
adsense: true
---

### 1. Spark on Kubernetes

Spark는 Cluster Manager로 Kubernetes를 지원한다. 즉 Kubernetes Cluster가 관리하는 Computing Resource를 Spark에서 이용할 수 있다.

#### 1.1. Spark Job 제출

Spark에서 Kubernetes Cluster를 대상으로 Spark Job을 제출하는 방법은 spark-submit CLI를 이용하는 방식과 Spark Operator를 이용하는 방식 두가지가 존재한다. 각각의 방식에 따라서 Spark Job을 제출하는 방식과 Architecture가 달라진다.

##### 1.1.1. spark-submit CLI

![[그림 1] spark-submit CLI Architecture]({{site.baseurl}}/images/theory_analysis/Spark_Kubernetes/spark-submit_Architecture.PNG){: width="600px"}

spark-submit CLI는 Spark에서 Spark Job 제출을 위한 도구이며, Kubernetes Cluster를 대상으로도 Spark Job 제출이 가능하다. [그림 1]은 spark-submit으로 Spark Job 제출시 Architecture를 나타내고 있다. 

{% highlight yaml linenos %}
apiVersion: v1
data:
  spark.kubernetes.namespace: spark
  spark.properties: |
    #Java properties built from Kubernetes config map with name: spark-drv-acab0389d5a14140-conf-map
    #Tue Aug 08 23:51:02 KST 2023
    spark.driver.port=7078
    spark.master=k8s\://https\://87C2A505AF21618F97F402E454E530AF.yl4.ap-northeast-2.eks.amazonaws.com
    spark.submit.pyFiles=
    spark.app.name=org.apache.spark.examples.SparkPi
    spark.kubernetes.resource.type=java
    spark.submit.deployMode=cluster
    spark.driver.host=org-apache-spark-examples-sparkpi-3abfe389d5a139da-driver-svc.spark.svc
    spark.driver.blockManager.port=7079
    spark.app.id=spark-b6683902e4e444b1aeb88836c127b038
    spark.kubernetes.namespace=spark
    spark.app.submitTime=1691506260371
    spark.kubernetes.container.image=895885662937.dkr.ecr.us-west-2.amazonaws.com/spark/emr-6.10.0\:latest
    spark.kubernetes.memoryOverheadFactor=0.1
    spark.kubernetes.submitInDriver=true
    spark.kubernetes.authenticate.driver.serviceAccountName=spark
    spark.kubernetes.driver.pod.name=org-apache-spark-examples-sparkpi-3abfe389d5a139da-driver
    spark.jars=local\:///usr/lib/spark/examples/jars/spark-examples.jar
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Driver Pod ConfigMap</figcaption>
</figure>

##### 1.1.2. Spark Operator

![[그림 2] Spark Operator Architecture]({{site.baseurl}}/images/theory_analysis/Spark_Kubernetes/spark-operator_Architecture.PNG)

### 2. Timeout

### 3. Scheduler

### 4. 참조

* [https://spark.apache.org/docs/latest/running-on-kubernetes.html](https://spark.apache.org/docs/latest/running-on-kubernetes.html)
