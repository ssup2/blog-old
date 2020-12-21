---
title: Kubernetes Pod Eviction
category: Theory, Analysis
date: 2020-12-18T12:00:00Z
lastmod: 2020-12-18T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 Pod Eviction 기법을 정리한다.

### 1. Kubernetes Pod Eviction

Kubernetes는 Cluster의 Resource 부족시 우선순위가 낮은 Pod를 제거하여 Resource를 확보하는 Pod Eviction 기법을 제공한다. Pod Eviction 기법은 Kubernetes Scheduler가 수행하는 기법과 kubelet이 기법 2가지가 존재한다. Kubernetes Scheduler가 수행하는 Pod Eviction 기법은 Cluster Level의 기법이고, kubelet이 수행하는 Pod Eviction 기법은 Node Level의 기법이다.

#### 1.1. Kubernetes Scheduler의 Pod Eviction

Kubernetes Scheduler가 수행하는 Pod Eviction은 Cluster Level의 기법이다. Kubernetes Scheduler가 새로 생성된 Pod을 Scheduling 할때 Pod이 동작 가능한 Node가 존재하지 않는다면, Kubernetes Scheduler는 기존에 동작중인 Pod을 Eviction하여 제거하고 새로 생성된 Pod를 할당한다. 이러한 Pod의 교체 과정을 Preemption이라고 명칭한다.

Preemption이 발생하기 위해서는 새로 생성된 Pod의 Prority가 기존에 동작중인 Pod의 Priority가 높아야한다. 따라서 만약 동작중인 모든 Pod의 Priority가 새로 생성된 Pod의 Prority보다 높다면, 새로 생성된 Pod는 Scheduling되지 않고 Pending 상태를 유지한다. Preemption 과정을 통해서 제거되는 Pod는, 동작중인 Pod들 중에서 가장 낮은 Priority를 갖고 있어 선택되는 것은 아니다. 새로 생성되는 Pod의 Resource 요청량과 Node의 Resource 상태에 따라서는 가장 낮은 Priority를 갖고 있지 않아도 선택될 수 있다. 한가지 확실한 점은 새로 생성된 Pod의 Priority 보다는 낮은 Priority를 갖는 Pod이 Preemption을 통해서 제거된다는 점이다.

##### 1.1. Pod PriorityClass

{% highlight yaml %}
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: my-priority
value: 1000000
globalDefault: false
description: "My Priority Class"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Priority Class</figcaption>
</figure>

{% highlight yaml %}
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  priorityClassName: my-priority
  containers:
  - name: nginx
    image: nginx
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Nginx Pod with Priority Class</figcaption>
</figure>

Pod의 Priority는 Priority 정보를 저장하고 있는 Priority Class를 생성하고, 생성한 Priority Class를 Pod에 명시하는 형태로 설정한다. [파일 1]은 my-priority라는 이름을 갖는 Priority Class를 생성하기 위한 Manifest 파일을 나타내고 있고, [파일 2]는 [파일 1]을 통해 생성한 my-priority Priority Class를 Nginx Pod에 설정하는 과정을 나타낸다. 

Priority Class의 값이 높을수록 높은 Priority를 갖으며 최대값은 "10억"이다. Priority Class의 globalDefault는 해당 Priority Class를 Default Priority Class로 이용할지 설정하는 값이다. Default Priority Class가 존재하지 않는 상태에서 Priority Class가 명시되어 있지 않는 Pod의 Priority는 "0"으로 설정된다. Kubernetes는 Cluster 구성에 필수적인 Pod들을 보호하기 위해서 다음과 높은 Priority를 갖는 다음과 같은 Priority Class를 기본적으로 제공한다.

* system-cluster-critical : 2000000000 
* system-node-critical : 2000001000

#### 1.2. kubelet의 Pod Eviction

### 2. 참조

* [https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/)
* [https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/#evicting-end-user-pods](https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/#evicting-end-user-pods)