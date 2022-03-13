---
title: Kubernetes Metric Server
category: Theory, Analysis
date: 2020-10-10T12:00:00Z
lastmod: 2020-10-10T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 Metric Server를 분석한다.

### 1. Kubernetes Metric Server

![[그림 1] Kubernetes Metric Server]({{site.baseurl}}/images/theory_analysis/Kubernetes_Metric_Server/Kubernetes_Metric_Server.PNG){: width="600px"}

Kubernetes Metric Server는 Kubernetes Cluster를 구성하는 Node와 Pod의 Metric 정보를 수집한 다음, Metric 정보가 필요한 Kubernetes Component들에게 수집한 Metric 정보를 전달하는 역할을 수행한다. [그림 1]은 Kubernetes Metric Server와 Metric 수집 과정을 나타내고 있다. kubelet은 cAdvisor라고 불리는 Linux의 Cgroup을 기반으로하는 Node, Pod Metric Collector를 내장하고 있다. cAdvisor가 수집하는 Metric은 kubelet의 10250 Port의 /stat Path를 통해서 외부로 노출된다. 

Metric Server는 Kubernetes API Server로부터 Node에서 구동중인 kubelet의 접속 정보를 얻은 다음, kubelet으로 부터 Node, Pod의 Metric을 수집한다. 수집된 Metric은 Memory에 저장된다. 따라서 Metric Server가 재시작 되면 수집된 모든 Metric 정보는 사라진다. Metric Server는 Kubernetes의 **API Aggregation** 기능을 이용하여 Metric Server와 연결되어 있는 Metric Service를 metric.k8s.io API로 등록한다. 따라서 Metric Server의 Metric 정보가 필요한 Kubernetes Component들은 Metric Server 또는 Metric Service로부터 직접 Metric을 가져오지 않고, Kubernetes API Server를 통해서 가져온다.

현재 Metric Server의 Metric 정보를 이용하는 Kubernetes Component에는 Kubernetes Controller Manager에 존재하는 Horizontal Pod Autoscaler Controller와 kubectl top 명령어가 있다. [그림 1]에는 존재하지 않지만 별도의 Controller로 동작하는 Vertical Pod Autoscaler Controller도 Metric Server의 Metric을 이용한다. Metric Server는 Kubernetes Component들에게 Metric을 제공하는 용도로 개발되었으며, Kubernetes Cluster 외부로 Metric 정보를 노출시키는 용도로 개발되지는 않았다. Kubernetes Cluster의 Metric을 외부로 노출하기 위해서는 Prometheus같은 별도의 도구를 이용해야 한다.

Metric Server의 HA (High Availability)를 위해서 다수의 Metric Server를 구동하는 방법을 생각해 볼 수 있다. 하지만 Metric Server의 구조상 Metrc Server의 개수만큼 중복되어 Metric을 수집하는 구조이기 때문에, 다수의 Metric Server는 Kubernetes Cluster의 부하의 원인이 된다. 또한 다수의 Metric Server를 구동하여도 Metric을 가져가는 Kubernetes API는 하나의 Metric Server와 Connection을 맺고 Metric을 수집하기 때문에, 다수의 Metric Server를 구동하여도 부하 분산 효과는 얻을 수 없다. 이러한 특징들 때문에 현재도 HA를 위해서 다수의 Metric Server를 띄우는 방식이 올바른 방식인지를 [검토](https://github.com/kubernetes-sigs/metrics-server/issues/552)하고 있다.

#### 1.1. High Availability

### 2. 참조

* [https://github.com/kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server)
* [https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/resource-metrics-api.md](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/resource-metrics-api.md)
* [https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/metrics-server.md](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/metrics-server.md)
* [https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
* [https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/monitoring_architecture.md#architecture](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/monitoring_architecture.md#architecture)
* [https://github.com/kubernetes-sigs/metrics-server/issues/552](https://github.com/kubernetes-sigs/metrics-server/issues/552)
* [https://gruuuuu.github.io/cloud/monitoring-k8s1/#](https://gruuuuu.github.io/cloud/monitoring-k8s1/#)
