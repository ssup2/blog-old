---
title: Kubernetes Operator SDK
category: Programming
date: 2019-05-30T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 operator-sdk User Guide를 바탕으로 Memcached Operator를 개발하고 operator-sdk를 분석한다.

### 1. 개발 환경

* Ubuntu 18.04 LTS
* Kubernetes 1.12
* golang 1.12.2
* root user

### 2. Kubernetes Operator SDK 설치

* Kubernetes Operator SDK CLI를 설치한다.

~~~
# mkdir -p ~/operator-sdk
# cd ~/operator-sdk
# RELEASE_VERSION=v0.8.0
# curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
# chmod +x operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu && sudo cp operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu /usr/local/bin/operator-sdk && rm operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
~~~

### 3. Project 생성

* Memcached Operator Project를 생성한다.

~~~
# mkdir -p $GOPATH/src/github.com/ssup2 
# cd $GOPATH/src/github.com/ssup2
# export GO111MODULE=on
# operator-sdk new example-k8s-operator-memcached 
# cd example-k8s-operator-memcached 
~~~

### 4. CRD 생성

* CRD (Custom Resource Definition)를 추가한다.
  * 추가된 CRD는 pkg/apis/cache/v1alpha1 폴더 아래에 정의되어 있다.

~~~
# operator-sdk add api --api-version=cache.example.com/v1alpha1 --kind=Memcached
~~~

* 위의 명령어로 추가된 MemcachedSpec, MemcachedStatus을 수정한다.
  * size - 배포되어야 하는 Memcached Pod의 개수
  * nodes - Memcached Pod의 이름

{% highlight golang linenos %}
type MemcachedSpec struct {
	Size int32 `json:"size"`
}

type MemcachedStatus struct {
	Nodes []string `json:"nodes"`
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] pkg/apis/cache/v1alpha1/memcached_types.go</figcaption>
</figure>

### 5. Controller 생성

* Controller를 생성한다.

~~~
# operator-sdk add controller --api-version=cache.example.com/v1alpha1 --kind=Memcached
~~~

### 6. 참조

* [https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md)
