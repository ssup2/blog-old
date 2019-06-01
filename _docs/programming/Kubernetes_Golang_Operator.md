---
title: Kubernetes Golang Operator
category: Programming
date: 2019-05-30T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

Operator SDK User Guide에 나온 Memcached Golang Operator를 실습을 통해 Golang Operator SDK를 분석한다.

### 1. Golang Operator

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

### 7. Memcached CR 생성

* Memcached CR을 생성한다.

~~~
# kubectl create -f deploy/crds/cache_v1alpha1_memcached_crd.yaml
~~~

### 8. Memcached Operator 구동

* 생성한 Memcached Operator를 Container Image로 생성한 다음 Docker Registry에 Push한다.
  * Container Image의 이름은 개인 Repository에 맞도록 변경한다.

~~~
# go mod vendor
# operator-sdk build supsup5642/memcached-operator:v0.0.1
# sed -i 's|REPLACE_IMAGE|supsup5642/memcached-operator:v0.0.1|g' deploy/operator.yaml
# docker push supsup5642/memcached-operator:v0.0.1
~~~

* Memcached Opeartor를 구동한다.

~~~
$ kubectl create -f deploy/service_account.yaml
$ kubectl create -f deploy/role.yaml
$ kubectl create -f deploy/role_binding.yaml
$ kubectl create -f deploy/operator.yaml
~~~

### 9. Memcached 구동

* Memcached Operator를 이용하여 Memcached를 구동한다.

~~~
# kubectl apply -f deploy/crds/cache_v1alpha1_memcached_cr.yaml
~~~

### 10. 참조

* [https://github.com/operator-framework/operator-sdk](https://github.com/operator-framework/operator-sdk)
* [https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md)
