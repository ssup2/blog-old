---
title: Golang Module
category: Programming
date: 2019-06-17T12:00:00Z
lastmod: 2019-06-17T12:00:00Z
comment: true
adsense: true
---

Golang에서 Package Dependency를 관리하는 기법인 Module을 실습을 통해서 이해하고 분석한다.

### 1. Golang Module

Module은 Package의 집합을 의미한다. 이러한 Module을 관리하는 기능이 **Golang 1.11** 이후부터는 포함되어 있다. Golang은 Module 관리를 통해서 Package Dependency를 관리한다. Golang 1.11 이전 Version에서는 vgo, dep 같은 별도의 Tool을 이용하여 Package Dependency를 관리하였다.

#### 1.1. Module 생성

{% highlight text %}
# export GO111MODULE=off
# go get github.com/ssup2/example-golang-module-module
# cd $GOPATH/src/github.com/ssup2/example-golang-module-module
# 
# export GO111MODULE=on
# vim test.go
# vim go.mod
# git add .
# git commit -m "version 1.1.0"
# git tag -a v1.1.0
#
# vim test.go
# vim go.mod
# git add .
# git commit -m "version 2.2.0"
# git tag -a v2.2.0
#
# git push --tags
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Module 생성</figcaption>
</figure>

{% highlight go %}
package test

import "fmt"

func TestPrint() {
        fmt.Println("test - v1.1.0")
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] test.go - v1.1.0</figcaption>
</figure>

{% highlight text %}
module github.com/ssup2/example-golang-module-module

go 1.12
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Module의 go.mod - v1</figcaption>
</figure>

{% highlight go %}
package test

import "fmt"

func TestPrint() {
        fmt.Println("test - v2.2.0")
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] test.go - v2.2.0</figcaption>
</figure>

{% highlight text %}
module github.com/ssup2/example-golang-module-module/v2

go 1.12
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Module의 go.mod - v2</figcaption>
</figure>

[Shell 1]은 github의 ssup2 계정에 example-golang-module-module Repository를 생성한 다음 Test를 위한 Module을 생성하는 과정을 나타내고 있다. **GO111MODULE** 환경변수는 Golang에서 지원하는 Module 관리 기능을 이용할지를 결정한다. GO111MODULE 환경변수가 off 값을 가지는 경우 Golang에서 지원하는 Module 관리 기능을 이용하지 않겠다는 의미이다. go get 명령어는 Golang Code를 **$GOPATH/src**에 받는다. GO111MODULE 환경변수가 on 값을 가지는 경우 Golang에서 지원하는 Module 관리 기능을 이용하겠다는 의미이다. go get 명령어는 Golang Code를 **$GOPATH/pkg/mod**에 받는다. [Shell 1]에서는 go get으로 Golang Code를 받을때만 잠깐 GO111MODULE 환경변수가 off로 설정한다.

Module Version은 반드시 **v[Major].[Minor].[Patch]** 형태로 구성되어야 한다. [Code 1, 2]는 Module Version별 test.go 파일을 나타내고 있다. Module의 Version이 TestPrint() 함수에 출력되는 것을 확인할 수 있다. [파일 1, 2]는 Module Version별 go.mod 파일을 나타내고 있다. Module의 Major Version이 v0, v1인 경우에는 go.mod 파일은 [파일 1]의 내용처럼 Major Version을 명시하지 않아도 관계없지만, Major Version이 v2 이상인 경우에는 go.mod 파일은 [파일 2]의 내용처럼 반드시 Major Version을 명시해야 한다. Golang의 Module 관리 기능은 Git Tag를 이용하여 Module Version을 관리하기 때문에 가능하면 Module Version으로 Git Tag를 생성해두는게 유리하다.

#### 1.2. Module 이용

{% highlight text %}
# export GO111MODULE=off
# go get github.com/ssup2/example-golang-module-main
# cd $GOPATH/src/github.com/ssup2/example-golang-module-main
#
# vim main.go
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Module 이용</figcaption>
</figure>

{% highlight go %}
package main

import module "github.com/ssup2/example-golang-module-module"
//import module "github.com/ssup2/example-golang-module-module/v2"

func main() {
    module.TestPrint()
}  
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] main.go</figcaption>
</figure>

[Shell 2]는 ssup2 계정에 example-golang-module-main Repository를 생성한 다음 [Shell 1]에서 생성한 Module을 이용하는 Golang Binary를 개발하는 과정을 나타내고 있다. [Code 4]에 나타낸 main.go에서 생성한 Module의 TestPrint() 함수를 호출하는 것을 확인할 수 있다.

#### 1.3. Module 관련 명령어

* go list -m all : Build시 사용된 Module들의 Version 확인한다.

* go list -u -m all : Module이 Patch 가능한지 확인한다.

* go get -u : Module을 Patch (Update)한다.

* go mod tidy : go.mod에서 불필요한 Module은 제거하고, 필요한 Module을 추가한다.

* go mod vendor : go.mod의 Module을 이용하여 vendor Directory를 생성한다.

* go clean --modcache : Module Cache ($GOPATH/pkg/mod)를 삭제한다.

### 2. 참조

* [https://blog.golang.org/using-go-modules](https://blog.golang.org/using-go-modules)
* [https://jusths.tistory.com/107](https://jusths.tistory.com/107)
* [https://velog.io/@kimmachinegun/Go-Go-Modules-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0-7cjn4soifk](https://velog.io/@kimmachinegun/Go-Go-Modules-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0-7cjn4soifk)
* [https://aidanbae.github.io/code/golang/modules/](https://aidanbae.github.io/code/golang/modules/)