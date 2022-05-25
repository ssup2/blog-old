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

Golang의 testing Package에서는 Unit Test를 위한 기능뿐만 아니라 Benchmarking 기능도 제공한다. [Code 1]은 Benchmarking을 위한 함수를 나타내고 있다. [Code 1]에서 SumRange01(), SumRange02() 함수는 특정 범위의 숫자의 합을 구하는 함수이고 이다. SumRange01() 함수는 O(n)의 시간 복잡도, O(1)의 공간 복잡도를 가지고 있고, SumRange02() 함수는 O(1)의 시간 복잡도, O(1)의 공간 복잡도를 가지고 있다. Append() 함수는 Slice에 1을 추가하는 함수이다. O(n)의 시간 복잡도, O(1)의 공간 복잡도를 가지고 있다.

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

[Code 2]는 [Code 1] 함수의 Benchmarking을 위한 Test Code를 나타내고 있다. Benchmarking을 위한 함수는 반드시 "Benchmark" 이름으로 시작해야 한다. Benchmarking을 수행하는 함수는 "b.N"번 만큼 구동되도록 작성되어야 한다. "b.N"은 고정된 값이 아니며, Benchmarking을 수행할때 Option에 따라서 동적으로 할당되는 값이다.

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

[Shell 1]은 Benchmarking을 수행하는 모습을 나타내고 있다. "-bench" Option을 통해서 Benchmarking을 수행한다. Benchmarking 함수명이 나오고 "-12" 숫자가 명시되어 있는데, Benchmarking을 수행할때 이용한 CPU Core 개수를 의미한다. GOMAXPROCS 환경변수를 통해서 설정할 수 있다. 중간의 단위가 없는 숫자(495760, 1000000000, 28550)는 각 Loop(함수)를 수행한 횟수를 의미하며, ns/op 단위의 숫자는 각 Loop가 한번 실행되는데 걸리는 시간을 의미한다. SumRange02() 함수의 시간 복잡도가 SumRange01() 함수보다 낮기 때문에, Benchmarking 결과에서도 더 빠른것을 확인할 수 있다.

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

[Shell 2]는 Memory 관련 Benchmarking 결과도 보여주는 "-benchmem" Option과 함께 Benchmarking을 수행하는 모습을 나타낸다. [Shell 1]에 대비하여 B/op 단위의 숫자와 allocs/op 단위의 숫자가 추가된 것을 알 수 있다. B/op 단위의 숫자는 Loop를 한번 수행할때 할당되는 Memory 양을 의미하며, allocs/op 단위의 숫자는 Loop를 한번 수행할때 Memory 할당 횟수를 의미한다.

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

[Shell 3]은 여러번 Benchmarking 함수를 구동할 수 있는 "-count" Option을 수행하는 모습을 나타낸다. count 값이 5이기 때문에 5번씩 Benchmarking 함수를 수행하는 것을 확인할 수 있다.

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

[Shell 4]는 benchtime Option을 통해서 Benchmarking을 최대 몇초동안 수행할지 설정하는 모습을 나타낸다. "s"로 끝나면 초를 의미하기 때문에 [Shell 4]에서는 Benchmarking을 10초 동안 수행한다. [Shell 5]는 benchtime Option을 통해서 Loop를 최대 몇회 수행할지 설정하는 모습을 나타낸다. "x"로 끝나면 Benchmarking Loop를 의미하기 때문에 [Shell 5]에서는 각 Benchimarking 함수는 10번씩만 Loop를 수행한 것을 확인할 수 있다.

### 2. 참조

* [https://blog.logrocket.com/benchmarking-golang-improve-function-performance/](https://blog.logrocket.com/benchmarking-golang-improve-function-performance/)