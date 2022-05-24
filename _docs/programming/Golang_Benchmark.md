---
title: Golang Benchmarking
category: Programming
date: 2022-05-24T12:00:00Z
lastmod: 2022-05-24T12:00:00Z
comment: true
adsense: true
---

Golang에서 제공하는 Benchmarking 기능을 정리한다.

### 1. Golang Benchmarking

{% highlight golang %}
package benchmark

func SumRange01(n, m int) int {
	result := 0
	for i := n; i <= m; i++ {
		result += i
	}
	return result
}

func SumRange02(n, m int) int {
	return ((m - n) / 2) * (m - n)
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] benchmarking.go</figcaption>
</figure>

{% highlight golang %}
package benchmark

import (
	"testing"
)

func BenchmarkSumRange01(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = SumRange01(10, 10000)
	}
}

func BenchmarkSumRange02(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = SumRange02(10, 10000)
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] benchmarking_test.go</figcaption>
</figure>

Golang의 testing Package에서는 Unit Test를 위한 기능뿐만 아니라 Benchmarking 기능도 제공한다.

### 2. 참조

* [https://blog.logrocket.com/benchmarking-golang-improve-function-performance/](https://blog.logrocket.com/benchmarking-golang-improve-function-performance/)