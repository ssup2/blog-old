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
* golang 1.10
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
# mkdir -p $GOPATH/src/github.com/example-inc/
# cd $GOPATH/src/github.com/example-inc/
# operator-sdk new memcached-operator
# cd memcached-operator
~~~

### 4. 참조

* [https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md)
