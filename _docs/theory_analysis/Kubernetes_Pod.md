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

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Component.PNG){: width="500px"}

Pod은 Kubernetes에서 이용하는 **Container 관리 단위**이다. Kubernetes는 Pod 단위로 Scheduling을 및 Load Balancing을 수행한다. 대부분의 Pod은 하나의 Container로 구성되어 있지만 다수의 Container로도 구성 될 수 있다. 이러한 Pod을 Multi-container Pod이라고 표현한다. Multi-container Pod의 Container들은 같은 Network Namespace와 IPC Namespace를 공유한다. 또한 같은 Volume(Storage)를 공유한다.

Multi-container Pod의 경우 서로 Tightly Coupling되어 주로 하나의 Main App과 Main App을 보조하는 보조 App의 구성으로 이루어진다. Web Server와 Web Server의 Log를 분석하는 Log Watcher가 예이다. App 단위로 Container를 구분하면 많은 관리 이점을 얻을 수 있다. Pod의 일부 App만 Upgrade가 필요하면 해당 App을 구동하는 Container만 다시 띄우면 된다. 또한 App 단위로 Container가 뜨면 App 죽었을때 Container도 죽기 때문에 외부에서 App의 상태도 파악하기 쉬워진다. 즉 Container 관리가 일반 App Process 관리 방식과 유사해지기 때문에 쉬운 관리가 가능하다.

물론 하나의 Container에서 여러개의 App을 구동하여 하나의 Pod에 하나의 Container만 띄우는 방식으로도 이용 할 수 있지만 위에서 언급한 장점들이 사라진다.

#### 1.1. (Linux) Namespace

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Namespace.PNG){: width="650px"}

위에서 언급한 것 처럼 Multi-container Pod의 Container들은 같은 Network Namespace와 IPC Namespace를 공유하는 특징을 갖는다. 이때 공유되는 Namespace는 사용자가 지정한 App이 동작하는 Container의 Namespace가 아니라, Kubernetes가 각 Pod마다 하나씩 생성하는 Pause Container의 Namespace이다. App Container의 Namespace가 아닌 Pause Container의 Namespace를 공유하는 이유에는 Namespace이 갖고 있는 특징 때문이다.

Namespace는 Clone() System Call을 통해 Process가 Fork되면서 같이 생성된다. Fork된 Process는 새로 생성된 Namespace에 속하게 된다. 이때 Fork되어 새로생긴 Process를 Namespace의 Init Process라고 한다. **Namespace의 생명주기는 Init Process와 동일하다.** Init Process가 죽으면 Namespace도 사라진다. 다시 말하면 Namespace가 유지되기 위해서는 반드시 Init Process가 존재해야 한다는 의미이다.

Init Process가 죽어 Namespace가 사라지면 Kernel은 Namespace에 속해있던 다른 Process들도 SIGKILL을 통해 죽인다. 따라서 Container의 Init Process가 죽으면 Namespace가 사라지고 Container의 모든 Process가 죽게된다. App Container의 Namepsace를 다른 App Container들이 공유해서 이용 할 경우, Namespace를 제공하는 App Container의 Init Process가 죽으면 같은 Pod에 속한 모든 Container(Process)도 죽게 된다.

Pause Container는 pause라는 binary를 Init Process로 이용하여 **pause()** System Call을 호출하고 Signal을 받을때까지 Blocking 상태가 된다. Pause Container는 Signal을 받기전 까지 죽지 않기 때문에 Pause Container를 통해 다른 App Container에게 안전하게 Namespace를 제공할 수 있다.

#### 1.2. Resource Manage (Cgroup)

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Cgroup.PNG){: width="650px"}

Pod의 Resource에는 **CPU**와 **Memory**가 있다. CPU와 Memory 둘다 Linux Kernel의 Cgroup을 이용하여 제어한다. 위의 그림은 Kubernetes가 Cgroup을 어떻게 구성하는지를 나타내고 있다. Pod A, Pod B, Pod C 처럼 Pod 단위의 Cgroup이 존재한다. 그리고 Pod Cgroup 아래에는 Pod에 속한 App Container의 Cgroup과 Pause Container의 Cgroup이 각각 존재한다.

Kubernetes는 Guaranteed, Burstable, BestEffort라는 3개의 QoS Class를 제공한다. Pod의 Resource 설정에 따라서 Pod의 QoS는 3개의 Class중 하나의 Class에 속하게 된다. Burstable, BestEffort Class에 속한 Pod은 해당 Cgroup 아래 속하게 된다. 그리고 Guaranteed Cgroup에 속한 Pod은 Kubernetes가 생성한 최상위 Cgroup인 kubepods Cgroup아래 속하게 된다. kubepods Cgroup은 cpu, memory, freezer 같은 모든 Cgroup 아래 각각 생성된다.

{% highlight YAML %}
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: db
    image: mysql
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: "password"
      resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: wp
    image: wordpress
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
{% endhighlight %}

위의 YAML 파일은 Pod의 설정 파일이다. Pod의 Resource 설정은 Pod 단위로 설정하는 기능은 없고, Pod에 속한 App Container 단위로 CPU, Memory 설정이 가능하다. CPU, Memory 설정값에는 **Request**와 **Limit** 두가지가 존재한다. Request는 Container가 언제나 이용할 수 있는 보장된 값을 의미하고, Limit는 Container가 이용할 수 있는 최대값을 나타낸다.

##### 1.2.1. CPU

CPU Resource 값은 **milicpu**라는 독특한 단위를 이용한다. 1cpu는 1000milicpu와 동일하다. 여기서 1cpu는 Container가 보는 CPU Core 1개의 Bandwidth를 의미한다. Container가 물리 머신에서 동작하면 1cpu는 물리 CPU Core 1개의 Bandwith를 의미하고, container가 VM에 올라가 동작하면 1cpu는 가상 CPU인 vCPU Core 1개의 Bandwidth를 의미한다

CPU Limit 값은 Linux에서 Process의 CPU Bandwidth를 제한하는데 이용되는 Cgroup의 CPU Quota를 설정하는데 이용된다. CPU Quota는 cfs_period_us와 cfs_quota_us라는 두개의 값으로 조작된다. cfs_period_us은 Quota의 주기를 의미하고 Default값은 100000이다. cfs_quota_us값은 Quota 주기 중에 얼만큼나 이용할지 설정하는 값이다. cfs_quota_us값도 100000으로 설정하면 아래와 같은 공식에 의해서 1cpu으로 CPU 사용량이 제한된다.

> cfs_quota_us / cfs_period_us = 100000 / 100000 = 1

2cpu만 이용하도록 제한한다면 cfs_quota_us 값을 200000으로 설정하면 된다. CPU 할당은 Container가 동작하는 (v)CPU의 개수에 의해 제한된다. 예를 들어 Container가 동작하는 Node에 4 (v)CPU만 있는데 Container에게 8cpu를 할당 할 수는 없다. 최대 4cpu까지만 할당 할 수 있다.

위와 같은 방식을 이해한다면 Kubernetes에서 CPU limit에 따라서 cfs_quota_us 값 어떻게 계산하여 넣는지 이해 할 수 있다. 만약 CPU limit를 500milicpu를 설정하였다면 아래와 같이 cfs_quota_us값이 계산된다.

> cfs_quota_us = (500 / 1000) * cfs_period_us = 0.5 * 100000 = 50000

CPU Request 값은 Linux에서 Process의 Scheduling 가중치를 주는데 이용되는 Cgroup의 CPU Weight를 설정하는데 이용된다. Process A는 1024 Weight를 갖고 있고, Process B는 512 Weight를 갖고 있다면 Process A는 Process B보다 2배 많이 CPU Bandwith를 이용할 수 있게 된다. CPU weight를 활용하면 Container가 필요한 최소의 CPU Bandwith를 확보 할 수 있다.

Cgroup에서 CPU Weigth는 shares라는 값으로 표현된다. CPU Request를 750milicpu로 설정하였다면 Kubernetes는 아래와 식을 이용하여 shares 값을 설정한다. 만약 CPU Request를 설정하지 않아 shares가 0이 나왔다면 최소 shares 값인 2로 설정한다.

> shares(weight) = (750 / 1000) * 1024 = 768

1000 milicpu를 갖고있는 Node에 750milicpu를 Container를 할당한다고 가정하자. shares는 위의 계산처럼 768이 된다. 이 Node에는 250milicpu만 남아있기 때문에 최대 250milicpu Container만 이 Node에 생성이 가능하다. 250milicpu Container의 share값은 256이다. share 값에 따라서 250 milicpu Container가 이 Node에 생성되더라도 처음 생성된 Container는 750milicpu를 보장받는다는 걸 알 수 있다. 이처럼 CPU Request 값은 CPU Weight와 Kubernets의 Pod Scheduling을 통해서 보장된다.

##### 1.2.2. Memory

Memory Resource 값은 일반적인 용량단위(Byte, MB, GB)를 이용한다. Memory Limit 값은 Linux에서 Process의 Memory 사용량을 제한하는데 이용되는 Cgroup의 Memory Limit 값을 설정하는데 이용된다. Container에 설정한 용량값 그대로 Memory Limit 값으로 이용된다. Memory Limit 값은 Container가 동작하는 Node의 Memory 값보다 클 수 없다. Memory Limit 값은 Cgroup의 limit_in_bytes라는 값으로 조작된다.

Memory Request 값은 Cgroup 설정에 이용되지 않고 오직 Kubernetes의 Pod Scheduling시에만 이용된다.

##### 1.2.3. QoS

위에서 언급한것 처럼 Kubernetes는 **Guaranteed, Burstable, BestEffort** 3개의 QoS Class를 제공한다. Pod에 속해있는 Container의 Resource 설정에 따라서 하나의 QoS Class로 분류되고, 관리된다.

* Guaranteed - 가장 우선순위가 높은 QoS Class로써 Pod이 사용할 Resource 보장에 초점을 두고 있다. Kubernetes는 Guaranteed Pod의 사용 Resource가 Limit 값 이상으로 커지지 경우에만 해당 Guaranteed Pod을 강제로 죽인다. Pod에 속한 모든 Container들의 CPU Limit, CPU Request 값이 같고 Memory Limit, Memory Request 값이 같으면 해당 Pod은 Guaranteed Class로 설정된다.

* Burstable - 중간 우선순위 QoS Class로써 Pod이 사용할 최소한의 Resource 제공에 초점을 두고 있다. Kubernetes는 Node에 Resource가 부족하고, BestEffort Pod이 없는 상태에서 Burstable Pod의 사용 Resource가 Request 값보다 큰 경우 해당 Burstable Pod을 강제로 죽일 수 있다. Resource Limit Guaranteed Class 조건을 만족시키지 않으면서 Pod에 속한 Container중 하나 이상의 Container의 Resource에 Request 값이 존재하면 Burstable 해당 Pod은 Burstable Class로 설정된다.

* BestEffort - 가장 우선순위가 낮은 QoS Class로써 Pod의 Resource 사용을 관여하지 않는다. 하지만 Kubernetes는 Node에 Resource가 부족한 경우 BestEffort Pod부터 강제로 죽이기 시작한다. Pod에 속한 모든 Container들의 모든 Resource가 설정되어있지 않으면 해당 Pod은 BestEffort Class로 설정된다.

#### 1.3. Manage

Kubernetes는 Pod 관리 및 제어를 위한 여러가지 기법을 제공하고 있다.

##### 1.3.1. Probe

Probe는 Kubernetes에서 Container의 정상 동작을 감시하기 위한 기법이다. 각 Node에 뜨는 kubelet Daemon은 주기적으로 Container마다 정의된 Handler를 호출하여 Container의 정상 동작을 감시한다. Handler는 Exec, TCP Socket, HTTP Get 크게 3가지의 Type이 존재한다.

* Exec - Container안에서 특정 명령어를 실행한다. 실행한 명령어의 Exit Code가 0이면 Container가 정상 상태라고 간주하고, 0이 아니면 정상 상태가 아니라고 간주한다.
* TCP Socket - Container가 특정 Port 번호를 열고 있으면 Container가 정상 상태라고 간주한다.
* HTTP Get - Container에게 HTTP Get Request를 날려 정상응답이 오면 Containe가 정상 상태라고 간주한다.

Probe에는 livenessProbe, readinessProbe 2가지 종류의 Probe가 존재한다. 각 Container마다 livenessProbe와 readinessProbe를 정의 할 수 있다.

* livenessProbe - Container가 Running 상태라는걸 감지하기 위한 Probe이다. livenessProbe의 결과가 실패라면 Kubernetes는 해당 Container를 삭제하고 Container의 Restart Policy에 따라서 해당 Container를 재시작하거나 그대로 놔둔다.
* readinessProbe - Container가 Service 요청을 받을 수 있는 상태인지를 감지하기 위한 Probe이다. readinessProbe의 결과가 실패라면 Kubernetes는 해당 Container를 갖고 있는 Pod의 IP 설정을 제거한다.

{% highlight YAML %}
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
{% endhighlight %}

위의 예제는 Exec Type의 livenessProbe를 이용한 Pod의 예제를 나타내고 있다. 위의 Pod은 /tmp/healthy 파일을 생성하고 30초 동안 대기하고 있다가 /tmp/healty 파일을 삭제하고 600초 동안 대기후 사라지는 Pod이다. livenessProbe는 cat 명령어를 통해 /tmp/healty 파일을 읽는 명령을 5초 주기로 수행한다. 30초동안은 /tmp/healty파일이 존재하기 때문에 Probe 결과는 성공으로 나오겠지만, 30초 이후에는 /tmp/healty 파일이 사라지기 때문에 Probe 결과는 실패가 된다.

##### 1.3.2. Init Container

Init Container는 Pod의 App Container가 동작하기 전에 Pod의 초기화, 외부 Service 대기 등을 위해 생성하는 Container이다. Init Container는 App Container와 동일하게 Pause Container의 Network Namespace와 IPC Namespace를 이용한다. 또한 Pod이 제공하는 Volume에도 똑같이 접근할 수 있다. 따라서 Init Container를 통해서 App Container가 이용하는 Network Routing Table을 변경하거나, Volume을 초기화 할 수 있다.

{% highlight YAML %}
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']
  - name: init-mydb
    image: busybox
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done;']
{% endhighlight %}

위의 예제는 2개의 Init Container를 이용하는 예제이다. 다수의 Init Container가 존재하는 경우 먼져 정의된 Init Container 부터 차례대로 실행한다. 앞의 Init Container가 정상 종료해야 다음 Init Container가 수행된다. 마지막 Init Container가 정상 종료된 뒤에야 App Container가 수행된다. 따라서 Init Container들은 반드시 초기화 진행 후 종료되는 Container야 한다. 위의 예제에서는 init-myservice -> init-mydb -> myapp-container 순으로 Container가 생성된다.

만약 Init Container가 정상 종료되지 않으면 Pod의 Restart 정책에 따라 해당 Pod을 재시작하여 Init Container를 다시 수행하거나, 그대로 놔둔다.

### 2. 참조

* [https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
* [https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/](https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/)
* [https://medium.com/google-cloud/quality-of-service-class-qos-in-kubernetes-bb76a89eb2c6](https://medium.com/google-cloud/quality-of-service-class-qos-in-kubernetes-bb76a89eb2c6)
