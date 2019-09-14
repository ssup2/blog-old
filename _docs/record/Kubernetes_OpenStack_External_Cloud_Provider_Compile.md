---
title: Kubernetes OpenStack External Cloud Provider Compile / Ubuntu 18.04 환경
category: Record
date: 2019-08-22T12:00:00Z
lastmod: 2019-08-22T12:00:00Z
comment: true
adsense: true
---

### 1. Compile 환경

Compile 환경은 다음과 같다.
* OpenStack External Cloud Provider : v1.15.0
* OS : Ubuntu 18.04 LTS
* Golang : v1.12.2

### 2. OpenStack External Cloud Provider Download

~~~console
# mkdir -p $GOPATH/src/k8s.io/
# cd $GOPATH/src/k8s.io/
# git clone https://github.com/kubernetes/cloud-provider-openstack.git
# git checkout v1.15.0
~~~

OpenStack External Cloud Provider를 Download 한다.

### 3. Binary Compile & Test

~~~console
# cd $GOPATH/src/k8s.io/cloud-provider-openstack
# make build
# make test
~~~

OpenStack External Cloud Provider를 Compile하여 Binary를 생성하고 Test한다.

### 4. Docker Image Build & Push

~~~console
# export REGISTRY=ssup2
# export DOCKER_USERNAME=ssup2
# export DOCKER_PASSWORD=ssup2
# make images
# make upload-images 
~~~

Docker Image로 생성하고 Docker Registry에 생성한 Image를 Push한다. Docker Image를 Push할 Registry 관련 정보를 환경변수로 설정해야 한다.

### 5. 참조

* [https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/getting-started-provider-dev.md](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/getting-started-provider-dev.md)
