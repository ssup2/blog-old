---
title: Docker Component
category: Theory, Analysis
date: 2020-05-20T12:00:00Z
lastmod: 2020-05-20T12:00:00Z
comment: true
adsense: true
---

Docker의 구성요소를 분석한다.

### 1. Docker Component

![[그림 1] Docker Component]({{site.baseurl}}/images/theory_analysis/Docker_Component/Docker_Component.PNG)

[그림 1]은 Docker 19.02 Version의 구성요소를 나타내고 있다. 구성 요소로는 docker, dockerd, docker-proxy, containerd, containerd-shim, runc로 구성되어 있다. 각 구성요소의 역할은 다음과 같다.

#### 1.1. docker (Docker Client)

docker는 Docker Daemon이 제공하는 HTTP 기반 REST API를 이용하여 Container를 제어하는 Docker Client 역할을 수행한다.

#### 1.2. dockerd (Docker Daemon)

Docker Daemon은 HTTP 기반 REST API를 제공하여 Docker Client가 Container를 제어하고 이용할 수 있게하는 Docker Daemon의 역할을 수행한다. Docker Client로부터 받은 요청중에서 대부분은 dockerd가 구동시킨 containerd에게 처리를 위임하고, 일부 요청만 직접 처리한다. dockerd는 containerd 구동, Docker Image Build (Dockerfile), Container Network 설정 (Bridge, iptables), Container Log 기록, docker-proxy 구동 등의 역할을 수행한다.

Docker Daemon의 REST API는 기본적으로 "/var/run/docker.sock" 파일의 Unix Domain Socket을 통해서 제공되며 Docker Daemon의 Opiton을 변경을 통해서 TCP Socket을 이용하도록 변경할 수도 있다.

#### 1.3. docker-proxy (Docker Proxy)

docker-proxy는 Node 외부에서 Container안으로 Packet을 Forwarding 해주는 Proxy Server 역할을 수행한다. docker-proxy는 Container 구동시 반드시 필요한 구성 요소는 아니다. Linux에서 동작하는 dockerd는 Linux Netfilter Framework를 기반으로 동작하는 iptables를 이용하여 Container로 Packet을 Forwarding 하기 때문이다. 하지만 dockerd가 동작하는 모든 환경에서 iptables를 이용할수 있는것은 아니기 때문에, docker-proxy의 이용은 환경에 따라 선택되어야 한다. dockerd-proxy의 이용 유무는 docker-proxy를 실행하는 dockerd의 설정에 따라서 결정된다.

dockerd는 docker-proxy는 Container의 Port Forwarding Option이 추가될 때마다 해당 Port를 담당하는 docker-proxy를 추가로  실행한다. 예를 들어 A Container에 10, 20 Port를 Port Forwarding 설정하고, B Container에 30, 40 Port를 Port Forwarding 하도록 설정한다면 docker-proxy는 총 4개가 동작한다. 다수의 docker-proxy 구동은 Node에도 부담될수 있기 때문에 dockerd가 Linux의 iptables가 이용가능한 환경이라면 docker-proxy를 이용 안하도록 dockerd를 설정하는 것이 좋다.

#### 1.4. containerd

containerd는 OCI (Open Container Initiative) Runtime Spec을 준수하는 dockerd에 요청에 따라서 config.json (Container Config) 파일을 생성하고 containerd-shim, runc를 이용하여 container를 생성하는 Daemon 역할을 수행한다. containerd는 또한 Node에 Container 구동에 필요한 Container Image가 존재하지 않는다면 OCI Image Spec을 기반으로 Container Image Server로부터 Container Image를 Pull 하는 역할도 수행한다. Container Snapshot 기능도 containerd가 수행한다.

containerd는 기본적으로 기본적으로 "/run/containerd/containerd.sock"의 Unix Domain Socket을 통해서 gRPC 기반 REST API를 제공한다. containerd는 ctr이라고 불리는 containerd 전용 CLI Client를 제공하기도 한다. containerd는 Namespace 기능을 제공하는데 Docker는 "moby"라는 이름의 Namespace에 모든 Container들을 생성한다.

#### 1.5. runc

runc는 containerd가 생성한 config.json (Container Config) 파일을 통해서 Container를 실제로 생성하는 역할을 수행한다. config.json은 OCI Runtime Spec을 기반으로 작성되어 있다. runc는 containerd가 아닌 containerd-shim으로부터 실행되는데, runc의 stdin/out/err는 runc를 실행한 Process의 stdin/out/err를 그대로 이용한다. 따라서 runc의 stdin/out/err는 containerd-shim과 동일하다. runc는 Container를 생성한뒤 Container가 종료될때까지 대기하지 않고 바로 종료되는 특징을 갖고 있다.

#### 1.6. containerd-shim

containerd-shim은 containerd와 runc사이에서 각 Container당 하나씩 동작하면서 Container의 stdin/out/err를 Named Pipe를 통해서 다른 Process에서 접근할수 있게 하고, Container Init Process (Container의 1번 Process)의 종료시 ExitCode를 containerd의 "/run/containerd/containerd.sock" Unix Domain Socket을 통해서 containerd에게 전달하는 역할을 수행한다. containerd-shim이 필요한 이유는 containerd는 언제든지 재시작 될수 있고 runc는 Container를 생성만하고 종료되기 때문에, Container의 stdin/out/err 및 Container Init Process의 Exit Code를 담당하는 Process가 필요하기 때문이다.

containerd-shim은 "@/containerd-shim/moby/[containerID]/shim.sock@" 이름의 Unix Domain Socket을 통해 전송되는 containerd의 명령어 따라서, Container Init Process의 상태를 Check하는 동작과 Container 내부에 별도의 Process를 띄우는 exec 동작도 수행한다. containerd-shim의 Unix Domain Socket은 기본적으로 별도의 파일이 존재하지 않는 형태로 동작하며 containerd-shim의 Option을 통해서 특정 경로에 Unix Domain Socket을 생성하는 형태로도 동작 가능하다.

runc의 stdin/stdout/stderr는 containerd-shim에 의해서 Named Pipe로 설정된 상태로 Container를 생성하기 때문에 생성된 Container의 stdin/out/err로 Named Pipe로 설정된다. Named Pipe의 경로는 "/run/docker/containerd/[containerID]/init-stdin/out/err"에 위치하며 dockerd가 containerd에게 요청한 경로를 containerd-shim이 다시 받아서 생성한다. dockerd는 Named Pipe를 통해서 Container의 stdout/stderr (Log)를 수집하며, Container 구동 Option에 따라서 Container의 stdin/out을 Terminal과 연결할때도 Named Pipe를 이용한다.

{% highlight text %}
# pstree
systemd-+-containerd-+-containerd-shim-+-bash
        |            |                 `-9*[{containerd-shim}]
...
        |-dockerd-+-docker-proxy---6*[{docker-proxy}]
        |         `-29*[{dockerd}]
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Docker Components pstree </figcaption>
</figure>

Linux는 기본적으로 고아 Process가 발생하는 경우 고아 Process의 새로운 부모 Process로 Node의 1번 Process인 Node Init Process를 설정한다. runc를 통해서 Container를 생성하게 되면 Container Init Process의 부모 Process는 runc가 된다. 이후 runc가 종료되면 Container Init Process의 부모 Process는 원래라면 Node Init Process가 되어야 하지만, [Shell 1]에서 확인할 수 있는것 처럼 containerd-shim Process가 새로운 Process가 된다. 이러한 이유는 containerd-shim이 runc를 실행하기 전에 prctl() System Call을 이용해 자신을 **Subreaper** Process로 설정하기 때문이다.

Subreaper Process는 자신의 모든 하위 Process 중에서 고아 Process가 발생하면 Node Init Process가 새로운 부모가 아닌, 자기 자신이 고아 Process를 거두어 새로운 부모 Process가 된다는 의미이다. Container Init Process의 부모 Process가 containerd-shim이기 때문에 Container Init Process가 종료될 경우 containerd-shim은 SIGCHLD Signal을 받게되고 Container Init Process의 ExitCode를 얻을수 있는 것이다.

### 2. 참조

* [https://iximiuz.com/en/posts/implementing-container-runtime-shim/?utm_medium=reddit&utm_source=r_kubernetes](https://iximiuz.com/en/posts/implementing-container-runtime-shim/?utm_medium=reddit&utm_source=r_kubernetes)
* [http://alexander.holbreich.org/docker-components-explained/](http://alexander.holbreich.org/docker-components-explained/)
* [http://cloudrain21.com/examination-of-docker-process-binary](http://cloudrain21.com/examination-of-docker-process-binary)
* [https://unix.stackexchange.com/questions/206386/what-does-the-symbol-denote-in-the-beginning-of-a-unix-domain-socket-path-in-l](https://unix.stackexchange.com/questions/206386/what-does-the-symbol-denote-in-the-beginning-of-a-unix-domain-socket-path-in-l)
* [https://github.com/containerd/containerd/pull/2631](https://github.com/containerd/containerd/pull/2631)
* [https://windsock.io/the-docker-proxy/](https://windsock.io/the-docker-proxy/)
