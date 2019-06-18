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
# go get github.com/ssup2/example-golang-module-module
# cd $GOPATH/src/github.com/ssup2/example-golang-module-module
# export GO111MODULE=on
# 
# vim test.go
# git add .
# git commit -m "version 1.1.0"
# git tag -a v1.1.0
#
# vim test.go
# git add .
# git commit -m "version 2.2.0"
# git tag -a v2.2.0
#
# vim test.go
# git add .
# git commit -m "version 3.5.0"
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

{% highlight go %}
package test

import "fmt"

func TestPrint() {
        fmt.Println("test - v3.5.0")
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] test.go - v3.5.0</figcaption>
</figure>

[Shell 1]은 github의 ssup2 계정에 example-golang-module-module Repository를 생성한 다음 Test를 위한 Module을 생성하는 과정을 나타내고 있다. [Code 1] ~ [Code 3]은 각 Version별 test.go 파일을 나타내고 있다. Module의 Version이 TestPrint() 함수에 출력되는 것을 확인할 수 있다. Tag는 반드시 v[Major].[Minor].[Patch] 형태로 작성되어야 한다. 마지막 v3.5.0 Version에만 별도의 Git Tag를 생성하지 않았다.

#### 1.2. Module 이용

{% highlight text %}
# go get github.com/ssup2/example-golang-module-main
# cd $GOPATH/src/github.com/ssup2/example-golang-module-main
# export GO111MODULE=on
#
# vim main.go
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Module 이용</figcaption>
</figure>

{% highlight go %}
package main

import module "github.com/ssup2/example-golang-module-module"

func main() {
    module.TestPrint()
}  
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] main.go</figcaption>
</figure>

[Shell 2]는 ssup2 계정에 example-golang-module-main Repository를 생성한 다음 [Shell 1]에서 생성한 Module을 이용하는 Golang Binary를 개발하는 과정을 나타내고 있다. [Code 4]에 나타낸 main.go에서 생성한 Module의 TestPrint() 함수를 호출하는 것을 확인할 수 있다.

##### 1.2.1. Module에 Git Tag가 있는 경우

{% highlight go %}
module github.com/ssup2/example-golang-module-main

go 1.12

require github.com/ssup2/example-golang-module-module v1.1.0
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] v1.1.0 Version을 이용하도록 설정된 go.mod</figcaption>
</figure>

{% highlight text %}
# go build
# ./example-golang-module-main
test - v3.5.0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] 최신 Version 이용 확인</figcaption>
</figure>

[Code 4]를 작성하고 저장하면 **go.mod** 파일이 생성된다. go.mod 파일은 Compile에 필요한 Module 정보를 저장하고 있다. [파일 1]은 생성된 go.mod 파일을 나타내고 있다. 이용한 Module의 Version을 명시하지 않으면 가장 낮은 Git Tag Version의 Module을 이용하도록 go.mod 파일이 생성된다. [Shell 1]로 생성된 Module의 가장 낮은 Git Tag Version은 v1.1.0이기 때문에 go.mod 파일에 v1.1.0을 이용하도록 설정된다. 다른 Git Tag Version을 이용하고 싶다면 이용하고 싶은 Version으로 go.mod을 수정하면 된다.

##### 1.2.2. Module에 Git Tag가 없는 경우

{% highlight go %}
module github.com/ssup2/example-golang-module-main

go 1.12

require github.com/ssup2/example-golang-module-module v0.0.0-20190618122326-74b4156c24a1 
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] 최신 Version을 이용하도록 설정된 go.mod</figcaption>
</figure>

{% highlight text %}
# go build
# ./example-golang-module-main
test - v3.5.0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] 최신 Version 이용 확인</figcaption>
</figure>

Module의 모든 Git Tag를 삭제한 다음 [Code 4]를 작성하면 저장하면 [파일 2]처럼 go.mod 파일이 생성된다.
Git Tag가 지정되지 않았기 때문에 임의의 Git Tag명을 이용한다. 임의의 Git Tag명은 Module의 마지막 Commit 시간과 ID로 구성된다. 20190618122326은 Module의 마지막 Commit 시간을 나타내고, 74b4156c24a1은 Module의 마지막 Commit ID를 나타낸다.

##### 1.2.3. go get을 이용하여 Package를 직접 받는 경우

#### 1.3. Module 명령어

### 2. 참조

* [https://blog.golang.org/using-go-modules](https://blog.golang.org/using-go-modules)
* [https://jusths.tistory.com/107](https://jusths.tistory.com/107)
* [https://velog.io/@kimmachinegun/Go-Go-Modules-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0-7cjn4soifk](https://velog.io/@kimmachinegun/Go-Go-Modules-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0-7cjn4soifk)
* [https://aidanbae.github.io/code/golang/modules/](https://aidanbae.github.io/code/golang/modules/)