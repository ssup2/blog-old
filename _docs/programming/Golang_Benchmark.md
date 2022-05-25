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

func Append(n int) []int {
	var result []int
	for i := 0; i < n; i++ {
		result = append(result, 1)
	}
	return result
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

func BenchmarkAppend(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = Append(10000)
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] benchmarking_test.go</figcaption>
</figure>

Golang의 testing Package에서는 Unit Test를 위한 기능뿐만 아니라 Benchmarking 기능도 제공한다.

{% highlight console %}
# go test -bench .
goos: linux
goarch: amd64
pkg: ssup2.com/test
cpu: AMD Ryzen 5 3600X 6-Core Processor             
BenchmarkSumRange01-12            495760              2352 ns/op
BenchmarkSumRange02-12          1000000000               0.2337 ns/op
BenchmarkAppend-12                 28550             42003 ns/op
PASS
ok      ssup2.com/test  3.081s
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Benchmarking</figcaption>
</figure>

{% highlight console %}
# go test -bench . -benchmem
goos: linux
goarch: amd64
pkg: ssup2.com/test
cpu: AMD Ryzen 5 3600X 6-Core Processor             
BenchmarkSumRange01-12            502443              2344 ns/op               0 B/op          0 allocs/op
BenchmarkSumRange02-12          1000000000               0.2338 ns/op          0 B/op          0 allocs/op
BenchmarkAppend-12                 29546             42306 ns/op          357628 B/op         19 allocs/op
PASS
ok      ssup2.com/test  3.129s
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Benchmarking with benchmem Option</figcaption>
</figure>

{% highlight console %}
# go test -bench . -count 5 
goos: linux
goarch: amd64
pkg: ssup2.com/test
cpu: AMD Ryzen 5 3600X 6-Core Processor             
BenchmarkSumRange01-12            500970              2352 ns/op
BenchmarkSumRange01-12            509751              2387 ns/op
BenchmarkSumRange01-12            494068              2366 ns/op
BenchmarkSumRange01-12            510322              2358 ns/op
BenchmarkSumRange01-12            456585              2364 ns/op
BenchmarkSumRange02-12          1000000000               0.2357 ns/op
BenchmarkSumRange02-12          1000000000               0.2348 ns/op
BenchmarkSumRange02-12          1000000000               0.2338 ns/op
BenchmarkSumRange02-12          1000000000               0.2344 ns/op
BenchmarkSumRange02-12          1000000000               0.2354 ns/op
BenchmarkAppend-12                 29409             42820 ns/op
BenchmarkAppend-12                 28377             41828 ns/op
BenchmarkAppend-12                 27708             45797 ns/op
BenchmarkAppend-12                 28015             42034 ns/op
BenchmarkAppend-12                 25623             43263 ns/op
PASS
ok      ssup2.com/test  15.482s
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Benchmarking with count Option</figcaption>
</figure>

{% highlight console %}
# go test -bench . -benchtime 10s
goos: linux
goarch: amd64
pkg: ssup2.com/test
cpu: AMD Ryzen 5 3600X 6-Core Processor             
BenchmarkSumRange01-12           5099930              2371 ns/op
BenchmarkSumRange02-12          1000000000               0.2372 ns/op
BenchmarkAppend-12                290082             42028 ns/op
PASS
ok      ssup2.com/test  27.354s
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Benchmarking with benchtime time Option</figcaption>
</figure>

{% highlight console %}
# go test -bench . -benchtime 10x
goos: linux
goarch: amd64
pkg: ssup2.com/test
cpu: AMD Ryzen 5 3600X 6-Core Processor             
BenchmarkSumRange01-12                10              2362 ns/op
BenchmarkSumRange02-12                10                23.00 ns/op
BenchmarkAppend-12                    10             63439 ns/op
PASS
ok      ssup2.com/test  0.006s
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Benchmarking with benchtime execute Option</figcaption>
</figure>

### 2. 참조

* [https://blog.logrocket.com/benchmarking-golang-improve-function-performance/](https://blog.logrocket.com/benchmarking-golang-improve-function-performance/)