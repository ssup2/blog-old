---
title: Golang Context
category: Programming
date: 2020-12-10T12:00:00Z
lastmod: 2020-12-10T12:00:00Z
comment: true
adsense: true
---

Golang의 Context를 분석한다

### 1. Golang Context Type

Golang의 Context는 Client으로부터 전달된 하나의 Request를 처리하면서 유지 되어야할 Context를 저장하는데 이용되는 변수이다. 각 Request 사이의 유지되어야 하는 Context가 아닌 하나의 Request 안에서 (Request-Scope) 공유되어야 하는 Context를 저장하는 용도로 이용된다. Context를 통해서 Request동안 유지되어야 하는 Value 저장 공간을 얻을 수 있고, 취소 Signal 전송 및 Deadline 기능을 쉽게 구현할 수 있다.

#### 1.1. 선언 및 전달

{% highlight golang linenos %}
package main

import (
    "context"
    "fmt"
)

func function(ctx context, n int) {
...
}

func main() {
    ctx := context.Background()
    function(ctx, 0)
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Context 선언 및 전달</figcaption>
</figure>

#### 1.2. Value 저장

{% highlight golang linenos %}
package main

import (
    "context"
    "fmt"
)

func function(ctx context.Context, k var key string) {
    // Print key and value
    fmt.Printf("key:%s, value:%s\n", key, ctx.Value(key))
}

func main() {
    // Set key, value
    key := "key"
    value := "value"

    // Init context with key, value
    ctx := context.Background()
    ctxValue := context.WithValue(ctx, key, value)

    // Call function
    function(ctxValue, key)
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] Context에 Value 저장 예제</figcaption>
</figure>

{% highlight console %}
key:key, value:value
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Context에 Value 저장 예제의 출력</figcaption>
</figure>

#### 1.3. 취소 Signal

{% highlight golang linenos %}
import (
    "context"
    "fmt"
    "time"
)

func function(ctx context.Context) {
    n := 1
    go func() {
        for {
            select {
            // Get cancellation signal and exit goroutine 
            case <-ctx.Done():
                fmt.Print("cancel\n")
                return

            // Increase and Print n
            default:
                fmt.Printf("n:%d\n", n)
                time.Sleep(1 * time.Second)
                n++
            }
        }
    }()
}

func main() {
    // Init context with Cancellation
    ctx := context.Background()
    ctxCancel, cancel := context.WithCancel(ctx)

    // Call function
    function(ctxCancel)

    // Sleep and call cancel()
    go func() {
        time.Sleep(5 * time.Second)
        cancel()
    }()

    // Sleep to wait cancel goroutine
    time.Sleep(10 * time.Second)
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] Context를 이용한 취소 Signal 전송 예제</figcaption>
</figure>

{% highlight console %}
n:1
n:2
n:3
n:4
n:5
cancel
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Context를 이용한 취소 Signal 전송 예제의 출력</figcaption>
</figure>

#### 1.4. Deadline, Timeout

{% highlight golang linenos %}
import (
    "context"
    "fmt"
    "time"
)

func function(ctx context.Context) {
    n := 1
    go func() {
        for {
            select {
            // Get cancellation signal and exit goroutine 
            case <-ctx.Done():
                fmt.Print("cancel\n")
                return

            // Increase and Print n
            default:
                fmt.Printf("n:%d\n", n)
                time.Sleep(1 * time.Second)
                n++
            }
        }
    }()
}

func main() {
    // Set deadline
    deadline := time.Now().Add(5 * time.Second)

    // Init context with deadline
    ctx := context.Background()
    ctxDeadline, cancel := context.WithDeadline(ctx, deadline)

    // Call function
    function(ctxDeadline)

    // Sleep to wait deadline
    time.Sleep(10 * time.Second)
    cancel() // 
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] Context를 이용한 Deadline 예제</figcaption>
</figure>

{% highlight console %}
n:1
n:2
n:3
n:4
n:5
cancel
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Context를 이용한 Request 취소 Code의 출력</figcaption>
</figure>

{% highlight golang linenos %}
import (
    "context"
    "fmt"
    "time"
)

func function(ctx context.Context) {
    n := 1
    go func() {
        for {
            select {
            // Get cancellation signal and exit goroutine 
            case <-ctx.Done():
                fmt.Print("cancel\n")
                return

            // Increase and Print n
            default:
                fmt.Printf("n:%d\n", n)
                time.Sleep(1 * time.Second)
                n++
            }
        }
    }()
}

func main() {
    // Set timeout
    timeout := 5 * time.Second

    // Init context with timeout
    ctx := context.Background()
    ctxDeadline, cancel := context.WithTimeout(ctx, timeout)

    // Call function
    function(ctxDeadline)

    // Sleep to wait timeout
    time.Sleep(10 * time.Second)
    cancel()
}

{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] Context를 이용한 Timeout 예제</figcaption>
</figure>

### 2. 참조

* [https://golang.org/pkg/context/](https://golang.org/pkg/context/)
* [https://www.popit.kr/go%EC%96%B8%EC%96%B4%EC%97%90%EC%84%9C-context-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0/](https://www.popit.kr/go%EC%96%B8%EC%96%B4%EC%97%90%EC%84%9C-context-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0/)
* [https://devjin-blog.com/golang-context/](https://devjin-blog.com/golang-context/)