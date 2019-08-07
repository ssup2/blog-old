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

Module은 Package의 집합을 의미한다. 이러한 Module을 관리하는 기능이 **Golang 1.11** 이후부터는 포함되어 있다. Golang은 Module 관리 기능을 이용하여 Package Dependency를 관리한다. Golang Module을 이용하면 Golang 개발자는 더이상 Golang Code를 $GOPATH/src Directory에 두지 않아도 된다. Golang 1.11 Version 이전에는 vgo, dep 같은 별도의 Tool을 이용하여 Package Dependency를 관리하였다.

#### 1.1. Module 생성

{% highlight text %}
# export GO111MODULE=off
# go get github.com/ssup2/example-golang-module-module
# cd $GOPATH/src/github.com/ssup2/example-golang-module-module
# export GO111MODULE=on
#
# vim test.go
# vim go.mod
# git add .
# git commit -m "version 1.1.0"
# git tag -a v1.1.0 -m "v1.1.0"
# vim test.go
# git add .
# git commit -m "version 1.1.5"
# git tag -a v1.1.5 -m "1.1.5"
#
# vim test.go
# vim go.mod
# git add .
# git commit -m "version 2.2.0"
# git tag -a v2.2.0 -m "2.2.0"
# vim test.go
# git add .
# git commit -m "version 2.2.7"
# git tag -a v2.2.7 -m "2.2.7"
#
# vim test.go
# vim go.mod
# git add .
# git commit -m "version 3.3.0"
# 
# git push
# git push --tags
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Module 생성</figcaption>
</figure>

{% highlight text %}
module github.com/ssup2/example-golang-module-module

go 1.12   
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Module의 go.mod - v0.x.x, v1.x.x</figcaption>
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
    fmt.Println("test - v1.1.5")
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] test.go - v1.1.5</figcaption>
</figure>

{% highlight text %}
module github.com/ssup2/example-golang-module-module/v2

go 1.12
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Module의 go.mod - v2.x.x</figcaption>
</figure>

{% highlight go %}
package test

import "fmt"

func TestPrint() {
    fmt.Println("test - v2.2.0")
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] outer.go - v2.2.0</figcaption>
</figure>

{% highlight go %}
package test

import "fmt"

func TestPrint() {
    fmt.Println("test - v2.2.7")
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] outer.go - v2.2.7</figcaption>
</figure>

{% highlight text %}
module github.com/ssup2/example-golang-module-module/v3

go 1.12
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Module의 go.mod - v3.x.x</figcaption>
</figure>

{% highlight go %}
package test

import "fmt"

func TestPrint() {
    fmt.Println("test - v3.3.0")
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] outer.go - v3.3.0</figcaption>
</figure>

[Shell 1]은 Github의 ssup2 계정에 example-golang-module-module Repository를 생성한 다음 Test를 위한 Module을 생성하는 과정을 나타내고 있다. **GO111MODULE** 환경변수는 Golang에서 지원하는 Module 관리 기능을 이용할지를 결정한다. GO111MODULE 환경변수가 off 값을 가지는 경우 Golang에서 지원하는 Module 관리 기능을 이용하지 않겠다는 의미이다. off 상태일때 go get 명령어는 Golang Code를 **$GOPATH/src**에 받는다. GO111MODULE 환경변수가 on 값을 가지는 경우 Golang에서 지원하는 Module 관리 기능을 이용하겠다는 의미이다. on 상태일때 go get 명령어는 Golang Code를 **$GOPATH/pkg/mod**에 받는다. [Shell 1]에서는 go get으로 Golang Code를 받을때만 잠깐 GO111MODULE 환경변수를 off로 설정하였다.

Module Version은 반드시 **v[Major].[Minor].[Patch]** 형태로 구성되어야 한다. [Code 1 ~ 5]는 Module Version별 test.go 파일을 나타내고 있다. [파일 1 ~3]은 Module의 go.mod 파일을 나타내고 있다. **go.mod 파일은 Module 관련 정보를 저장하고 있는 중요한 파일이다.** Module의 Major Version이 v0, v1인 경우에는 go.mod 파일은 [파일 1]의 내용처럼 Major Version을 명시하지 않아도 관계없지만, Major Version이 v2 이상인 경우에는 go.mod 파일은 [파일 2, 3]의 내용처럼 반드시 **Major Version**을 명시해야 한다.

Golang의 Module 관리 기능은 **Git Tag**를 이용하여 Module Version을 관리하기 때문에 가능하면 Module Version으로 Git Tag를 생성해 두는것이 좋다. [Shell 1]에서는 Test를 위해서 v3.3.0 Version의 Module만 Git Tag를 생성하지 않았고 나머지 Version은 Git Tag를 생성하였다. [Shell 1]에서 생성한 Module은 [https://github.com/ssup2/example-golang-module-module](https://github.com/ssup2/example-golang-module-module)에서 확인할 수 있다.

#### 1.2. Module 이용

##### 1.2.1. Module을 이용하지 않지만 가져오기만 하는 경우

{% highlight text %}
# export GO111MODULE=on
#
# go mod init module-main
# go get github.com/ssup2/example-golang-module-module@v1.1.0
# vim go.mod
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Module 초기화</figcaption>
</figure>

{% highlight text %}
module module-main

go 1.12

require github.com/ssup2/example-golang-module-module v1.1.0 // indirect      
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] Main의 go.mod - v1.1.0</figcaption>
</figure>

[Shell 2]는 임의의 Directory안에서 **go mod init** 명령어를 이용하여 go.mod 파일을 생성한 다음, [Shell 1]에서 생성한 v1.1.0 Version의 Module을 가져오는 과정을 나타내고 있다. [파일 5]의 내용으로 go.mod 파일이 생성된다. 가져온 Module과 Version이 명시되어 있는걸 확인할 수 있다. 마지막에 **indirect** 주석이 써있는데 go get 명령어를 통해서 Module을 가져왔지만 실제 이용하고 있지는 않기 때문에 indirect 주석이 달린것이다.

{% highlight text %}
# export GO111MODULE=on
#
# go mod tidy
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Module 정리</figcaption>
</figure>

{% highlight text %}
module module-main

go 1.12
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] Main의 go.mod - Empty</figcaption>
</figure>

**go mod tidy** 명령어는 사용하지 않고 있는 Module 정보를 go.mod 파일에서 삭제하는 기능이다. Golang의 Module 관리기능은 새로운 Module이 추가될때는 자동으로 go.mod 파일에 추가하지만, 사용하지 않는 Module을 자동으로 go.mod 파일에서 제거하지는 않는다. 개발자가 go mod tidy 명령어로 이용하지 않는 Module을 관리해야 한다. [Shell 3], [파일 6]은 go mod tidy 명령어를 통해서 이용하지 않는 Module 정보가 go.mod 파일에서 삭제되는 과정을 나타내고 있다.

##### 1.2.2. Git Tag로 Module의 Version이 등록되어 있는 Module을 이용할 경우

{% highlight text %}
# export GO111MODULE=on
#
# vim main.go
# vim go.mod
# go build
# ./module-main
test - v1.1.5
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Main 생성, 구동 - v1.1.5</figcaption>
</figure>

{% highlight go %}
package main

import module "github.com/ssup2/example-golang-module-module"

func main() {
    module.TestPrint()
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 6] main.go - v0.x.x, v1.x.x</figcaption>
</figure>

{% highlight text %}
module module-main

go 1.12

require github.com/ssup2/example-golang-module-module v1.1.5      
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 7] Main의 go.mod - v1.1.5</figcaption>
</figure>

[Shell 4]는 생성한 Module을 호출하는 main() 함수를 생성하고 구동하는 과정을 나타내고 있다. [Code 6]에 나타낸 main.go에서 생성한 Module의 TestPrint() 함수를 호출하는 것을 확인할 수 있다. main.go를 생성하고 나면 [파일 7]의 내용을 갖는 go.mod 파일이 생성된다. [파일 7]에는 생성한 v1.1.5 Version의 Module을 이용한다는 내용이 명시되어 있는것을 확인할 수 있다. [Code 6]에서는 Module Version을 명시하지 않았기 때문에 Major Version이 v0, v1인 Module 중에서 가장 높은 Version의 Module이 선택되는데, v1.1.5 Version이 가장 높은 v0, v1의 Version의 이기 때문에 v1.1.5를 이용하도록 자동으로 설정되는 것이다.

{% highlight text %}
# export GO111MODULE=on
#
# vim main.go
# vim go.mod
# go build
# ./module-main
test - v1.1.5
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Main 생성, 구동 - v2.2.7</figcaption>
</figure>

{% highlight go %}
package main

import module "github.com/ssup2/example-golang-module-module/v2"

func main() {
    module.TestPrint()
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 7] main.go - v2.x.x</figcaption>
</figure>

{% highlight text %}
module module-main

go 1.12

require (
    github.com/ssup2/example-golang-module-module v1.1.5
    github.com/ssup2/example-golang-module-module/v2 v2.2.7
)       
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 8] Main의 go.mod - v2.2.7</figcaption>
</figure>

[Shell 4]는 [Code 7]처럼 main.go에서 Module Version v2를 이용하도록 변경한 다음, 다시 main() 함수를 구동하는 과정을 나타내고 있다. v2 Version의 Module 중에서 v2.2.7 Version이 가장 높은 Version이기 때문에 v2.2.7를 이용하도록 자동으로 설정되는 것이다. [파일 8]에는 v2.2.7 Version의 Module을 이용한다는 내용이 추가되어 있는걸 확인할 수 있다. v1.1.5 Version의 Module 정보는 남아 있지만 실제로는 이용되지는 않는다. go mod tidy 명령어를 이용하면 v1.1.5 Version의 Module 정보는 사라진다.

{% highlight text %}
# export GO111MODULE=on
#
# go get github.com/ssup2/example-golang-module-module/v2@v2.2.0
# vim go.mod
# go build
# ./module-main
test - v2.2.0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] Main 생성, 구동 - v2.2.0</figcaption>
</figure>

{% highlight text %}
module module-main

go 1.12

require (
    github.com/ssup2/example-golang-module-module v1.1.5
    github.com/ssup2/example-golang-module-module/v2 v2.2.0
)           
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 9] Main의 go.mod - v2.2.7</figcaption>
</figure>

[Shell 6]는 v2.2.0 Version의 Module을 이용하도록 설정하는 과정을 나타내고 있다. go get 명령어를 통해서 go.mod를 수정할 수 있다. [파일 9]에서 v2의 Version이 v2.2.0으로 변경 된것을 확인 할 수 있다. go.mod 파일을 직접 수정하여도 관계없다.

##### 1.2.3. Git Tag로 Module의 Version이 등록되어 있지 않은 Module을 이용할 경우

{% highlight text %}
# export GO111MODULE=on
#
# go get github.com/ssup2/example-golang-module-module/v3@master
# vim main.go
# vim go.mod
# go build
# ./module-main
test - v3.3.0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 7] Main 생성, 구동 - v3</figcaption>
</figure>

{% highlight go %}
package main

import module "github.com/ssup2/example-golang-module-module/v3"

func main() {
    module.TestPrint()
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 8] main.go - v3.x.x</figcaption>
</figure>

{% highlight text %}
module module-main

go 1.12

require (
    github.com/ssup2/example-golang-module-module v1.1.5
    github.com/ssup2/example-golang-module-module/v2 v2.2.7
    github.com/ssup2/example-golang-module-module/v3 v3.0.0-20190622090929-c4fe1b48c3ad
)       
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 10] Main의 go.mod - v3.3.0</figcaption>
</figure>

[Shell 7]은 v3.3.0 Version의 Module을 이용하도록 설정하는 과정을 나타내고 있다. v3.3.0 Version은 Git Tag를 생성하지 않았기 때문에 master Branch를 이용하여 설정할 수 밖에 없다. [파일 10]에서도 v3.3.0 Version은 Git Tag가 없기 때문에 v3에는 임의의 Tag가 들어가 있는것을 확인할 수 있다. 임의의 Tag는 master Branch에 마지막으로 Commit된 날짜와 Commit ID로 구성되어 있다. [파일 10]에서 20190622090929은 Commit 날짜를 의미하고 c4fe1b48c3ad는 Commit ID를 의미한다.

#### 1.3. Module 관련 명령어

Golang Module과 관련된 명령어는 아래와 같다.

* go mod init : go.mod 파일을 생성한다.
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
* [https://medium.com/rungo/anatomy-of-modules-in-go-c8274d215c16](https://medium.com/rungo/anatomy-of-modules-in-go-c8274d215c16)
* [https://johngrib.github.io/wiki/golang-mod/](https://johngrib.github.io/wiki/golang-mod/)