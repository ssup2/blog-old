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

Golang에서도 Javascript와 동일하게 Closure 기능을 제공한다. Closure는 함수를 객체화하여 **함수가 상태를 갖게하는 기법**을 의미한다.

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

[Code 1]은 Golang의 Closure 예제를 나타내고 있다. nextFunc() 함수는 자신이 넘겨받은 i Parameter와 1씩 계속 증가하는 j 지역변수를 더하는 함수를 반환한다. Closure를 지원하지 않는 일반적인 언어에서는 동작할 수 없는 함수이다. Stack에 저장되는 i Parameter와 j 지역변수는 nextFunc() 함수가 종료되는 순간 해제되기 때문에 nextFunc() 함수가 반환하는 함수에서는 이용할 수 없기 때문이다.

하지만 Golang에서는 Closure를 지원하기 때문에 nextFunc() 함수의 종료와 함께 Closure가 구성되고, i Paramter와 j 지역변수는 구성된 Closure에 저장된다. 여기서 Closure가 구성된다는 의미는 Stack에 저장되어 변수들을 **Heap**에 복사하여 저장하고 관리된다는 의미를 뜻한다. 따라서 i Parameter와 j 지역변수도 Heap에 저장된다. 따라서 nextFunc() 함수가 반환한 함수는 Clousre에 저장된 변수들을 통해서 동작하게 된다.

[Code 1]에서 next10, next20 변수는 함수 nextFunc()에 의해서 반환되는 함수를 각각 저장하고 있으며, 따라서 각각 별도의 Closure가 구성된다. 이후에 각 Clouser에 저장되어 있는 변수를 활용하여 동작한다. next10 변수의 Closure에는 `j = 0, i = 10` 값이 저장되어 있다. next10 변수를 호출 할 때마다 j의 값이 증가하기 때문에 `11, 12, 13` 값이 출력된다. next20 변수의 Closure에는 `j = 0, i = 20` 값이 저장되어 있다. next20 변수를 호출 할 때마다 j의 값이 증가하기 때문에 `21, 22, 23` 값이 출력된다.

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

[Code 2]는 Closure를 활용하여 Global 변수를 대체하는 방법을 나타내고 있다. 변수를 Closure에 저장하는 방식을 활용하면 Global Variable의 사용을 줄일 수 있다. [Code 2]에서는 arrayFunc() 함수의 Closure에 Integer Slice를 할당하고 이용하는 예제를 나타내고 있다.

### 2. 참조

* [http://golang.site/go/article/11-Go-%ED%81%B4%EB%A1%9C%EC%A0%80](http://golang.site/go/article/11-Go-%ED%81%B4%EB%A1%9C%EC%A0%80)
* [https://medium.com/code-zen/why-gos-closure-can-be-dangerous-f3e5ad0b9fce](https://medium.com/code-zen/why-gos-closure-can-be-dangerous-f3e5ad0b9fce)
* [https://hwan-shell.tistory.com/339](https://hwan-shell.tistory.com/339)