---
title: Golang 설치 / Ubuntu 18.04 환경
category: Record
date: 2019-05-30T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설치 환경은 다음과 같다.
* Ubuntu 18.04 LTS 64bit, root user
* golang 1.12.2

### 2. Ubuntu Package 설치

~~~console
# wget https://dl.google.com/go/go1.12.2.linux-amd64.tar.gz
# tar -xvf go1.12.2.linux-amd64.tar.gz
# mv go /usr/local
~~~

golang을 설치한다. /usr/local/go Directory에 설치한다.

### 3. 환경변수 설정

{% highlight text %}
...
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$GOROOT/bin:$GOBIN:$PATH
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.bashrc</figcaption>
</figure>

~/.bashrc 파일에 golang에 이용하는 환경변수를 설정하고, 어느 Directory에서든 golang을 이용할 수 있도록 한다.
* GOROOT : golang의 명령어, Package, Library 등이 있는 Directory이다.
* GOPATH : 현재 개발하고 있는 golang Program의 Home Directory이다.
* GOBIN : go install 명령어를 이용하여 컴파일된 golang Binary가 복사되는 Directory이다.

### 4. 참조

* [https://medium.com/@RidhamTarpara/install-go-1-11-on-ubuntu-18-04-16-04-lts-8c098c503c5f](https://medium.com/@RidhamTarpara/install-go-1-11-on-ubuntu-18-04-16-04-lts-8c098c503c5f)