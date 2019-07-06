---
title: Golang 설치 / macOS
category: Record
date: 2019-05-30T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설치 환경은 다음과 같다.
* Ubuntu 10.14.5
* golang 1.12.2

### 2. Homebrew Package 설치
~~~
# brew install golang
~~~

Homebrew를 이용하여 golang을 설치한다.

### 3. 환경변수 설정

{% highlight text %}
...
export GOROOT="$(brew --prefix golang)/libexec"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$GOROOT/bin:$GOBIN:$PATH
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.bash_profile</figcaption>
</figure>

~/.bash_profile 파일에 golang에 이용하는 환경변수를 설정하고, 어느 Directory에서든 golang을 이용할 수 있도록 한다.
* GOROOT : golang의 명령어, Package, Library 등이 있는 Directory이다.
* GOPATH : 현재 개발하고 있는 golang Program의 Home Directory이다.
* GOBIN : go install 명령어를 이용하여 컴파일된 golang Binary가 복사되는 Directory이다.

### 4. 참조

* [https://ahmadawais.com/install-go-lang-on-macos-with-homebrew](https://ahmadawais.com/install-go-lang-on-macos-with-homebrew/)