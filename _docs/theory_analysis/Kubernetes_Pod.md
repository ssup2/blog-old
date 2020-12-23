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

![[그림 1] Kubernetes Pod]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Component.PNG){: width="500px"}

Pod은 Kubernetes에서 이용하는 **Container 관리 단위**이다. Kubernetes는 Pod 단위로 Scheduling을 및 Load Balancing을 수행한다. 대부분의 Pod은 하나의 Container로 구성되어 있지만 다수의 Container로도 구성 될 수 있다. 이러한 Pod을 Multi-container Pod이라고 표현한다. Multi-container Pod의 Container들은 같은 Network Namespace와 IPC Namespace를 공유한다. 또한 같은 Volume(Storage)를 공유한다. 

Pod의 각 Container는 대부분 하나의 App만을 구동시킨다. Container에 하나의 App만을 구동시키면 App이 죽었을 경우 Container도 제거된다. 즉 App의 Life Time과 Container의 Life Time이 일치하게 된다. 또한 App의 Log를 stdout/stderr으로 출력하게 설정하면, Container 외부에서도 App의 Log를 쉽게 파악할 수 있게 된다. 물론 하나의 Container에서 다수의 App을 구동하여 하나의 Pod에 하나의 Container만을 띄우는 방식으로도 구성할 수 있지만, 위에서 언급한 장점들이 사라진다.

Multi-container Pod의 각 Container안에서 동작하는 App들은 일반적으로 서로 Tightly Coupling되어 동작한다. 주로 하나의 Main App과 Main App을 보조하는 보조 App의 구성으로 이루어진다. Web Server와 Web Server의 Log를 분석하는 Log Watcher가 대표적인 예이다.

#### 1.1. (Linux) Namespace

![[그림 2] Kubernetes Pod Namespace]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Namespace.PNG){: width="650px"}

위에서 언급한 것 처럼 Multi-container Pod의 Container들은 같은 Network Namespace와 IPC Namespace를 공유하는 특징을 갖는다. 이때 공유되는 Namespace는 App Container의 Namespace가 아니라, Kubernetes가 각 Pod마다 하나씩 생성하는 Pause Container의 Namespace이다. App Container의 Namespace를 이용하지 않는 이유는, App Container의 불안전성 때문이다. App Container의 App이 죽으면 App Container가 제거되고, App Container의 Namespace도 같이 제거된다. Kubernetes는 App Container의 App이 언제 죽을지 알 수 없기 때문에, 언제 App Container의 Namespace가 제거 될지도 알 수 없다. 따라서 Kubernetes는 App Container의 Namespace를 Pod의 공유 Namespace로 이용하지 않는다.

Pause Container는 pause라고 불리는 Binary를 구동한다. pause Binary은 **pause()** System Call을 호출하고 Signal을 받을때까지 Blocking 상태가 된다. 즉 pause Binary은 Signal을 받기전 까지는 죽지 않기 때문에, Pause Container는 안정적으로 존재할 수 있게 된다. 따라서 Kubernetes는 안정적인 Pause Container의 Namespace를 Pod의 공유 Namespace로 이용한다.

#### 1.2. Resource Manage (Cgroup)

![[그림 3] Kubernetes Pod Cgroup ]({{site.baseurl}}/images/theory_analysis/Kubernetes_Pod/Pod_Cgroup.PNG){: width="650px"}

Pod의 Resource에는 **CPU**와 **Memory**가 있다. CPU와 Memory 둘다 Linux Kernel의 Cgroup을 이용하여 제어한다. [그림 3]은 Kubernetes가 Cgroup을 어떻게 구성하는지를 나타내고 있다. Pod A, Pod B, Pod C 처럼 Pod 단위의 Cgroup이 존재한다. 그리고 Pod Cgroup 아래에는 Pod에 속한 App Container의 Cgroup과 Pause Container의 Cgroup이 각각 존재한다.

Kubernetes는 Guaranteed, Burstable, BestEffort라는 3개의 QoS Class를 제공한다. Pod의 Resource 설정에 따라서 Pod의 QoS는 3개의 Class중 하나의 Class에 속하게 된다. Burstable, BestEffort Class에 속한 Pod은 해당 Cgroup 아래 속하게 된다. 그리고 Guaranteed Cgroup에 속한 Pod은 Kubernetes가 생성한 최상위 Cgroup인 kubepods Cgroup아래 속하게 된다. kubepods Cgroup은 cpu, memory, freezer 같은 모든 Cgroup 아래 각각 생성된다.

{% highlight yaml %}
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
<figure>
<figcaption class="caption">[파일 1] Kubernetes Pod 예제</figcaption>
</figure>

[파일 1]은 Kubernetes Pod의 설정 파일이다. Pod의 Resource 설정은 Pod 단위로 설정하는 기능은 없고, Pod에 속한 App Container 단위로 CPU, Memory 설정이 가능하다. CPU, Memory 설정값에는 **Request**와 **Limit** 두가지가 존재한다. Request는 Container가 이용할 수 있는 보장된 값을 의미하고, Limit는 Container가 이용할 수 있는 최대값을 나타낸다.

##### 1.2.1. CPU

CPU Resource 값은 **milicpu**라는 독특한 단위를 이용한다. 1000milicpu는 1cpu와 동일하다. 여기서 1cpu는 Container가 보는 CPU Core 1개의 Bandwidth를 의미한다. Container가 물리 머신에서 동작하면 1cpu는 물리 CPU Core 1개의 Bandwith를 의미하고, container가 VM에 올라가 동작하면 1cpu는 가상 CPU인 vCPU Core 1개의 Bandwidth를 의미한다

{: .newline }
> (cfs_quota_us / cfs_period_us) * 1000 = Limit milicpu
> (150000 / 100000) * 1000 = 1500 milicpu
<figure>
<figcaption class="caption">[공식 1] CPU Quota 계산 01</figcaption>
</figure>

{: .newline }
> (milicpu / 1000) * cfs_period_us = cfs_quota_us
> 0.5 * 100000 = 50000
<figure>
<figcaption class="caption">[공식 2] CPU Quota 계산 02</figcaption>
</figure>

**CPU Limit** 값은 Linux에서 Process의 CPU Bandwidth를 제한하는데 이용되는 Cgroup의 CPU Quota를 설정하는데 이용된다. CPU Quota는 cfs_period_us와 cfs_quota_us라는 두개의 값으로 조작된다. cfs_period_us은 Quota 주기를 의미하고 Default 값은 100000이다. cfs_quota_us은 Quota 주기동간 최대 얼마만큼 CPU를 이용할지 설정하는 값이다. cfs_quota_us값을 150000으로 설정하면 [공식 1]에 의해서 Container는 최대 1500milicpu만 이용 할 수 있다. 

설정할 수 있는 최대 CPU Limit 값은 Container가 동작하는 (v)CPU의 개수에 의해 제한된다. Container가 동작하는 Node에 4 (v)CPU만 있다면 Container에게는 최대 4000milicpu까지만 할당할 수 있다. [공식 1]을 이용하여 [공식 2]를 만들 수 있다. [공식 2]는 Kubernetes에서 CPU limit에 따라서 cfs_quota_us 값을 계산하는 방법을 나타낸다. cfs_period_us 값은 무조건 Default 값인 100000을 이용한다. 만약 CPU limit를 500milicpu를 설정하였다면 [공식 2]에 의해서 cfs_quota_us값은 50000이 된다.

{: .newline }
> (Request milicpu / Node Total milicpu) * 1024 = shares
> Contaier A : (1500 / 2000) * 1024 = 768
> Contaier B : (500 / 2000) * 1024 = 256
<figure>
<figcaption class="caption">[공식 3] CPU Weight 계산</figcaption>
</figure>

**CPU Request** 값은 Linux에서 Process의 Scheduling 가중치를 주는데 이용되는 Cgroup의 CPU Weight를 설정하는데 이용된다. Cgroup에서 CPU Weigth는 shares라는 값으로 조작된다. Process A는 1024 shares를 갖고 있고, Process B는 512 shares를 갖고 있다면 Process A는 Process B보다 2배 많은 CPU Bandwith를 이용할 수 있게 된다. CPU Weight와 Kubernets의 Pod Scheduling을 이용하면 Container가 요구하는 CPU Request 값을 Container에게 제공할 수 있다.

2000 milicpu (2 CPU)를 갖고 있는 Node에 Container A는 1500 milicpu를 Request로 요청하고 Container B는 500 milicpu를 Request로 요청한다고 가정한다면, Container A와 Container B의 Weight의 비율은 3:1만 충족시키면된다. 비율을 적용하는 기준값은 shares의 기본 값인 1024를 이용한다. 따라서 Container A의 shares 값은 768이 되고 Container B의 shares 값은 256이 된다. shares 값은 [공식 3]을 통해서 계산할 수 있다.

##### 1.2.2. Memory

Memory Resource 값은 일반적인 용량단위(Byte, MB, GB)를 이용한다. **Memory Limit** 값은 Linux에서 Process의 Memory 사용량을 제한하는데 이용되는 Cgroup의 Memory Limit 값을 설정하는데 이용된다. Container에 설정한 용량값 그대로 Memory Limit 값으로 이용된다. Memory Limit 값은 Container가 동작하는 Node의 Memory 값보다 클 수 없다. Memory Limit 값은 Cgroup의 limit_in_bytes라는 값으로 조작된다. **Memory Request** 값은 Cgroup 설정에 이용되지 않고 오직 Kubernetes의 Pod Scheduling시 이용된다.

##### 1.2.3. QoS

위에서 언급한것 처럼 Kubernetes는 **Guaranteed, Burstable, BestEffort** 3개의 QoS Class를 제공한다. Pod에 속해있는 Container의 Resource 설정에 따라서 하나의 QoS Class로 분류되고, 관리된다.

* Guaranteed : 가장 우선순위가 높은 QoS Class로써 Pod이 사용할 Resource 보장에 초점을 두고 있다. Kubernetes는 Guaranteed Pod의 사용 Resource가 Limit 값 이상으로 커지지 경우에만 해당 Guaranteed Pod을 강제로 죽인다. Pod에 속한 모든 Container들의 CPU Limit, CPU Request 값이 같고 Memory Limit, Memory Request 값이 같으면 해당 Pod은 Guaranteed Class로 설정된다. Request 값을 설정하지 않고 Limit 값만 설정하는 경우 Kubernetes는 기본적으로 Request 값을 Limit 값과 일치시키기 때문에, CPU Limit, Memory Limit 값만 설정되어 있어도 Guaranteed Pod이 된다.

* Burstable : 중간 우선순위 QoS Class로써 Pod이 사용할 최소한의 Resource 제공에 초점을 두고 있다. Kubernetes는 Node에 Resource가 부족하고, BestEffort Pod이 없는 상태에서 Burstable Pod의 사용 Resource가 Request 값보다 큰 경우 해당 Burstable Pod을 강제로 죽일 수 있다. Resource Limit Guaranteed Class 조건을 만족시키지 않으면서 Pod에 속한 Container중 하나 이상의 Container의 Resource에 Request 값이 존재하면 Burstable 해당 Pod은 Burstable Class로 설정된다.

* BestEffort : 가장 우선순위가 낮은 QoS Class로써 Pod의 Resource 사용을 관여하지 않는다. 하지만 Kubernetes는 Node에 Resource가 부족한 경우 BestEffort Pod부터 강제로 죽이기 시작한다. Pod에 속한 모든 Container들의 모든 Resource가 설정되어있지 않으면 해당 Pod은 BestEffort Class로 설정된다.

#### 1.3. Manage

Kubernetes는 Pod 관리 및 제어를 위한 여러가지 기법을 제공하고 있다.

##### 1.3.1. Probe

Probe는 Kubernetes에서 Container의 정상 동작을 감시하기 위한 기법이다. 각 Node에 뜨는 kubelet Daemon은 주기적으로 Container마다 정의된 Handler를 호출하여 Container의 정상 동작을 감시한다. Handler는 Exec, TCP Socket, HTTP Get 크게 3가지의 Type이 존재한다.

* Exec : Container안에서 특정 명령어를 실행한다. 실행한 명령어의 Exit Code가 0이면 Container가 정상 상태라고 간주하고, 0이 아니면 정상 상태가 아니라고 간주한다.
* TCP Socket : Container가 특정 Port 번호를 열고 있으면 Container가 정상 상태라고 간주한다.
* HTTP Get : Container에게 HTTP Get Request를 날려 정상응답이 오면 Containe가 정상 상태라고 간주한다.

Probe에는 livenessProbe, readinessProbe 2가지 종류의 Probe가 존재한다. 각 Container마다 livenessProbe와 readinessProbe를 정의 할 수 있다.

* livenessProbe : Container가 Running 상태라는걸 감지하기 위한 Probe이다. livenessProbe의 결과가 실패라면 Kubernetes는 해당 Container를 삭제하고 Container의 Restart Policy에 따라서 해당 Container를 재시작하거나 그대로 놔둔다.
* readinessProbe : Container가 Service 요청을 받을 수 있는 상태인지를 감지하기 위한 Probe이다. readinessProbe의 결과가 실패라면 Kubernetes는 해당 Container를 갖고 있는 Pod의 IP 설정을 제거하여, 해당 Pod이 Service를 제공하지 못하도록 한다.

<figure>
{% highlight yaml %}
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
<figcaption class="caption">[파일 2] Kubernetes Pod의 livenessProbe 예제</figcaption>
</figure>

[파일 2]는 Exec Type의 livenessProbe를 이용한 Pod의 예제를 나타내고 있다. [파일 2]는 /tmp/healthy 파일을 생성하고 30초 동안 대기하고 있다가 /tmp/healty 파일을 삭제하고 600초 동안 대기후 사라지는 Pod을 나타낸다. livenessProbe는 cat 명령어를 통해 /tmp/healty 파일을 읽는 명령을 5초 주기로 수행한다. 30초동안은 /tmp/healty 파일이 존재하기 때문에 Probe 결과는 성공으로 나오겠지만, 30초 이후에는 /tmp/healty 파일이 사라지기 때문에 Probe 결과는 실패가 된다.

##### 1.3.2. Init Container

Init Container는 Pod의 App Container가 동작하기 전에 Pod의 초기화, 외부 Service 대기 등을 위해 생성하는 Container이다. Init Container는 App Container와 동일하게 Pause Container의 Network Namespace와 IPC Namespace를 이용한다. 또한 Pod이 제공하는 Volume에도 똑같이 접근할 수 있다. 따라서 Init Container를 통해서 App Container가 이용하는 Network Routing Table을 변경하거나, Volume을 초기화 할 수 있다.

<figure>
{% highlight yaml %}
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
<figcaption class="caption">[파일 3] Kubernetes Pod의 Init Container 에제</figcaption>
</figure>

[파일 3]은 2개의 Init Container를 이용하는 예제이다. 다수의 Init Container가 존재하는 경우 먼져 정의된 Init Container 부터 차례대로 실행한다. 앞의 Init Container가 정상 종료해야 다음 Init Container가 수행된다. 마지막 Init Container가 정상 종료된 뒤에야 App Container가 수행된다. 따라서 Init Container들은 반드시 초기화 진행 후 종료되는 Container야 한다. [파일 3]에서는 init-myservice -> init-mydb -> myapp-container 순으로 Container가 생성된다. 만약 Init Container가 정상 종료되지 않으면 Pod의 Restart 정책에 따라 해당 Pod을 재시작하여 Init Container를 다시 수행하거나, 그대로 놔둔다.

##### 1.3.3. Container Life Cycle Hook

<figure>
{% highlight yaml %}
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
  - name: lifecycle-demo-container
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo test"]
      preStop:
        httpGet:
          path: "/test"
          port: 8080
{% endhighlight %}
<figcaption class="caption">[파일 4] Kubernetes Container의 Life Cycle Hook 에제</figcaption>
</figure>

Container Life Cycle Hook은 각 Container의 생명주기 Event에 따라서 특정 동작을 수행할 수 있게 만든다. [파일 4]는 Container Life Cycle Hook을 나타내고 있다. 현재 Kubernetes는 postStart Hook과 preStop Hook을 제공하고 있다. postStart Hook, preStop Hook 둘다 Parameter로 특정 Data를 전달하는 기능은 제공하지 않는다.

* postStart Hook : Container의 Init Process (Command) 및 Namespace를 생성한 뒤 수행하는 Hook이다. Container의 Init Process가 정상동작을 하더라도 Container의 postStart Hook이 제대로 실행 완료되지 않으면, 해당 Container는 Running 상태로 바뀌지 않는다. Container의 postStart Hook이 실패하면 Kubernetes는 해당 Container를 강제로 죽인다.

* preStop Hook : Container를 정지하기전에 수행하는 Hook이다. preStop Hook이 정상적으로 수행완료 된 이후에야 Container 삭제를 시도한다. 따라서 Container의 preStop Script가 종료되지 않으면 해당 Container는 삭제할 수 없다. 이러한 문제를 해결하기 위해서 Kubernetes는 terminationGracePeriodSeconds 옵션을 통해서 preStop Hook의 Timeout 시간을 지정할 수 있다. Container의 preStop Hook이 실패하거나, Timeout으로 인해 강제로 종료되면 Kubernetes는 해당 Container를 강제로 죽인다.

Hook Handler Type에는 Exec, HTTP를 제공한다.

* Exec : Container의 Namespace 안에서 명령어를 수행한다. 명령어의 Exit Code 값이 0인 경우 성공으로 간주하고 0이 아닌경우에는 실패로 간주한다. [파일 4]의 postStart Hook이 Exec Type의 Hook Handler이다.

* HTTP : Container에게 HTTP Request를 전달한다. HTTP의 결과가 200번대라면 성공으로 간주하고 아닌 경우에는 실패로 간주한다. [파일 4]의 preStop Hook이 HTTP Type의 Hook Handler이다.

### 2. 참조

* [https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
* [https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/](https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/)
* [https://medium.com/google-cloud/quality-of-service-class-qos-in-kubernetes-bb76a89eb2c6](https://medium.com/google-cloud/quality-of-service-class-qos-in-kubernetes-bb76a89eb2c6)
