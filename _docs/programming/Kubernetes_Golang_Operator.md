---
title: Kubernetes Golang Operator
category: Programming
date: 2019-05-30T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

Operator SDK User Guide에 나온 Memcached Golang Operator를 실습을 통해 Golang Operator SDK를 분석한다.

### 1. Golang Operator SDK

### 2. Memcached Golang Operator

Memcached Golang Operator를 개발한다.

#### 2.1. 개발 환경

개발 환경은 다음과 같다.
* Ubuntu 18.04 LTS, root user
* Kubernetes 1.12
* golang 1.12.2

#### 2.2. Operator SDK 설치

{% highlight text %}
# mkdir -p ~/operator-sdk
# cd ~/operator-sdk
# RELEASE_VERSION=v0.8.0
# curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
# chmod +x operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu && sudo cp operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu /usr/local/bin/operator-sdk && rm operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
# operator-sdk
An SDK for building operators with ease

Usage:
  operator-sdk [command]

Available Commands:
  add         Adds a controller or resource to the project
  build       Compiles code and builds artifacts
  completion  Generators for shell completions
  generate    Invokes specific generator
  help        Help about any command
  migrate     Adds source code to an operator
  new         Creates a new operator application
  olm-catalog Invokes a olm-catalog command
  print-deps  Print Golang packages and versions required to run the operator
  run         Runs a generic operator
  scorecard   Run scorecard tests
  test        Tests the operator
  up          Launches the operator
  version     Prints the version of operator-sdk

Flags:
  -h, --help      help for operator-sdk
      --verbose   Enable verbose logging

Use "operator-sdk [command] --help" for more information about a command.
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Operator SDK 설치</figcaption>
</figure>

Kubernetes Operator SDK CLI를 설치하고 동작을 확인한다.

#### 2.3. Project 생성

{% highlight text %}
# mkdir -p $GOPATH/src/github.com/ssup2 
# cd $GOPATH/src/github.com/ssup2
# export GO111MODULE=on
# operator-sdk new example-k8s-operator-memcached 
# cd example-k8s-operator-memcached && ls
build  cmd  deploy  go.mod  go.sum  pkg  tools.go  vendor  version
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Project 생성</figcaption>
</figure>

**operator-sdk new** 명령어를 통해서 Memcached Operator Project를 생성한다. 'operator-sdk new' 명령어를 수행하면 **Standard Go Project Layout**이 생성된다. [Shell 2]에서 조회되는 bulid, cmd, pkg, vendor Directory는 Memcached Operator Project를 위한 Standard Go Project Layout의 일부분이다. deploy Directory에는 Kubernetes에 Memcached Operator 구동하거나, Kubernetes의 CRD (Custom Resource Definition)를 통해서 정의된 Memcached Object를 생성하기 위한 YAML 파일이 위치하게 된다.

#### 2.4. Memcached CRD 생성

{% highlight text %}
# operator-sdk add api --api-version=cache.example.com/v1alpha1 --kind=Memcached
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Memcached CRD 생성</figcaption>
</figure>

Memcached CRD를 추가한다. 추가된 Memcached CRD는 'pkg/apis/cache/v1alpha1' Directory 아래에 정의된다. 또한 Memcached Object 생성을 위한 YAML 파일은 'deploy/crds' Directory 아래에 위치한다.

{% highlight golang linenos %}
...
type MemcachedSpec struct {
	Size int32 `json:"size"`
}
...
type MemcachedStatus struct {
	Nodes []string `json:"nodes"`
}
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] pkg/apis/cache/v1alpha1/memcached_types.go</figcaption>
</figure>

[Shell 3]의 명령어로 추가된 MemcachedSpec, MemcachedStatus 구조체를 [Code 1]과 같이 수정한다. MemcachedSpec의 Size는 동작해야 하는 Memcached Pod의 개수를 나타내고, MemcachedStatus의 Nodes는 Memcached가 동작하는 Pod의 이름을 나타낸다.

#### 2.5. Memcached Controller 생성

{% highlight text %}
# operator-sdk add controller --api-version=cache.example.com/v1alpha1 --kind=Memcached
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Memcached Controller 생성</figcaption>
</figure>

Memcached를 실제로 관리하는 Memcached Controller를 생성한다.

#### 2.6. Memcached Object 생성

{% highlight text %}
# kubectl create -f deploy/crds/cache_v1alpha1_memcached_crd.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Memcached Object 생성</figcaption>
</figure>

[Shell 2]에서 생성된 Memcached Object가 정의된 YAML 파일을 이용하여 Memcached Object를 생성한다.

#### 2.7. Memcached Operator 구동

{% highlight text %}
# go mod vendor
# operator-sdk build supsup5642/memcached-operator:v0.0.1
# sed -i 's|REPLACE_IMAGE|supsup5642/memcached-operator:v0.0.1|g' deploy/operator.yaml
# docker push supsup5642/memcached-operator:v0.0.1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] Memcached Operator Image 생성 및 Push</figcaption>
</figure>

개발한 Memcached Operator를 기반으로 하는 Container Image로 생성한 다음 Docker Registry에 Push한다. Container Image의 이름은 개인 Repository에 맞도록 변경한다.

{% highlight text %}
$ kubectl create -f deploy/service_account.yaml
$ kubectl create -f deploy/role.yaml
$ kubectl create -f deploy/role_binding.yaml
$ kubectl create -f deploy/operator.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 7] Memcached Operator Image 생성 및 Push</figcaption>
</figure>

[Shell 2]에서 생성된 Memcached Operator 관련 Object가 정의된 YAML 파일을 이용하여 Memcached Operator를 구동한다.

#### 2.8. Memcached 구동

{% highlight text %}
# kubectl apply -f deploy/crds/cache_v1alpha1_memcached_cr.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 8] Memcached 구동</figcaption>
</figure>

Memcached Operator를 이용하여 Memcached를 구동한다.

### 3. 참조

* [https://github.com/operator-framework/operator-sdk](https://github.com/operator-framework/operator-sdk)
* [https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md)
* [https://github.com/operator-framework/operator-sdk-samples/tree/master/memcached-operator](https://github.com/operator-framework/operator-sdk-samples/tree/master/memcached-operator)
* [https://github.com/golang-standards/project-layout](https://github.com/golang-standards/project-layout)
