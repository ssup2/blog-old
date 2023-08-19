---
title: Spark on Kubernetes
category: Theory, Analysis
date: 2023-08-12T12:00:00Zpus
lastmod: 2023-08-12T12:00:00Z
comment: true
adsense: true
---

### 1. Spark on Kubernetes

Spark는 Cluster Manager로 Kubernetes를 지원한다. 즉 Kubernetes Cluster가 관리하는 Computing Resource를 Spark에서 이용할 수 있다.

#### 1.1. Spark Job 제출

Spark에서 Kubernetes Cluster를 대상으로 Spark Job을 제출하는 방법은 spark-submit CLI를 이용하는 방식과 Spark Operator를 이용하는 방식 두가지가 존재한다. 각각의 방식에 따라서 Spark Job을 제출하는 방식과 Architecture가 달라진다.

##### 1.1.1. spark-submit CLI

![[그림 1] spark-submit CLI Architecture]({{site.baseurl}}/images/theory_analysis/Spark_Kubernetes/spark-submit_Architecture.PNG){: width="700px"}

spark-submit CLI는 Spark에서 Spark Job 제출을 위한 도구이며, Kubernetes Cluster를 대상으로도 Spark Job 제출이 가능하다. [그림 1]의 파랑색 화살표는 spark-submit CLI를 통해서 Spark Job이 Kubernetes Cluster로 제출될 경우 Spark Job의 처리 과정을 나타내고 있다.

spark-submit CLI으로 Spark Job 제출시 Architecture를 나타내고 있다. spark-submit CLI를 통해서 Driver Pod가 생성이 되고, Driver Pod에서는 다시 Executor Pod를 생성하여 Spark Job을 처리한다. spark-submit CLI를 통한 Spark Job의 상세한 설정은 "\-\-conf" Parameter  또는 "\-\-properties-file" Parameter를 통해서 [Property](https://spark.apache.org/docs/latest/configuration.html) 설정이 가능하다.

{% highlight shell %}
spark-submit \
 --master k8s://87C2A505AF21618F97F402E454E530AF.yl4.ap-northeast-2.eks.amazonaws.com \
 --deploy-mode cluster \
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

[Shell 1]은 Kubernetes Cluster에 spark-submit CLI를 통해서 Spark Job을 제출하는 예제를 나타내고 있다. spark-submit CLI는 실행되면 가장 먼저 Driver Pod 및 Spark Job 구동에 필요한 설정 정보 정보를 Driver ConfigMap으로 생성한다. 이후에 Driver Pod를 생성하면서 이전에 생성한 Driver ConfigMap을 Driver Pod의 Volume으로 설정하여, Driver Pod 내부의 Driver가 Driver ConfigMap의 내용을 참조할 수 있도록 만든다.

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

[파일 2]는 Executor ConfigMap 예제를 나타내고 있다. Executor Pod 내부의 Executor는 Driver의 Headless Service를 통해서 Driver Pod의 IP 정보를 알아낸 이후에 Driver Pod에 접속한다. 이후 Executor는 Driver로 부터 Task를 받아 처리한다.

##### 1.1.2. Spark Operator

![[그림 2] Spark Operator Architecture]({{site.baseurl}}/images/theory_analysis/Spark_Kubernetes/spark-operator_Architecture.PNG)

Spark Operator는 Spark Job 제출을 Kubernetes Object로 정의하도록 도와주는 도구이다. [그림 2]는 Spark Operator를 통해서 Spark Job 제출시 Architecture를 나타내고 있다. spark-submit CLI의 Architecture와 비교시 가장 큰 차이점은 User가 spark-submit CLI를 이용하지 않고 SparkApplication, ScheduledSparkApplication Object를 정의하여 Spark Job을 제출한다는 점이다.

SparkApplication, ScheduledSparkApplication 모두 Spark Operator가 제공하는 고유의 Object이다. SparkApplication은 Ad-hoc 형태로 하나의 Spark Job을 제출하는 경우 이용하며, ScheduledSparkApplication Object는 Cron과 깉이 주기적으로 Spark Job을 제출해야하는 경우 이용한다. SparkApplication, ScheduledSparkApplication Object가 생성되면 Spark Operator 내부에 존재하는 spark-submit CLI가 Spark Job 제출을 수행한다. SparkApplication, ScheduledSparkApplication의 상세한 Spec은 [Operator API Page](https://googlecloudplatform.github.io/spark-on-k8s-operator/docs/api-docs.html)에서 확인할 수 있다.

{% highlight yaml linenos %}
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-pi
  namespace: default
spec:
  type: Python
  mode: cluster
  image: "public.ecr.aws/r1l5w1y9/spark-operator:3.2.1-hadoop-3.3.1-java-11-scala-2.12-python-3.8-latest"
  mainApplicationFile: local:///opt/spark/examples/src/main/python/pi.py
  sparkVersion: "3.1.1"
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
    type: Python
    mode: cluster
    image: "public.ecr.aws/r1l5w1y9/spark-operator:3.2.1-hadoop-3.3.1-java-11-scala-2.12-python-3.8-latest"
    mainApplicationFile: local:///opt/spark/examples/src/main/python/pi.py
    sparkVersion: "3.1.1"
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

#### 1.2. Pod Template

{% highlight yaml linenos %}
apiVersion: v1
kind: Pod
spec:
  volumes:
    - name: source-data-volume
      emptyDir: {}
    - name: metrics-files-volume
      emptyDir: {}
  nodeSelector:
    eks.amazonaws.com/nodegroup: emr-containers-nodegroup
  containers:
  - name: spark-kubernetes-driver # This will be interpreted as driver Spark main container
    env:
      - name: RANDOM
        value: "random"
    volumeMounts:
      - name: shared-volume
        mountPath: /var/data
      - name: metrics-files-volume
        mountPath: /var/metrics/data
  - name: custom-side-car-container # Sidecar container
    image: <side_car_container_image>
    env:
      - name: RANDOM_SIDECAR
        value: random
    volumeMounts:
      - name: metrics-files-volume
        mountPath: /var/metrics/data
    command:
      - /bin/sh
      - '-c'
      -  <command-to-upload-metrics-files>
  initContainers:
  - name: spark-init-container-driver # Init container
    image: <spark-pre-step-image>
    volumeMounts:
      - name: source-data-volume # Use EMR predefined volumes
        mountPath: /var/data
    command:
      - /bin/sh
      - '-c'
      -  <command-to-download-dependency-jars>
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] Pod Template Example</figcaption>
</figure>

Pod Template를 통해서 Spark Config로 설정할 수 없서 Driver Pod 또는 Executor Pod의 설정이 가능하다. [파일 5]는 AWS EMR on EKS 문서에서 제공하는 Pod Template의 예제를 나타내고 있다. Spark Config로 설정이 불가능한 Init Container, Sidecar Container 등을 Pod Template을 통해서 설정할 수 있다.

{% highlight shell %}
spark-submit \
 --master k8s://87C2A505AF21618F97F402E454E530AF.yl4.ap-northeast-2.eks.amazonaws.com \
 --deploy-mode cluster \
 --driver-cores 1 \
 --driver-memory 512m \
 --num-executors 1 \
 --executor-cores 1 \
 --executor-memory 512m \
 --conf spark.kubernetes.driver.podTemplateFile=s3a://bucket/driver.yml
 --conf spark.kubernetes.executor.podTemplateFile=s3a://bucket/executor.yml
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] spark-submit CLI with Event Log Example</figcaption>
</figure>

[Shell 3]은 Pod Template을 지정하는 예제를 나타내고 있다. Pod Template의 지정은 Spark Config의 podTemplateFile 설정을 통해서 지정할 수 있다. Driver Pod와 Executor Pod 각각 지정이 가능하다. 

#### 1.3. Spark History Server

Spark History Server는 Spark Driver 또는 Spark Executor가 남기는 Event Log를 시각화 해주는 역할을 수행한다. Kubernetes Cluster 환경에서 Spark History Server는 별도의 Pod로 동작한다. Spark Job이 제출과 함께 Config 설정을 통해서 Spark Driver가 Event Log Enable 및 Event Log를 남길 경로를 지정할 수 있다. Kubernetes Cluster 환경에서는 일반적으로 PVC 또는 AWS의 S3와 같은 외부의 Object Storage를 Event Log의 저장소로 이용한다.

{% highlight shell %}
spark-submit \
 --master k8s://87C2A505AF21618F97F402E454E530AF.yl4.ap-northeast-2.eks.amazonaws.com \
 --deploy-mode cluster \
 --driver-cores 1 \
 --driver-memory 512m \
 --num-executors 1 \
 --executor-cores 1 \
 --executor-memory 512m \
 --conf spark.kubernetes.namespace=spark \
 --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
 --conf spark.kubernetes.container.image=public.ecr.aws/r1l5w1y9/spark-operator:3.2.1-hadoop-3.3.1-java-11-scala-2.12-python-3.8-latest \
 --conf spark.eventLog.enabled=true \
 --conf spark.eventLog.dir=s3a://ssup2-spark/history \
 --conf spark.kubernetes.driver.secretKeyRef.AWS_ACCESS_KEY_ID=aws-secrets:key \
 --conf spark.kubernetes.driver.secretKeyRef.AWS_SECRET_ACCESS_KEY=aws-secrets:secret \
 --conf spark.kubernetes.executor.secretKeyRef.AWS_ACCESS_KEY_ID=aws-secrets:key \
 --conf spark.kubernetes.executor.secretKeyRef.AWS_SECRET_ACCESS_KEY=aws-secrets:secret \
 local:///opt/spark/examples/src/main/python/pi.py
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] spark-submit CLI with Event Log Example</figcaption>
</figure>

[그림 1]의 빨간색 화살표는 Event Log를 Spark History Server를 통해서 사용자에게 전달되는 과정을 나타내고 있다. spark-submit CLI로 Spark Job을 제출하는 경우 [Shell 3]과 같이 Config Parameter의 eventLog.dir 설정을 통해서 Event Log의 경로를 설정할 수 있다. secretKeyRef 설정의 경우 Event Log 경로로 지정한 s3(s3a://ssup2-spark/history)에 접근하기 위해서 Kubernetes Secret으로 저장된 Access Key, Secret Access Key를 나타낸다.

{% highlight yaml linenos %}
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-pi
  namespace: default
spec:
  type: Python
  mode: cluster
  image: "public.ecr.aws/r1l5w1y9/spark-operator:3.2.1-hadoop-3.3.1-java-11-scala-2.12-python-3.8-latest"
  mainApplicationFile: local:///opt/spark/examples/src/main/python/pi.py
  sparkVersion: "3.1.1"
  sparkConf:
    spark.eventLog.enabled: "true"
    spark.eventLog.dir: "s3a://ssup2-spark/history"
    spark.kubernetes.driver.secretKeyRef.AWS_ACCESS_KEY_ID: "aws-secrets:key"
    spark.kubernetes.driver.secretKeyRef.AWS_SECRET_ACCESS_KEY : "aws-secrets:secret"
    spark.kubernetes.executor.secretKeyRef.AWS_ACCESS_KEY_ID: "aws-secrets:key"
    spark.kubernetes.executor.secretKeyRef.AWS_SECRET_ACCESS_KEY : "aws-secrets:secret"
  driver:
    cores: 1
    memory: 512m
  executor:
    cores: 1
    instances: 1
    memory: 512m
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] SparkApplication Example</figcaption>
</figure>

[그림 2]의 빨간색 화살표도 Event Log를 Spark History Server를 통해서 사용자에게 전달되는 과정을 나타내고 있다. [파일 5]는 Event Log를 설정한 SparkApplication을 나타내고 있다. sparkConf 항목의 eventLog.dir 설정을 통해서 Event Log의 경로를 설정할 수 있다.

#### 1.4. Scheduler for Spark

Kubernetes의 Default Scheduler는 단순히 각 Pod 단위로 Scheduling을 수행할 뿐 Pod 사이의 관계까지 고려하여 Scheduling을 수행하지 않는다. Kubernetes에서는 이러한 단점을 완화시키기 위해서 Third-party Scheduler 또는 사용자가 직접 Customer Scheduler를 개발하고 이용할 수 있도록 도와주는 Multiple Scheduler 기능을 제공한다.

Kubernetes Cluster에 Spark Job이 제출되는 경우 Driver Pod 내부의 Driver가 Executor Pod들을 직접 생성하여 이용한다는 특징으로 인해서 다수의 Pod를 한번에 Scheduling하는 **Batch Scheduling** 기법이 유용한 경우가 많다. 또한 Spark Job의 Shuffle 연산에 의해서 Executor Pod들은 서로 많은 Data를 주고 받는다는 특징 때문에, Executor Pod들을 가능한 동일한 Node에 배치시키는게 가능한 **Application-aware Scheduling** 기법이 유용한 경우가 많다. 이러한 Scheduling 기법들은 일반적으로 **YuniKorn**, **Volcano**와 같은 Third-party Scheduler를 통해서 이용할 수 있다.

##### 1.4.1. Batch Scheduling

Kubernetes Cluster에 Spark Job이 제출되는 경우 Driver Pod 내부의 Driver가 직접 Executor Pod들을 직접 생성한다는 특징을 갖는다. 이는 Kubernetes Cluster에서 Cluster Auto-scailing을 이용하고 있지 않는다면 Driver가 생성한 Executor Pod들이 Resource 부족으로 생성에 실패할 수 있다는걸 의미한다. Driver Pod가 생성된 이후에 Resource 부족으로 인해서 모든 Executor Pod들의 생성이 실패한다면, Spark Job 처리 실패뿐만 아니라 Driver Pod 구동에 이용한 Resource의 불필요한 낭비도 발생하게 된다.

이러한 문제가 발생하는 이유는 Spark Job이 제출된 시점에는 Driver Pod만 생성이 되고, Driver Pod가 생성한 Executor Pod들을 Driver Pod 내부에서 이용한다는 사실을 Kubernetes의 Default Scheduler가 인지하지 못하기 때문이다. Driver Pod와 모든 Executor Pod가 이용 가능한 Resource를 확보할 경우에만 한번에 모든 Pod들을 Scheduling하는 Batch Scheduling 기법을 이용하면 이러한 문제를 해결할 수 있다.

Batch Scheduling 기법을 이용하면 Kubernetes Cluster에서 Cluster Auto-scaler가 동작하고 있는 환경에서도 빠르게 Spark Job을 처리할 수 있도록 도와준다. Batch Scheduling을 이용하지 않는다면 Driver Pod가 생성되면서 Cluster Auto-scailing이 한번 발생하고 이후에 Executor Pod들이 생성되면서 Auto-scailing이 발생하여 총 2번의 Auto-scailing이 발생한다. 반면에 Batch Scheduling을 이용하면 한번의 Auto-scailing으로 Driver Pod와 Executor Pod들이 필요한 Resource를 확보할 수 있기 때문에 Auto-scailing의 발생 횟수를 줄일 수 있다.

#### 1.5. Monitoring with Prometheus

Spark 3.0 Version 부터 Driver는 Executor로부터 Metric을 받아 ":4040/metrics/executors/prometheus" 경로로 Executor의 Metric을 노출시킬 수 있다. 노출되는 Executor Metric은 [Link](https://spark.apache.org/docs/latest/monitoring.html#executor-metrics)에서 확인할 수 있습니다.

{% highlight shell %}
spark-submit \
 --master k8s://87C2A505AF21618F97F402E454E530AF.yl4.ap-northeast-2.eks.amazonaws.com \
 --deploy-mode cluster \
 --driver-cores 1 \
 --driver-memory 512m \
 --num-executors 1 \
 --executor-cores 1 \
 --executor-memory 512m \
 --conf spark.kubernetes.namespace=spark \
 --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
 --conf spark.kubernetes.container.image=public.ecr.aws/r1l5w1y9/spark-operator:3.2.1-hadoop-3.3.1-java-11-scala-2.12-python-3.8-latest \
 --conf spark.ui.prometheus.enabled=true \
 --conf spark.kubernetes.driver.annotation.prometheus.io/scrape=true \
 --conf spark.kubernetes.driver.annotation.prometheus.io/path=/metrics/executors/prometheus \
 --conf spark.kubernetes.driver.annotation.prometheus.io/port=4040 \
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] spark-submit CLI with Event Log Example</figcaption>
</figure>

Prometheus에서 Executor Pod에 몇가지 Annotation을 붙이면 Promethues에서 자동으로 Target을 Discovery 하고 Metric을 수집하도록 만들 수 있다. [Shell 4]는 Prometheus로 Metric을 자동으로 노출시키는 예제를 나타내고 있다. Spark Config 부분에서 Promtheus를 활성화 하고 Annotation을 붙여 Prometheus가 자동으로 Driver Metric을 가져갈 수 있도록 만들고 있다.

### 2. 참조

* [https://spark.apache.org/docs/latest/running-on-kubernetes.html](https://spark.apache.org/docs/latest/running-on-kubernetes.html)
* [https://swalloow.github.io/spark-on-kubernetes-scheduler/](https://swalloow.github.io/spark-on-kubernetes-scheduler/)
* spark-submit : [https://spark.apache.org/docs/latest/submitting-applications.html](https://spark.apache.org/docs/latest/submitting-applications.html)
* Spark Configuration : [https://spark.apache.org/docs/latest/configuration.html](https://spark.apache.org/docs/latest/configuration.html)
* Spark Pod Template Example : [https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/pod-templates.html](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/pod-templates.html)
* Spark Operator API Spec : [https://googlecloudplatform.github.io/spark-on-k8s-operator/docs/api-docs.html](https://googlecloudplatform.github.io/spark-on-k8s-operator/docs/api-docs.html)
* Spark Executor Metric : [https://spark.apache.org/docs/latest/monitoring.html#executor-metrics](https://spark.apache.org/docs/latest/monitoring.html#executor-metrics)
* Spark Monitoring with Prometheus : [http://jason-heo.github.io/bigdata/2021/01/31/spark30-prometheus.html](http://jason-heo.github.io/bigdata/2021/01/31/spark30-prometheus.html)
* Spark Monitoring with Prometheus : [https://dzlab.github.io/bigdata/2020/07/03/spark3-monitoring-1/](https://dzlab.github.io/bigdata/2020/07/03/spark3-monitoring-1/)
* Spark Monitoring with Prometheus : [https://dzlab.github.io/bigdata/2020/07/03/spark3-monitoring-2/](https://dzlab.github.io/bigdata/2020/07/03/spark3-monitoring-2/)