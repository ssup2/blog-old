---
title: Kubernetes Operator SDK
category: Programming
date: 2019-05-30T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

Operator SDK User Guide에 나온 Memcached Operator를 실습을 통해 Operator SDK를 이해한다.

### 1. Operator SDK

### 2. 개발 환경

* Ubuntu 18.04 LTS
* Kubernetes 1.12
* golang 1.12.2
* root user

### 3. Operator SDK 설치

* Kubernetes Operator SDK CLI를 설치한다.

~~~
# mkdir -p ~/operator-sdk
# cd ~/operator-sdk
# RELEASE_VERSION=v0.8.0
# curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
# chmod +x operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu && sudo cp operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu /usr/local/bin/operator-sdk && rm operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
~~~

### 4. Project 생성

* Memcached Operator Project를 생성한다.
  * **operator-sdk new** 명령어를 통해서 golang Project의 표준 Directory 구조가 생성된다.

~~~
# mkdir -p $GOPATH/src/github.com/ssup2 
# cd $GOPATH/src/github.com/ssup2
# export GO111MODULE=on
# operator-sdk new example-k8s-operator-memcached 
# cd example-k8s-operator-memcached
# ls 
build  cmd  deploy  go.mod  go.sum  pkg  README.md  tools.go  vendor  version
~~~

### 5. CRD 생성

* CRD (Custom Resource Definition)를 추가한다.
  * 추가된 CRD는 'pkg/apis/cache/v1alpha1' Directory 아래에 정의되어 있다.

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

### 6. Controller 생성

* Controller를 생성한다.

~~~
# operator-sdk add controller --api-version=cache.example.com/v1alpha1 --kind=Memcached
~~~

### 7. Memcached Operator 배포

* 생성한 Memcached Operator를 Kubernetes Cluster에 배포한다.

### 8. Memcached CR 생성

* Memcached CR을 생성한다.

### 9. 참조

* [https://github.com/operator-framework/operator-sdk](https://github.com/operator-framework/operator-sdk)
* [https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md)
