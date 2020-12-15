---
title: Kubernetes Pod with Linux OOM Killer
category: Theory, Analysis
date: 2020-12-18T12:00:00Z
lastmod: 2020-12-18T12:00:00Z
comment: true
adsense: true
---

Kubernetes Pod와 연관된 Linux Kernel의 OOM Killer의 동작을 정리한다.

### 1. Kubernetes Pod with Linux OOM Killer

Linux OOM Killer가 Pod의 Container를 강제로 죽이는 경우는 크게 2가지의 경우로 나눌수 있다. 첫번째 경우는 Pod의 Container가 Pod의 Manifest에 명시된 Container의 Memory Limit 값보다 더 많은 Memory 용량을 이용할 경우이다. 두번째 경우는 Node에 가용 가능한 Memory 용량이 부족할 경우이다. 각각의 경우를 정리한다.

#### 1.1. Memory Limit을 초과한 경우

{% highlight yaml %}
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "100Mi"
      limits:
        memory: "200Mi"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Pod Manifest Example with nginx Container Memory Limit</figcaption>
</figure>

[파일 1]은 Memory limit이 200MB로 설정된 nginx Container를 소유하고 있는 Pod의 Manifest 파일을 나타내고 있다. [파일 1]을 이용하여 Pod를 생성하면 nginx Container가 이용하는 Memory Cgroup의 Limit에는 200MB가 설정된다. 따라서 nginx Container는 200MB 이상의 Memory 용량을 이용하지 못한다.

{% highlight console %}
# dmesg
...
[ 1869.151779] Memory cgroup out of memory: Kill process 27881 (stress) score 1100 or sacrifice child
[ 1869.155654] Killed process 27881 (stress) total-vm:8192780kB, anon-rss:7152284kB, file-rss:4kB, shmem-rss:0kB
[ 1869.434078] oom_reaper: reaped process 27881 (stress), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] OOM Killer Log with Memory Cgroup</figcaption>
</figure>

만약 Node에 이용가능한 Swap Memory 공간이 존재한다면 nginx Container가 200MB 이상의 Memory 용량을 이용하는 경우 Swap Memory 공간을 이용하게 된다. 만약 Node에 이용가능한 Swap Memory 공간이 존재하지 않거나, Swap Memory가 Disable되어 있는 상태라면 nginx Container가 200MB 이상의 Memory 용량을 이용하는 경우 nginx Container는 Linux Kernel의 OOM Killer에 의해서 강제로 죽는다. [Shell 1]은 Memory Cgroup에 의해서 Pod의 Container가 죽을때의 Linux Kernel Log를 나타내고 있다.

#### 1.2. Node에 Memory가 부족한 경우

Kubernetes Cluster의 각 Node에서 동작하는 kubelet은 kubelet이 내장하고 있는 cAdvisor를 통해서 Node에서 동작하는 모든 Container의 Resource 사용량을 **Polling** 기반으로 Monitoring한다. cAdvisor는 Cgroup을 기반으로 모든 Container의 Resource 사용량을 측정하는 도구이다. 만약 Node의 모든 Container의 총 Memory 사용량이 Node의 Container에게 할당 가능한 Memory 용량을 초과하면, kubelet은 우선순위에 따라서 Pod Eviction 과정을 통해서 Pod를 삭제하여 Node의 Memory를 확보한다.

문제는 Node의 모든 Container의 총 Memory 사용량이 갑작스럽게 급증하게되면, kubelet이 cAdvisor Polling을 통해서 Node의 모든 Container의 Memory 사용량을 얻고 Pod Eviction을 수행하기전에 Linux Kernel의 OOM Killer에 의해서 임의의 Container가 강제로 죽을수 있다.

{% highlight console %}
# dmesg
...
[ 2826.282883] Out of memory: Kill process 4070 (stress) score 972 or sacrifice child
[ 2826.289059] Killed process 4070 (stress) total-vm:8192780kB, anon-rss:7231748kB, file-rss:0kB, shmem-rss:0kB
[ 2826.635944] oom_reaper: reaped process 4070 (stress), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] OOM Killer Log with Lack of Node Memory </figcaption>
</figure>

### 2. 참조

* [https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/](https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/)