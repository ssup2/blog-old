---
title: Kubernetes 설치 / kind 이용 / Ubuntu 18.04 환경
category: Record
date: 2021-02-24T12:00:00Z
lastmod: 2021-02-24T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

### 2. kind 설치

~~~console
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
# chmod +x ./kind
# mv ./kind /usr/bin/kind
~~~

kind를 설치한다.

### 3. cluster 생성

{% highlight text %}
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] kind-config.yaml</figcaption>
</figure>

~~~console
# kind create cluster --config kind-config.yaml
~~~

### 4. Cluster 확인

~~~console
# kubectl get nodes
NAME                 STATUS   ROLES                  AGE   VERSION
kind-control-plane   Ready    control-plane,master   99s   v1.20.2
kind-worker          Ready    <none>                 64s   v1.20.2
kind-worker2         Ready    <none>                 64s   v1.20.2
~~~

~~~console
# docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                       NAMES
e822ea854922        kindest/node:v1.20.2   "/usr/local/bin/entr…"   8 minutes ago       Up 8 minutes                                    kind-worker
5d1428f8c37c        kindest/node:v1.20.2   "/usr/local/bin/entr…"   8 minutes ago       Up 8 minutes        127.0.0.1:41593->6443/tcp   kind-control-plane
21da173648df        kindest/node:v1.20.2   "/usr/local/bin/entr…"   8 minutes ago       Up 8 minutes                                    kind-worker2
~~~

### 5. 참조

* [https://kind.sigs.k8s.io/docs/user/quick-start/](https://kind.sigs.k8s.io/docs/user/quick-start/)