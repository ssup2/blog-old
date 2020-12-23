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

Kubernetes Scheduler가 수행하는 Pod Eviction 기법은 Cluster Level의 기법이다. Kubernetes Scheduler가 새로 생성된 Pod을 Scheduling 할때 Pod이 동작 가능한 Node가 존재하지 않는다면, Kubernetes Scheduler는 기존에 동작중인 Pod을 Eviction하여 제거하고 새로 생성된 Pod를 할당한다. 이러한 Pod의 교체 과정을 Preemption이라고 명칭한다.

Preemption이 발생하기 위해서는 새로 생성된 Pod의 Prority가 기존에 동작중인 Pod의 Priority가 높아야한다. 따라서 만약 동작중인 모든 Pod의 Priority가 새로 생성된 Pod의 Prority보다 높다면, 새로 생성된 Pod는 Scheduling되지 않고 Pending 상태를 유지한다. Preemption 과정을 통해서 제거되는 Pod는, 동작중인 Pod들 중에서 가장 낮은 Priority를 갖고 있어 선택되는 것은 아니다. 새로 생성되는 Pod의 Resource 요청량과 Node의 Resource 상태에 따라서는 가장 낮은 Priority를 갖고 있지 않아도 선택될 수 있다. 한가지 확실한 점은 새로 생성된 Pod의 Priority 보다는 낮은 Priority를 갖는 Pod이 Preemption을 통해서 제거된다는 점이다.

##### 1.1.1. Pod PriorityClass

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

kubelet이 수행하는 Pod Eviction 기법은 Node Level의 기법이다. Kubernetes Scheduler에 의해서 Scheduling되어 특정 Node에서 동작하던 Pod는 여러가지 원인에 의해서 Node의 Resource 부족이 발생하게 되면 Kubelet에 의해서 Eviction 되어 강제로 제거될 수 있다. kubelet의 Pod Eviction은 Node의 CPU, Memory Resource가 부족할 때와 Node의 Disk 또는 inode가 부족할 경우 2가지로 나누어 생각할 수 있다.

##### 1.2.1. CPU, Memory 부족시

Pod(Container)는 CPU, Memory Resource에 대해서 Request 값과 Limit 값을 갖는다. Request는 Kubernetes Scheduler가 Pod를 Scheduling시 이용하는 값이고 Limit 값은 Pod이 이용할 수 있는 최대 값을 의미한다. 따라서 Pod들은 Request 값보다 더 많은 CPU, Memory Resource를 이용할 수 있다는 의미이다. Kubernetes Scheduler는 Request 값을 기준으로 Pod Scheduling을 수행하기 때문에 kubelet은 CPU, Memory Resource 부족시 Request 값보다 실제로 더 많이 CPU, Memory Resource를 이용하는 Pod들을 Eviction 대상으로 선정한다.

Pod에 Request 값이 설정되어 있지 않다면 Kubernetes는 Request 값을 0으로 간주한다. 따라서 CPU, Memory 둘다 Request 값을 설정하지 않는 BestEffort QoS Pod는 항상 kubelet의 Eviction 대상이 된다. Burstable QoS Pod의 경우에는 CPU, Memory 둘다 Request 값을 설정하고 실제 CPU, Memory Resource 사용량이 Request 값보다 작은 경우에는 kubelet의 Eviction 대상에서 벗어나지만, 그외의 경우에는 kubelet의 Eviction 대상이 된다. CPU, Memory Request와 Limit이 동일한 Guaranteed QoS Pod는 언제나 kubelet의 Eviction 대상에서 벗어난다.

kubelet은 Eviction 대상이 된 Pod 중에서 Priority Class에 의해서 낮은 Priority를 갖는 Pod을 먼저 제거한다. 동일한 Priority를 갖는 Pod들이 있다면 Request 값보다 초과해서 Resource를 많이 이용하는 Pod부터 먼저 제거한다. kubelet은 내장하고 있는 CAdvisor를 통해서 Pod의 실제 CPU, Memory Resource 사용량을 Polling하여 Monitoring하고 있다. Polling 시간 간격사이에 Memory 사용량이 갑작스럽게 증가하여 kubelet이 CAdvisor로부터 Node의 Memory 상태를 얻지 못하여 Pod Eviction을 수행하지 못하는 경우에는, Linux Kernel의 OOM Killer에 의해서 Pod는 죽게된다.

##### 1.2.2. Disk, inode 부족시

kubelet은 Disk 용량 부족시 낮은 QoS를 갖는 Pod부터 Eviction을 통해 제거한다. 동일한 QoS를 갖는 Pod 중에서는 많은 Disk를 용량을 사용하는 Pod부터 제거한다. kubelet은 inode 부족시에 낮은 QoS를 갖는 임이의 Pod부터 Eviction을 통해 제거한다.

### 2. 참조

* [https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/)
* [https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/#evicting-end-user-pods](https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/#evicting-end-user-pods)
* [https://m.blog.naver.com/PostView.nhn?blogId=alice_k106&logNo=221676471427&referrerCode=0&searchKeyword=Eviction](https://m.blog.naver.com/PostView.nhn?blogId=alice_k106&logNo=221676471427&referrerCode=0&searchKeyword=Eviction)
* [https://stackoverflow.com/questions/56486023/does-kubernetes-consider-the-current-memory-usage-when-scheduling-pods](https://stackoverflow.com/questions/56486023/does-kubernetes-consider-the-current-memory-usage-when-scheduling-pods)