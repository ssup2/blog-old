---
title: Kubernetes 설치 / kind 이용 / Ubuntu 18.04 환경
category: Record
date: 2021-02-24T12:00:00Z
lastmod: 2021-02-24T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Ubuntu 18.04.5
* kind v0.10.0
* kubernetes v1.20.2

### 2. kind 설치

~~~console
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
# chmod +x ./kind
# mv ./kind /usr/bin/kind
~~~

kind를 설치한다.

### 3. Cluster 생성

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

[파일 1]의 내용을 갖는 kind-config.yaml 파일을 작성하여 kind가 1 Master, 2 Worker를 Kubernetes Cluster를 구성하도록 만든다.

~~~console
# kind create cluster --config kind-config.yaml
~~~

작성한 kind-config.yaml 파일을 이용하여 Kubernetes Cluster를 구성한다.

### 4. Cluster 확인

~~~console
# # kubectl get nodes -o wide
NAME                 STATUS   ROLES                  AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION     CONTAINER-RUNTIME
kind-control-plane   Ready    control-plane,master   20h   v1.20.2   172.18.0.3    <none>        Ubuntu 20.10   5.4.0-52-generic   containerd://1.4.0-106-gce4439a8
kind-worker          Ready    <none>                 20h   v1.20.2   172.18.0.2    <none>        Ubuntu 20.10   5.4.0-52-generic   containerd://1.4.0-106-gce4439a8
kind-worker2         Ready    <none>                 20h   v1.20.2   172.18.0.4    <none>        Ubuntu 20.10   5.4.0-52-generic   containerd://1.4.0-106-gce4439a8

# kubectl -n kube-system get pod -o wide
NAME                                         READY   STATUS    RESTARTS   AGE   IP           NODE                 NOMINATED NODE   READINESS GATES
coredns-74ff55c5b-8p8wc                      1/1     Running   0          19h   10.244.0.2   kind-control-plane   <none>           <none>
coredns-74ff55c5b-nsh6c                      1/1     Running   0          19h   10.244.0.4   kind-control-plane   <none>           <none>
etcd-kind-control-plane                      1/1     Running   0          20h   172.18.0.3   kind-control-plane   <none>           <none>
kindnet-dbbwm                                1/1     Running   0          19h   172.18.0.2   kind-worker          <none>           <none>
kindnet-kmkbq                                1/1     Running   0          19h   172.18.0.4   kind-worker2         <none>           <none>
kindnet-ncfz5                                1/1     Running   0          19h   172.18.0.3   kind-control-plane   <none>           <none>
kube-apiserver-kind-control-plane            1/1     Running   0          20h   172.18.0.3   kind-control-plane   <none>           <none>
kube-controller-manager-kind-control-plane   1/1     Running   0          20h   172.18.0.3   kind-control-plane   <none>           <none>
kube-proxy-6n8pv                             1/1     Running   0          19h   172.18.0.2   kind-worker          <none>           <none>
kube-proxy-kvnxq                             1/1     Running   0          19h   172.18.0.3   kind-control-plane   <none>           <none>
kube-proxy-ttpxl                             1/1     Running   0          19h   172.18.0.4   kind-worker2         <none>           <none>
kube-scheduler-kind-control-plane            1/1     Running   0          20h   172.18.0.3   kind-control-plane   <none>           <none>
~~~

생성된 Kubernetes Cluster를 확인한다.

~~~console
# docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                       NAMES
e822ea854922        kindest/node:v1.20.2   "/usr/local/bin/entr…"   8 minutes ago       Up 8 minutes                                    kind-worker
5d1428f8c37c        kindest/node:v1.20.2   "/usr/local/bin/entr…"   8 minutes ago       Up 8 minutes        127.0.0.1:41593->6443/tcp   kind-control-plane
21da173648df        kindest/node:v1.20.2   "/usr/local/bin/entr…"   8 minutes ago       Up 8 minutes                                    kind-worker2
~~~

1 Master, 2 Worker Node로 구성하였기 때문에 3개의 Docker Container가 구동되고 있는것을 확인할 수 있다.

### 5. 참조

* [https://kind.sigs.k8s.io/docs/user/quick-start/](https://kind.sigs.k8s.io/docs/user/quick-start/)