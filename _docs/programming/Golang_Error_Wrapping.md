---
title: Golang Error Wrapping
category: Programming
date: 2021-05-17T12:00:00Z
lastmod: 2021-05-17T12:00:00Z
comment: true
adsense: true
---

Golang의 Error Wrapping 기법을 정리한다.

### 1. Golang Error Wrapping

{% highlight golang linenos %}
package main

import (
	"fmt"
)

func outterFunc() error {
	if err := innerFunc(); err != nil {
		return fmt.Errorf("outterError")
	}
	return nil
}

func innerFunc() error {
	return fmt.Errorf("innerError")
}

func main() {
	if err := outterFunc(); err != nil {
		fmt.Printf("error: %v\n", err)  // error: outterError
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Golang Error Example</figcaption>
</figure>

#### 1.1. with Standard errors Package

#### 1.2. with github.com/pkg/errors Package

### 2. 참조

* [https://earthly.dev/blog/golang-errors/](https://earthly.dev/blog/golang-errors/)
* [https://gosamples.dev/check-error-type/](https://gosamples.dev/check-error-type/)
* [https://stackoverflow.com/questions/39121172/how-to-compare-go-errors](https://stackoverflow.com/questions/39121172/how-to-compare-go-errors)
* [https://www.popit.kr/golang-error-stack-trace%EC%99%80-%EB%A1%9C%EA%B9%85/](https://www.popit.kr/golang-error-stack-trace%EC%99%80-%EB%A1%9C%EA%B9%85/)
* [https://dev-yakuza.posstree.com/ko/golang/error-handling/](https://dev-yakuza.posstree.com/ko/golang/error-handling/)