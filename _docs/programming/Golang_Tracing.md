---
title: Golang Tracing
category: Programming
date: 2022-06-13T12:00:00Z
lastmod: 2022-06-13T12:00:00Z
comment: true
adsense: true
---

Golang의 Tracing 기법을 정리한다.

### 1. Tracing 수행 방법

Golang에서 이용 가능한 Tracing 수행 방법을 정리한다. Tracing을 통해서 어디서 지연이 발생하는지 추적할 수 있다.

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

net/http/pprof Package는 Server와 같이 계속 동작중인 App의 Tracing을 위해서 이용되는 Package이다. pprof Package를 이용하면 App의 Trace를 얻을 수 있는 HTTP Endpoint를 간단하게 생성할 수 있다. [Code 1]은 net/http/pprof Package의 사용 방법을 나타내고 있다. net/http/pprof Package를 초기화 하고, http Package를 통해서 HTTP Server를 구동하면 된다.

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

[Code 2]는 net/http/pprof Package 초기화시 호출되는 init() 함수를 나타내고 있다. 5개의 HTTP Endpoint를 HTTP Server에 등록하는 것을 확인할 수 있다. 이중에 "/debug/pprof/trace" Endpoint를 통해서 Trace를 얻을 수 있다. "seconds" Query String을 통해서 몇 초 동안 Profiling을 수행할지 설정할 수 있다.

* http://localhost:6060/debug/pprof/trace?seconds=30

#### 1.2. runtime/trace Package

{% highlight golang linenos %}
package main

import (
	"flag"
	"log"
	"os"
	"runtime/trace"
)

var traceFile = flag.String("trace", "", "write trace `file`")

func main() {
	flag.Parse()

	// Set trace file
	if *traceFile != "" {
		f, err := os.Create(*traceFile)
		if err != nil {
			log.Fatal("could not create trace: ", err)
		}
		if err := trace.Start(f); err != nil {
			log.Fatal("could not start trace: ", err)
		}
		defer trace.Stop()
	}

    ...
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] runtime/profile Package Example</figcaption>
</figure>

#### 1.3. Unit Test

{% highlight console %}
# go test ./... -trace trace.out 
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Test Profile Example</figcaption>
</figure>

Golang에서는 Unit Test를 수행할때 같이 Tracing 수행도 가능하다. [Console 1]은 Trace 생성과 함께 Test를 수행하는 예제를 나타내고 있다.

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

# gops trace 23968
Tracing now, will take 5 secs...
Trace dump saved to: /tmp/trace2991957244
2022/06/15 00:05:14 Parsing trace...
2022/06/15 00:05:15 Splitting trace...
2022/06/15 00:05:17 Opening browser. Trace viewer is listening on http://127.0.0.1:42519
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] gops CLI Example</figcaption>
</figure>

### 2. pprof

### 3. 참조

* [https://pkg.go.dev/cmd/trace](https://pkg.go.dev/cmd/trace)