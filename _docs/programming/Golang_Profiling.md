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

Golang에서 이용 가능한 Profiling 수행 방법을 정리한다.

#### 1.1. net/http/pprof Package

net/http/pprof Package는 Server와 같이 계속 동작중인 App의 Profiling을 위해서 이용되는 Package이다. pprof Package를 이용하면 App에 Profile을 얻을 수 있는 HTTP Endpoint를 간단하게 생성할 수 있다.

{% highlight golang linenos %}
package main

import (
    "http"
	_ "net/http/pprof"
    ...
)

func main() {
    // Run http server with 8080 port
	go func() {
		http.ListenAndServe("localhost:8080", nil)
	}()
    ...
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] net/http/pprof Package Example</figcaption>
</figure>

[Code 1]은 net/http/pprof Package의 사용 방법을 나타내고 있다. net/http/pprof Package를 초기화 하고, http Package를 통해서 HTTP Server를 구동하면 된다.

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

[Code 2]는 net/http/pprof Package 초기화시 호출되는 init() 함수를 나타내고 있다. 5개의 HTTP Endpoint를 HTTP Server에 등록하는 것을 확인할 수 있다. 등록된 HTTP Endpoint 중에서 /debug/pprof/profile Endpoint를 통해서 Profile을 획득할 수 있다.

#### 1.2. runtime/pprof Package

runtime/profile Package는 CLI (Command Line Interface)와 같이 한번 실행이되고 종료되는 App의 Profiling을 위해서 이용되는 Package이다.

{% highlight golang linenos %}
package main

import (
	"fmt"
	"log"
	"net/http"
	"runtime"
	"runtime/pprof"
	"time"
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
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] runtime/profile Package Example</figcaption>
</figure>

#### 1.3. Unit Test

Golang에서는 Unit Test를 수행할때 같이 Profiling 수행도 가능하다.

### 2. Profile 종류, 분석

#### 2.1. CPU

#### 2.2. Heap

#### 2.3. Thread Create

#### 2.4. Goroutine

#### 2.5. Block

#### 2.6. Mutex

### 3. 참조

* [https://github.com/DataDog/go-profiler-notes/blob/main/guide/README.md](https://github.com/DataDog/go-profiler-notes/blob/main/guide/README.md)
* [https://hackernoon.com/go-the-complete-guide-to-profiling-your-code-h51r3waz](https://hackernoon.com/go-the-complete-guide-to-profiling-your-code-h51r3waz)
* [https://go.dev/doc/diagnostics](https://go.dev/doc/diagnostics)
* [https://github.com/google/pprof](https://github.com/google/pprof)
* [https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/)
* [https://medium.com/a-journey-with-go/go-how-does-gops-interact-with-the-runtime-778d7f9d7c18](https://medium.com/a-journey-with-go/go-how-does-gops-interact-with-the-runtime-778d7f9d7c18)
* [https://riptutorial.com/go/example/25406/basic-cpu-and-memory-profiling](https://riptutorial.com/go/example/25406/basic-cpu-and-memory-profiling)