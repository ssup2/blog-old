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

[그림 1]은 Docker 19.02 Version의 구성요소를 나타내고 있다. 구성 요소로는 docker, dockerd, docker-proxy, containerd, containerd-shim, runc로 구성되어 있다. 각 구성요소의 역활은 다음과 같다.

#### 1.1. docker (Docker Client)

docker는 Docker Daemon이 제공하는 HTTP 기반 REST API를 이용하여 Container를 제어하는 Docker Client 역활을 수행한다.

#### 1.2. dockerd (Docker Daemon)

Docker Daemon은 HTTP 기반 REST API를 제공하여 Docker Client가 Container를 제어하고 이용할 수 있게하는 Docker Daemon의 역활을 수행한다. Docker Client로부터 받은 요청중에서 대부분은 dockerd가 구동시킨 containerd에게 처리를 위임하고, 일부 요청만 직접 처리한다. dockerd는 containerd 구동, Docker Image Build (Dockerfile), Container Network 설정 (Bridge, iptables), Container Log 기록, docker-proxy 구동 등의 역활을 수행한다. Docker Daemon의 REST API는 기본적으로 "/var/run/docker.sock" 파일의 Unix Domain Socket을 통해서 제공되며 Docker Daemon의 Opiton을 변경을 통해서 TCP Socket을 이용하도록 변경할 수도 있다.

#### 1.3. docker-proxy (Docker Proxy)

docker-proxy는 Node 외부에서 Container안으로 Packet을 Forwarding 해주는 Proxy Server 역활을 수행한다. docker-proxy는 Container 구동시 반드시 필요한 구성 요소는 아니다. Linux에서 동작하는 dockerd는 Linux Netfilter Framework를 기반으로 동작하는 iptables를 이용하여 Container로 Packet을 Forwarding 하기 때문이다. 하지만 dockerd가 동작하는 모든 환경에서 iptables를 이용할수 있는것은 아니기 때문에, docker-proxy는 환경에 따라서 이용 유무가 결정된다. dockerd-proxy의 이용 유무는 docker-proxy를 실행하는 dockerd의 설정에 따라서 결정된다.

dockerd는 docker-proxy는 Container의 Port Forwarding Option이 추가될 때 마다 해당 Port를 담당하는 docker-proxy를 추가로  실행한다. 예를 들어 A Container에 10, 20 Port를 Port Forwarding 설정하고, B Container에 30, 40 Port를 Port Forwarding 하도록 설정한다면 docker-proxy는 4개가 동작한다. 다수의 docker-proxy 구동은 Node에도 부담될수 있기 때문에 dockerd가 Linux의 iptables가 이용가능한 환경이라면 docker-proxy를 이용 안하도록 dockerd를 설정하는것이 좋다.

#### 1.4. containerd

#### 1.5. containerd-shim

#### 1.6. runc

### 2. 참조

* [https://iximiuz.com/en/posts/implementing-container-runtime-shim/?utm_medium=reddit&utm_source=r_kubernetes](https://iximiuz.com/en/posts/implementing-container-runtime-shim/?utm_medium=reddit&utm_source=r_kubernetes)
* [http://alexander.holbreich.org/docker-components-explained/](http://alexander.holbreich.org/docker-components-explained/)
* [http://cloudrain21.com/examination-of-docker-process-binary](http://cloudrain21.com/examination-of-docker-process-binary)
* [https://unix.stackexchange.com/questions/206386/what-does-the-symbol-denote-in-the-beginning-of-a-unix-domain-socket-path-in-l](https://unix.stackexchange.com/questions/206386/what-does-the-symbol-denote-in-the-beginning-of-a-unix-domain-socket-path-in-l)
* [https://github.com/containerd/containerd/pull/2631](https://github.com/containerd/containerd/pull/2631)
* [https://windsock.io/the-docker-proxy/](https://windsock.io/the-docker-proxy/)
