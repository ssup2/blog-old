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

spark-submit CLI는 Spark에서 Spark Job 제출을 위한 도구이며, Kubernetes Cluster를 대상으로도 Spark Job 제출이 가능하다. [그림 1]의 파링색 화살표는 spark-submit CLI를 통해서 Spark Job이 Kubernetes Cluster로 제출될 경우 Spark Job의 처리 과정을 나타내고 있다.

spark-submit CLI으로 Spark Job 제출시 Architecture를 나타내고 있다. spark-submit CLI를 통해서 Driver Pod가 생성이 되고, Driver Pod에서는 다시 Executor Pod를 생성하여 Spark Job을 처리한다. spark-submit CLI를 통한 Spark Job의 상세한 설정은 "--conf" Parameter  또는 "--properties-file" Parameter를 통해서 [Property](https://spark.apache.org/docs/latest/configuration.html) 설정이 가능하다.

{% highlight shell %}
spark-submit \
 --master k8s://87C2A505AF21618F97F402E454E530AF.yl4.ap-northeast-2.eks.amazonaws.com \
 --deploy-mode cluster \
 --class org.apache.spark.examples.SparkPi \
 --driver-cores 1 \
 --driver-memory 512m \
 --num-executors 1 \
 --executor-cores 1 \
 --executor-memory 512m \
 --conf spark.kubernetes.namespace=spark \
 --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
 --conf spark.kubernetes.container.image=public.ecr.aws/r1l5w1y9/spark-operator:3.2.1-hadoop-3.3.1-java-11-scala-2.12-python-3.8-latest \
 local:///opt/spark/examples/src/main/python/pi.py
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] spark-submit CLI Example</figcaption>
</figure>

[Shell 1]은 Kubernetes Cluster에 spark-submit CLI를 통해서 Spark Job을 제출하는 예제를 나타내고 있다. Spark Job이 실행되는 Kubernetes Cluster 정보 및 Driver/Executor Pod, Spark Job 구동에 필요한 설정들을 spark-submit CLI의 Parameter로 설정한다. 또는 별도의 설정 파일을 생성하고 "--properties-file" Parameter를 통해서도 설정할 수 있다. Spark Job 관련 설정들은 [Property Site](https://spark.apache.org/docs/latest/configuration.html)에서 확인 가능하다.

spark-submit CLI는 실행되면 가장 먼저 Driver Pod 및 Spark Job 구동에 필요한 설정 정보 정보를 Driver ConfigMap으로 생성한다. 이후에 Driver Pod를 생성하면서 이전에 생성한 Driver ConfigMap을 Driver Pod의 Volume으로 설정하여, Driver Pod 내부의 Driver가 Driver ConfigMap의 내용을 참조할 수 있도록 만든다.

{% highlight yaml linenos %}
apiVersion: v1
data:
  spark.kubernetes.namespace: spark
  spark.properties: |
    #Java properties built from Kubernetes config map with name: spark-drv-8b9fd589dcfc5820-conf-map
    #Thu Aug 10 10:07:52 KST 2023
    spark.executor.memory=512m
    spark.driver.port=7078
    spark.driver.memory=512m
    spark.master=k8s\://https\://87C2A505AF21618F97F402E454E530AF.yl4.ap-northeast-2.eks.amazonaws.com
    spark.submit.pyFiles=
    spark.driver.cores=1
    spark.app.name=org.apache.spark.examples.SparkPi
    spark.executor.cores=1
    spark.kubernetes.resource.type=java
    spark.submit.deployMode=cluster
    spark.driver.host=org-apache-spark-examples-sparkpi-4fb69989dcfc505e-driver-svc.spark.svc
    spark.driver.blockManager.port=7079
    spark.app.id=spark-e3d8c4a199e44163936889b3ebda2ed7
    spark.kubernetes.namespace=spark
    spark.app.submitTime=1691629670418
    spark.kubernetes.container.image=895885662937.dkr.ecr.us-west-2.amazonaws.com/spark/emr-6.10.0\:latest
    spark.kubernetes.memoryOverheadFactor=0.1
    spark.kubernetes.submitInDriver=true
    spark.kubernetes.authenticate.driver.serviceAccountName=spark
    spark.kubernetes.driver.pod.name=org-apache-spark-examples-sparkpi-4fb69989dcfc505e-driver
    spark.executor.instances=1
    spark.jars=local\:///usr/lib/spark/examples/jars/spark-examples.jar
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Driver Pod ConfigMap Example</figcaption>
</figure>

[파일 1]은 Driver ConfigMap 예제를 나타내고 있다. Driver/Executor Pod 및 Spark Job 관련 설정들이 저장되어 있는것을 확인할 수 있다. Driver Pod 내부의 Driver는 Driver ConfigMap의 내용을 참고하여 Executor Pod 내부의 Executor가 참고할 Executor ConfigMap을 생성한다. 또한 Executor에게 Driver Pod의 IP 정보를 제공하기 위해서 Driver Pod의 Headless Service도 같이 생성한다. 이후에 Driver는 Driver ConfigMap의 내용을 참고하여 Executor ConfigMap을 Volume으로 이용하는 Executor Pod를 생성한다.

{% highlight yaml linenos %}
apiVersion: v1
data:
  spark.kubernetes.namespace: spark
  spark.properties: |
    #Java properties built from Kubernetes config map with name: spark-exec-16664f89dd377f76-conf-map
    #Thu Aug 10 02:12:29 UTC 2023
    spark.kubernetes.namespace=spark
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Executor Pod ConfigMap Example</figcaption>
</figure>

[파일 2]는 Executor ConfigMap 예제를 나타내고 있다. Executor Pod 내부의 Executor는 Driver의 Headless Service를 통해서 Driver Pod의 IP 정보를 알아낸 이후에 Driver Pod에 접속한다. 이후에 Driver로 부터 Task를 받아 처리한다.

{% highlight shell %}
spark-submit \
 --master k8s://87C2A505AF21618F97F402E454E530AF.yl4.ap-northeast-2.eks.amazonaws.com \
 --deploy-mode cluster \
 --class org.apache.spark.examples.SparkPi \
 --driver-cores 1 \
 --driver-memory 512m \
 --num-executors 1 \
 --executor-cores 1 \
 --executor-memory 512m \
 --conf spark.kubernetes.namespace=spark \
 --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
 --conf spark.kubernetes.container.image=public.ecr.aws/r1l5w1y9/spark-operator:3.2.1-hadoop-3.3.1-java-11-scala-2.12-python-3.8-latest \
 local:///opt/spark/examples/src/main/python/pi.py
 --conf spark.eventLog.enabled=true \
 --conf spark.eventLog.dir=s3a://ssup2-spark/history \
 --conf spark.kubernetes.driver.secretKeyRef.AWS_ACCESS_KEY_ID=aws-secrets:key \
 --conf spark.kubernetes.driver.secretKeyRef.AWS_SECRET_ACCESS_KEY=aws-secrets:secret \
 --conf spark.kubernetes.executor.secretKeyRef.AWS_ACCESS_KEY_ID=aws-secrets:key \
 --conf spark.kubernetes.executor.secretKeyRef.AWS_SECRET_ACCESS_KEY=aws-secrets:secret \
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] spark-submit CLI with Event Log Example</figcaption>
</figure>

[그림 1]의 빨간색 화살표는 Spark Driver의 Event Log를 Spark History Server를 통해서 사용자에게 전달되는 과정을 나타내고 있다. spark-submit CLI로 Spark Job을 제출하는 경우 [Shell 2]와 같이 Spark Driver의 Event Log를 어디에 저장할지 지정이 가능하다. 일반적으로는 HDFS 또는 AWS S3에 Event Log를 저장한다. 저장된 Event Log는 Kubernetes Cluster에 설치된 Spark History Server에 의해서 시각화된다.

##### 1.1.2. Spark Operator

![[그림 2] Spark Operator Architecture]({{site.baseurl}}/images/theory_analysis/Spark_Kubernetes/spark-operator_Architecture.PNG)

Spark Operator는 Spark Job 제출을 Kubernetes Object로 정의하도록 도와주는 도구이다. [그림 2]는 Spark Operator를 통해서 Spark Job 제출시 Architecture를 나타내고 있다. spark-submit CLI의 Architecture와 비교시 가장 큰 차이점은 User가 spark-submit CLI를 이용하지 않고 SparkApplication, ScheduledSparkApplication Object를 정의하여 Spark Job을 제출한다는 점이다.

SparkApplication, ScheduledSparkApplication 모두 Spark Operator가 제공하는 고유의 Object이다. SparkApplication은 Add-hoc 형태로 하나의 Spark Job을 제출하는 경우 이용하며, ScheduledSparkApplication Object는 Cron과 깉이 주기적으로 Spark Job을 제출해야하는 경우 이용한다. SparkApplication, ScheduledSparkApplication Object가 생성되면 Spark Operator 내부에 존재하는 spark-submit CLI가 Spark Job 제출을 수행한다. SparkApplication, ScheduledSparkApplication의 상세한 Spec은 [Operator API Page](https://googlecloudplatform.github.io/spark-on-k8s-operator/docs/api-docs.html)에서 확인할 수 있다.

{% highlight yaml linenos %}
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-pi
  namespace: default
spec:
  type: Scala
  mode: cluster
  image: gcr.io/spark/spark:v3.1.1
  mainClass: org.apache.spark.examples.SparkPi
  mainApplicationFile: local:///opt/spark/examples/jars/spark-examples_2.12-3.1.1.jar
  driver:
    cores: 1
    memory: 512m
  executor:
    cores: 1
    instances: 1
    memory: 512m
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] SparkApplication Example</figcaption>
</figure>

[파일 3]은 SparkApplication의 예제를 나타내고 있다. Spec 부분에 Spark Job을 수행하기 위한 설정들이 존재하는 것을 확인할 수 있다.

{% highlight yaml linenos %}
apiVersion: "sparkoperator.k8s.io/v1beta2"
kind: ScheduledSparkApplication
metadata:
  name: spark-pi-scheduled
  namespace: default
spec:
  schedule: "@every 5m"
  concurrencyPolicy: Allow
  successfulRunHistoryLimit: 1
  failedRunHistoryLimit: 3
  template:
    type: Scala
    mode: cluster
    image: gcr.io/spark/spark:v3.1.1
    mainClass: org.apache.spark.examples.SparkPi
    mainApplicationFile: local:///opt/spark/examples/jars/spark-examples_2.12-3.1.1.jar
    driver:
      cores: 1
      memory: 512m
    executor:
      cores: 1
      instances: 1
      memory: 512m
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] ScheduledSparkApplication Example</figcaption>
</figure>

[파일 4]는 ScheduledSparkApplication의 예제를 나타내고 있다. ScheduledSparkApplication의 Spec의 Template 부분은 SparkApplication의 Spec 부분과 동일하다. 다만 ScheduledSparkApplication은 Spec에 위치한 Schedule, Concurrency Policy 등은 ScheduledSparkApplication에서만 이용이 가능하다.

Spark Operator 이용 시 spark-submit CLI를 이용할 경우와 다른 또 한가지는 차이점은, Spark Operator는 Spark Driver에서 제공하는 Web UI를 User가 접근할 수 있도록 Service 및 Ingress를 생성해 준다는 점이다. [그림 2]의 초록색 화살표는 Spark Driver의 Service, Ingress를 통해서 사용자가 Spark Web UI에 접근하는 과정을 나타내고 있다.

### 2. Scheduler

### 3. 참조

* [https://spark.apache.org/docs/latest/running-on-kubernetes.html](https://spark.apache.org/docs/latest/running-on-kubernetes.html)
* [https://swalloow.github.io/spark-on-kubernetes-scheduler/](https://swalloow.github.io/spark-on-kubernetes-scheduler/)
* spark-submit : [https://spark.apache.org/docs/latest/submitting-applications.html](https://spark.apache.org/docs/latest/submitting-applications.html)
* Spark Configuration : [https://spark.apache.org/docs/latest/configuration.html](https://spark.apache.org/docs/latest/configuration.html)
* Spark Operator API Spec : [https://googlecloudplatform.github.io/spark-on-k8s-operator/docs/api-docs.html](https://googlecloudplatform.github.io/spark-on-k8s-operator/docs/api-docs.html)
* Spark K8s Scheduler : [https://swalloow.github.io/spark-on-kubernetes-scheduler/](https://swalloow.github.io/spark-on-kubernetes-scheduler/)
