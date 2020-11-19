---
title: Kubernetes 설치 / Cluster API 이용 / Ubuntu 18.04, OpenStack 환경
category: Record
date: 2020-11-20T12:00:00Z
lastmod: 2020-11-20T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* kind v0.9.0
* clusterctl v0.3.10

### 2. Local Kubernetes Cluster 설치

Cluster API 구동하기 위한 Local Kubernetes Cluster를 설치하고 구동을 확인한다.

~~~console
(Local)# GO111MODULE="on" go get sigs.k8s.io/kind@v0.9.0 && kind create cluster
(Local)# kubectl cluster-info
Kubernetes master is running at https://127.0.0.1:34839
KubeDNS is running at https://127.0.0.1:34839/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
~~~

### 3. clusterctl 설치

Cluster API를 Local Kubernetes Cluster에 설치하고 이용하도록 도와주는 clusterctl를 설치한다.

~~~console
(Local)# curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.3.10/clusterctl-linux-amd64 -o clusterctl
(Local)# chmod +x ./clusterctl
(Local)# sudo mv ./clusterctl /usr/local/bin/clusterctl
(Local)# clusterctl version
clusterctl version: &version.Info{Major:"0", Minor:"3", GitVersion:"v0.3.10", GitCommit:"af6630920560ca0e12179897b96d6ea8bd830b63", GitTreeState:"clean", BuildDate:"2020-10-01T14:29:50Z", GoVersion:"go1.13.15", Compiler:"gc", Platform:"linux/amd64"}
~~~

### 4. Cluster API 설치

clusterctl을 이용하여 Local Kubernetes Cluster에 Cluster API를 설치한다.

~~~console
(Local)# clusterctl init --infrastructure openstack
(Local)# kubectl get pod --all-namespaces
capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-6b6579d56d-q7cfm       2/2     Running   0          2m44s
capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-6d878bb599-4wh7h   2/2     Running   0          2m43s
capi-system                         capi-controller-manager-7ff4999d6c-252dk                         2/2     Running   0          2m45s
capi-webhook-system                 capi-controller-manager-6c48f8f9bb-qknwx                         2/2     Running   0          2m45s
capi-webhook-system                 capi-kubeadm-bootstrap-controller-manager-56f98bc7f9-whkgb       2/2     Running   0          2m44s
capi-webhook-system                 capi-kubeadm-control-plane-controller-manager-85bcfd7fcd-hxs4v   2/2     Running   0          2m43s
capi-webhook-system                 capo-controller-manager-cc997bf9-vpqxd                           2/2     Running   0          2m43s
capo-system                         capo-controller-manager-64f4d7f476-95fln                         2/2     Running   0          2m42s
cert-manager                        cert-manager-cainjector-fc6c787db-jknzr                          1/1     Running   0          3m17s
cert-manager                        cert-manager-d994d94d7-rrbjg                                     1/1     Running   0          3m17s
cert-manager                        cert-manager-webhook-845d9df8bf-9m4l8                            1/1     Running   0          3m17s
...
~~~

### 5. VM Image Build

Cluster API를 통해서 생성할 Kubernetes Cluster Node의 VM Image를 Build 한다.

~~~console
(Local)# apt install qemu-kvm libvirt-bin qemu-utils
...
~~~

~~~console
(Local)# curl -L https://github.com/kubernetes-sigs/image-builder/tarball/master -o image-builder.tgz
(Local)# tar xzf image-builder.tgz
(Local)# cd kubernetes-sigs-image-builder-3c3a17
~~~

~~~console
(Local)# cd images/capi
(Local)# export PATH=$PWD/.bin:$PATH
(Local)# make deps-qemu
~~~


### 5. 참조

* [https://kind.sigs.k8s.io/](https://kind.sigs.k8s.io/)
* [https://cluster-api.sigs.k8s.io/](https://cluster-api.sigs.k8s.io/)
* [https://cluster-api.sigs.k8s.io/user/quick-start.html](https://cluster-api.sigs.k8s.io/user/quick-start.html)
* [https://image-builder.sigs.k8s.io/capi/providers/openstack.html](https://image-builder.sigs.k8s.io/capi/providers/openstack.html)