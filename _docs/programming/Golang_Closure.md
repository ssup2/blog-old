---
title: Golang Closure
category: Programming
date: 2022-05-24T12:00:00Z
lastmod: 2022-05-24T12:00:00Z
comment: true
adsense: true
---

Golang의 Closure 기법을 분석한다.

### 1. Golang Closure

{% highlight golang linenos %}
package main

import (
    "fmt"
)

func nextFunc(i int) func() int {
	j := 0
	return func() int {
		j++
		return i + j
	}
}

func main() {
	next10 := nextFunc(10)
	fmt.Println(next10()) // 11
	fmt.Println(next10()) // 12
	fmt.Println(next10()) // 13

	next20 := nextFunc(20)
	fmt.Println(next20()) // 21
	fmt.Println(next20()) // 22
	fmt.Println(next20()) // 23
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Golang Closure</figcaption>
</figure>

{% highlight golang linenos %}
package main

import "fmt"

func arryFunc() func() []int {
	arry := []int{1, 2, 3, 4, 5}
	return func() []int {
		return arry
	}
}

func main() {
	arry := arryFunc()
	fmt.Println(arry()) // 1,2,3,4,5
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] Golang Closure to Replace Global Variables</figcaption>
</figure>

### 2. 참조

* [http://golang.site/go/article/11-Go-%ED%81%B4%EB%A1%9C%EC%A0%80](http://golang.site/go/article/11-Go-%ED%81%B4%EB%A1%9C%EC%A0%80)
* [https://medium.com/code-zen/why-gos-closure-can-be-dangerous-f3e5ad0b9fce](https://medium.com/code-zen/why-gos-closure-can-be-dangerous-f3e5ad0b9fce)
* [https://hwan-shell.tistory.com/339](https://hwan-shell.tistory.com/339)