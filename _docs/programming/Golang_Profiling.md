---
title: Golang Profiling
category: Programming
date: 2022-05-18T12:00:00Z
lastmod: 2022-05-18T12:00:00Z
comment: true
adsense: true
---

Golang의 Profiling 기법을 정리한다.

### 1. Profiling 수행 방법

Golang에서 이용 가능한 Profiling 수행 방법을 정리한다. Profiling을 통해서 함수별 Resource (CPU, Memory, Mutex, Goroutine, Thread) 사용률을 얻을수 있다.

#### 1.1. net/http/pprof Package

{% highlight golang linenos %}
package main

import (
    "http"
	_ "net/http/pprof"
    ...
)

func main() {
    // Run http server with 6060 port
	go func() {
		http.ListenAndServe("localhost:6060", nil)
	}()
    ...
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] net/http/pprof Package Example</figcaption>
</figure>

net/http/pprof Package는 Server와 같이 계속 동작중인 App의 Profiling을 위해서 이용되는 Package이다. pprof Package를 이용하면 App에 Profile을 얻을 수 있는 HTTP Endpoint를 간단하게 생성할 수 있다. [Code 1]은 net/http/pprof Package의 사용 방법을 나타내고 있다. net/http/pprof Package를 초기화 하고, http Package를 통해서 HTTP Server를 구동하면 된다.

{% highlight golang linenos %}
func init() {
	http.HandleFunc("/debug/pprof/", Index)
	http.HandleFunc("/debug/pprof/cmdline", Cmdline)
	http.HandleFunc("/debug/pprof/profile", Profile)
	http.HandleFunc("/debug/pprof/symbol", Symbol)
	http.HandleFunc("/debug/pprof/trace", Trace)
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] net/http/pprof init() Function</figcaption>
</figure>

[Code 2]는 net/http/pprof Package 초기화시 호출되는 init() 함수를 나타내고 있다. 5개의 HTTP Endpoint를 HTTP Server에 등록하는 것을 확인할 수 있다. [Code 2]에는 나타나지 않지만 Index Handler 하위에도 다양한 Profile을 얻을 수 있는 Endpoint들이 존재한다. 다음의 Endpoint들을 대상으로 "Get" 요청을 통해서 다음의 Profile들을 얻을 수 있다.

* CPU : http://localhost:6060/debug/pprof/profile
* Memory Heap : http://localhost:6060/debug/pprof/heap
* Block : http://localhost:6060/debug/pprof/block
* Thread Create : http://localhost:6060/debug/pprof/threadcreate
* Goroutine : http://localhost:6060/debug/pprof/goroutine
* Mutex : http://localhost:6060/debug/pprof/mutex

"seconds" Query String을 통해서 몇 초 동안 Profiling을 수행할지 설정할 수 있다.

* seconds : http://localhost:6060/debug/pprof/profile?seconds=30

#### 1.2. runtime/pprof Package

{% highlight golang linenos %}
package main

import (
	"flag"
	"log"
	"runtime"
	"runtime/pprof"
)

var cpuprofile = flag.String("cpuprofile", "", "write cpu profile `file`")
var memprofile = flag.String("memprofile", "", "write memory profile to `file`")

func main() {
    flag.Parse()

	// Set CPU profile
    if *cpuprofile != "" {
        f, err := os.Create(*cpuprofile)
        if err != nil {
            log.Fatal("could not create CPU profile: ", err)
        }
        if err := pprof.StartCPUProfile(f); err != nil {
            log.Fatal("could not start CPU profile: ", err)
        }
        defer pprof.StopCPUProfile()
    }

	// Set memory (heap) profile
    if *memprofile != "" {
        f, err := os.Create(*memprofile)
        if err != nil {
            log.Fatal("could not create memory profile: ", err)
        }
        runtime.GC() // Get up-to-date statistics
        if err := pprof.WriteHeapProfile(f); err != nil {
            log.Fatal("could not write memory profile: ", err)
        }
        f.Close()
    }
	...
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] runtime/profile Package Example</figcaption>
</figure>

runtime/profile Package는 CLI (Command Line Interface)와 같이 한번 실행이되고 종료되는 App의 Profiling을 위해서 이용되는 Package이다. [Code 3]은 runtime/profile Package의 예제를 나타내고 있다. runtime/profile Package는 CPU와 Memory Heap Profile, 두 가지 Profile만 얻을 수 있다.

CPU Profile을 얻기 위해서는 Profiling의 시작 부분에서 StartCPUProfile() 함수를 호출하고, Profiling의 끝 부분에서 StopCPUProfile() 함수를 호출하면 된다. Memory Profile을 얻기 위해서는 GC() 함수를 호출한 다음 WriteHeapProfile() 함수를 호출하면 된다.

#### 1.3. Unit Test

{% highlight console %}
# go test ./... -cpuprofile cpu.out -memprofile mem.out -blockprofile block.out -mutexprofile mutex.out
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Test Profile Example</figcaption>
</figure>

Golang에서는 Unit Test를 수행할때 같이 Profiling 수행도 가능하다. [Console 1]은 Profile 생성과 함께 Test를 수행하는 예제를 나타내고 있다. CPU, Memory, Block, Mutex Profile을 얻을 수 있다.

#### 1.4. github.com/google/gops Package & gops CLI

{% highlight golang linenos %}
package main

import (
	"github.com/google/gops/agent"
)

func main() {
    // Run gops agent
	go func() {
		agent.Listen(agent.Options{})
	}()
	...
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] github.com/google/gops Package Example</figcaption>
</figure>

{% highlight console %}
# gops
23469 23364 gopls  go1.18.1 /root/go/bin/gopls
23846 23395 go     go1.18.1 /usr/local/go/bin/go
23968 23846 main   go1.18.1 /tmp/go-build306237982/b001/exe/main
24262 23995 gops   go1.18.1 /root/go/bin/gops

# gops pprof-cpu 23968
Profiling CPU now, will take 30 secs...gops
Profiling CPU now, will take 30 secs...
Profile dump saved to: /tmp/cpu_profile2976012992
Binary file saved to: /tmp/binary3401790069
File: binary3401790069
Type: cpu
Time: Jun 12, 2022 at 11:44pm (KST)
Duration: 30.18s, Total samples = 85.70s (283.97%)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) 

# gops pprof-heap 23968
Profile dump saved to: /tmp/heap_profile2558761742
Binary file saved to: /tmp/binary2141405164
File: binary2141405164
Type: inuse_space
Time: Jun 12, 2022 at 11:48pm (KST)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) 
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] gops CLI Example</figcaption>
</figure>

github.com/google/gops Package와 gops CLI를 통해서도 Server와 같이 계속 동작중인 App의 Profiling을 수행할 수 있다. CPU와 Memory Heap Profile만 얻을 수 있다. [Code 4]는 github.com/google/gops Package의 사용법을 나타내고 있다. gops Agent를 구동시키면 된다. 이후에 [Console 2]의 내용과 같이 gops 명령어를 통해서 PID를 조회한 다음 gops pprof-cpu, gops pprof-heap 명령어를 통해서 CPU, Memory Profile 획득 및 pprof를 실행한다.

### 2. pprof

얻은 Profile은 Golang 설치시 같이 설치되는 [pprof](https://github.com/google/pprof) 도구를 통해서 시각화가 가능하다. `-http [Port]` Option을 같이 설정하면 Web Browser를 통해서 "localhost:[Port]"에 접속하여 시각화된 Profile을 얻을 수 있다. Top, Graph, Flame Graph, Peek와 같은 형태로 시각화를 제공한다.

{% highlight console %}
# go tool pprof -http :8080 [Profile HTTP Endpoint]
# go tool pprof -http :8080 [Profile File]
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] Run pprof with CPU profile</figcaption>
</figure>

[Console 3]은 pprof 사용법을 나타내고 있다. `-http` Option과 함께 net/http/pprof Package를 통해서 설정되는 Profile HTTP Endpoint나 runtime/pprof Package 또는 Test를 통해서 얻은 Profile File을 지정하면 된다.

#### 2.1. Flat, Cum

{% highlight golang linenos %}
func OutterFunc() {
	InnerFunc() // step1
	InnerFunc() // step2
	i := 0      // step3
	i++         // step4
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] Flat, Cum Example</figcaption>
</figure>

pprof를 통해서 시각회된 Profile을 이해하기 위해서는 **Flat**과 **Cum**의 개념을 알고 있어야 한다. [Code 4]는 Flat과 Cum 설명을 위한 예제 Code를 나타내고 있다. Flat은 함수가 직접적으로 수행하는 Action의 부하를 나타낸다. 따라서 [Code 4]에서 OutterFunc() 함수의 Flat은 Step3, Step4만 포함된다. Cum은 함수가 실행되기 위한 모든 Action의 부하를 나타낸다. 다른 함수의 호출로 인해서 발생하는 부하도 Cum에 포함된다. 따라서 [Code 5]에서 OutterFunc() 함수의 Cum에는 Step1 ~ Step4가 포함된다.

### 3. Profile 종류, 분석

Profile 종류 및 분석은 아래의 예제 App을 통해서 진행한다. Profile은 net/http/pprof Package를 통해서 6060 Port를 통해서 노출되도록 설정되어 있으며, 부하를 주기 위한 다양한 함수들이 구동되도록 개발되어 있다.

* Example App : [https://github.com/ssup2/golang-pprof-example](https://github.com/ssup2/golang-pprof-example)

#### 3.1. CPU

{% highlight golang linenos %}
package cpu

func IncreaseInt() {
	i := 0
	for {
		i = increase1000(i)
		i = increase2000(i)
	}
}

func IncreaseIntGoroutine() {
	go func() {
		i := 0
		for {
			i = increase1000(i)
			i = increase2000(i)
		}
	}()
}

func increase1000(n int) int {
	for n := 0; n < 1000; n++ {
		n = n + 1
	}
	return n
}

func increase2000(n int) int {
	for n := 0; n < 1000; n++ {
		n = n + 1
	}
	return n
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 6] CPU Profiling Example Code</figcaption>
</figure>

{% highlight console %}
# go tool pprof -http :8080 http://localhost:6060/debug/pprof/profile\?seconds\=30
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 4] Run pprof with CPU profile</figcaption>
</figure>

CPU Profile을 통해서 함수별 CPU 사용률을 얻을 수 있다. [Code 6]은 CPU Profiling을 위한 예제 Code를 나타내고 있고, [Console 4]는 Example App을 통해서 30초 동안의 CPU Profile을 얻은 다음 pprof를 구동하는 모습을 나타내고 있다.

![[그림 1] CPU Profile Top]({{site.baseurl}}/images/programming/Golang_Profiling/Profile_CPU_Top.PNG){: width="700px"}

[그림 1]은 CPU 사용률이 높은 함수를 순서대로 나타내고 있다. Increase2000() 함수가 Increase1000() 함수에 비해서 2배더 증가 연산을 수행하는 만큼 Cum도 2배더 높은것을 확인할 수 있다. Increase2000(), Increase1000() 함수 모두 내부에서 함수를 호출하지 않기 때문에 각 함수의 Flat과 Cum이 동일한 것을 알 수 있다. 반면에 IncreaseInt() 함수와 IncreaseIntGoroutine() 함수 내부에서 실행되는 함수는 Goroutine은 별도의 연산을 수행하지 않고, Increase2000(), Increase1000() 함수에 의존하기 때문에 Flat은 매우 낮지만, Cum은 높은것을 확인할 수 있다.

30초 동안의 CPU Profile을 얻었기 때문에 Profiling 중에 IncreaseInt() 함수와 IncreaseIntGoroutine() 함수 내부에 실행되는 함수는 별도의 Goroutine에서 각각 30초 동안 수행되된다. 따라서 전체 총 60초 동안 Goroutine이 수행되며, Increase2000(), Increase1000() 함수의 총 Cum이 약 60초인것을 확인할 수 있다.

![[그림 2] CPU Profile Graph]({{site.baseurl}}/images/programming/Golang_Profiling/Profile_CPU_Graph.PNG){: width="650px"}

[그림 2]는 CPU 사용률 및 함수 사이의 의존성을 나타내고 있다.

#### 3.2. Memory Heap

#### 3.3. Block

#### 3.4. Thread Create

#### 3.5. Goroutine

#### 3.6. Mutex

### 4. 참조

* [https://github.com/DataDog/go-profiler-notes/blob/main/guide/README.md](https://github.com/DataDog/go-profiler-notes/blob/main/guide/README.md)
* [https://hackernoon.com/go-the-complete-guide-to-profiling-your-code-h51r3waz](https://hackernoon.com/go-the-complete-guide-to-profiling-your-code-h51r3waz)
* [https://go.dev/doc/diagnostics](https://go.dev/doc/diagnostics)
* [https://pkg.go.dev/net/http/pprof](https://pkg.go.dev/net/http/pprof)
* [https://github.com/google/pprof](https://github.com/google/pprof)
* [https://github.com/google/gops](https://github.com/google/gops)
* [https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/)
* [https://medium.com/a-journey-with-go/go-how-does-gops-interact-with-the-runtime-778d7f9d7c18](https://medium.com/a-journey-with-go/go-how-does-gops-interact-with-the-runtime-778d7f9d7c18)
* [https://riptutorial.com/go/example/25406/basic-cpu-and-memory-profiling](https://riptutorial.com/go/example/25406/basic-cpu-and-memory-profiling)
* [https://stackoverflow.com/questions/32571396/pprof-and-golang-how-to-interpret-a-results](https://stackoverflow.com/questions/32571396/pprof-and-golang-how-to-interpret-a-results)