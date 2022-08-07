---
title: Kubernetes Kubeflow 설치 / kind 이용 / Ubuntu 20.04
category: Record
date: 2022-08-06T12:00:00Z
lastmod: 2022-08-06T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* Kubeflow 1.4.0
* kind v0.14.0
* Kubernetes 1.24.14

### 2. king 설치

~~~console
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
# chmod +x ./kind
# sudo mv ./kind /usr/local/bin/kind
~~~

### 3. Kubernetes Cluster 생성

{% highlight text %}
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] kind-config.yaml</figcaption>
</figure>

[파일 1]의 내용을 갖는 kind-config.yaml 파일을 작성하여 kind가 1 Master, 2 Worker를 Kubernetes Cluster를 구성하도록 만든다.

~~~console
# kind create cluster --config kind-config.yaml
...

# kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   76s   v1.24.0
kind-worker          Ready    <none>          44s   v1.24.0
kind-worker2         Ready    <none>          57s   v1.24.0
kind-worker3         Ready    <none>          44s   v1.24.0
~~~

작성한 kind-config.yaml 파일을 이용하여 Kubernetes Cluster를 구성한다.

### 4. 참고

* [https://github.com/kubeflow/manifests#installation](https://github.com/kubeflow/manifests#installation)
