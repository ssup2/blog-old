---
title: Kubernetes Pod
category: Theory, Analysis
date: 2018-06-05T12:00:00Z
lastmod: 2018-06-05T12:00:00Z
comment: true
adsense: true
---

Kubernetes Pod을 분석한다.

### 1. Pod

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Component.PNG){: width="600px"}

Pod은 Kubernetes에서 이용하는 **Container 관리 단위**이다. Kubernetes는 Pod 단위로 Scheduling을 및 Load Balancing을 수행한다. 대부분의 Pod은 하나의 Container로 구성되어 있지만 다수의 Container로도 구성 될 수 있다. 이러한 Pod을 Multi-container Pod이라고 표현한다. Multi-container Pod의 Container들은 같은 Network Namespace와 IPC Namespace를 공유한다. 또한 같은 Volume(Storage)를 공유한다.

Multi-container Pod의 경우 서로 Tightly Coupling되어 주로 하나의 Main App과 Main App을 보조하는 보조 App의 구성으로 이루어진다. Web Server와 Web Server의 Log를 분석하는 Log Watcher가 예이다. App 단위로 Container를 구분하면 많은 관리 이점을 얻을 수 있다. Pod의 일부 App만 Upgrade가 필요하면 해당 App을 구동하는 Container만 다시 띄우면 된다. 또한 App 단위로 Container가 뜨면 App 죽었을때 Container도 죽기 때문에 외부에서 App의 상태도 파악하기 쉬워진다. 즉 Container 관리가 일반 App Process 관리 방식과 유사해지기 때문에 쉬운 관리가 가능하다.

물론 하나의 Container에서 여러개의 App을 구동하여 하나의 Pod에 하나의 Container만 띄우는 방식으로도 이용 할 수 있지만 위에서 언급한 장점들이 사라진다.

#### 1.1. (Linux) Namespace

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Namespace.PNG){: width="600px"}

위에서 언급한 것 처럼 Multi-container Pod의 Container들은 같은 Network Namespace와 IPC Namespace를 공유하는 특징을 갖는다. 이때 공유되는 Namespace는 사용자가 지정한 App이 동작하는 Container의 Namespace가 아니라, Kubernetes가 각 Pod마다 하나씩 생성하는 Pause Container의 Namespace이다. App Container의 Namespace가 아닌 Pause Container의 Namespace를 공유하는 이유에는 Namespace이 갖고 있는 특징 때문이다.

Namespace는 Clone() System Call을 통해 Process가 Fork되면서 같이 생성된다. Fork된 Process는 새로 생성된 Namespace에 속하게 된다. 이때 Fork되어 새로생긴 Process를 Namespace의 Init Process라고 한다. **Namespace의 생명주기는 Init Process와 동일하다.** Init Process가 죽으면 Namespace도 사라진다. 다시 말하면 Namespace가 유지되기 위해서는 반드시 Init Process가 존재해야 한다는 의미이다.

Init Process가 죽어 Namespace가 사라지면 Kernel은 Namespace에 속해있던 다른 Process들도 SIGKILL을 통해 죽인다. 따라서 Container의 Init Process가 죽으면 Namespace가 사라지고 Container의 모든 Process가 죽게된다. App Container의 Namepsace를 다른 App Container들이 공유해서 이용 할 경우, Namespace를 제공하는 App Container의 Init Process가 죽으면 같은 Pod에 속한 모든 Container(Process)도 죽게 된다.

Pause Container는 pause라는 binary를 Init Process로 이용하여 **pause()** System Call을 호출하고 Signal을 받을때까지 Blocking 상태가 된다. Pause Container는 Signal을 받기전 까지 죽지 않기 때문에 다른 App Container에게 안전하게 Namespace를 제공할 수 있다.

#### 1.2. Resource Manage (Cgroup)

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Cgroup.PNG){: width="600px"}

##### 1.2.1. CPU

##### 1.2.2. Memory

#### 1.3. Life Cycle

### 2. 참조

* [https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
* [https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/](https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/)
