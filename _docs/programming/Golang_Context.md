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
<figcaption class="caption">[Code 1] Context 선언 및 전달 예제</figcaption>
</figure>

[Code 1]은 Context 객체를 선언하고 함수에 전달하는 방법을 나타내고 있다. Context 객체는 context.Background() 함수를 통해서 얻는다. Context.Background()를 통해서 얻은 Context 객체는 어떠한 값도 갖지 않는 비어있는 상태이다. Golang에서는 Context 객체를 함수로 전달할때는 Struct에 포함하여 전달하지 않고 Context 객체 자체를 함수의 Parameter로 전달하는 것을 권장한다.

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

Context 객체는 Key-Value 기반의 Value를 저장할수 있는 공간을 제공한다. [Code 2]는 Context에 Key, Value를 저장한 다음 함수에서 저장한 Key, Value를 출력하는 예제이다. Context 객체는 한번 생성이되면 객체안의 값을 변경할 수 없다. 오직 기존 Context를 객체의 내용을 기반으로 새로운 Context 객체를 생성해서 이용해야한다. 이러한 특징 때문에 context Package는 WithXXXX() 함수를 제공한다. WithXXX() 함수는 Context를 객체를 받은 다음 필요한 값을 설정한 새로운 Context 객체를 반환한다.

[Code 2]에서는 WithValue() 함수를 통해서 Key, Value가 설정된 새로운 Context 객채를 생성한 다음, function() 함수의 Parameter로 넘겨주는 것을 확인할 수 있다. [Code 2]를 실행하면 [Shell 1]의 내용처럼 key, value 문자열을 출력한다.

#### 1.3. 취소 Signal

{% highlight golang linenos %}
package main

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
                fmt.Printf("err:%s\n", ctx.Err())
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
err:context canceled
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Context를 이용한 취소 Signal 전송 예제의 출력</figcaption>
</figure>

Context 객체를 이용하여 취소 Signal을 전송할 수 있다. [Code 3]은 Context 객체를 이용하여 취소 Signal을 전송하는 예제이다. WithCancel() 함수를 통해서 취소 Signal을 받을수 있도록 설정된 새로운 Context 객체와, 해당 Context 객체에 취소 Signal을 전송하는 cancel() 함수를 얻는다. 얻은 Context 객체의 Done() 함수를 통해서 취소 Signal이 전달되는 Channel을 얻을 수 있다. 여기서 취소 Signal은 Channel을 통해서 어떠한 값이 전달되는 것이 아니라, Channel이 닫히는 것을 의미한다.

[Shell 2]는 [Code 3]을 실행하였을때의 출력을 나타낸다. [Code 3]에서 Main 함수는 5초뒤에 cancel() 함수를 호출한다. function() 함수가 생성한 Goroutine은 5초동안 1초 간격으로 변수 n을 5번 출력하고 종료된다. Context 객체의 Err() 함수는 Done() 함수를 통해서 전달되는 Channel이 왜 닫혔는지를 알려주는 Error 객체를 Return 한다. [Shell 2]에서 Context 객체가 취소되어 (cancel() 함수가 호출되어) Channel이 닫혔다는 내용도 출력된것을 확인할 수 있다.

#### 1.4. Deadline, Timeout

{% highlight golang linenos %}
package main

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
                fmt.Printf("err:%s\n", ctx.Err())
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
    cancel() // Although not required, it is recommended to call cancel()
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
cancel context deadline exceeded
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Context를 이용한 Request 취소 Code의 출력</figcaption>
</figure>

Context 객체를 이용하여 Deadline 기능을 쉽게 구현할 수 있다. [Code 4]는 Context 객체를 이용하여 Deadline을 구현하는 예제이다. WithDeadline() 함수를 통해서 Deadline 만료 Signal 및 취소 Signal을 받을수 있도록 설정된 새로운 Context 객체와, 해당 Context 객체에 취소 Signal을 전송하는 cancel() 함수를 얻는다.

얻은 Context 객체의 Done() 함수를 통해서 Deadline 만료 Signal 또는 취소 Signal이 전달되는 Channel을 얻을 수 있다. 여기서 Deadline 만료 Signal 또는 취소 Signal은 Channel을 통해서 어떠한 값이 전달되는 것이 아니라, Channel이 닫히는 것을 의미한다. Deadline이 만료되면 별도의 cancel() 함수가 호출되지 않더라도 Done() 함수를 통해서 얻은 Channel은 닫힌다. 또는 Deadline에 임박하지 않더라도, cancel() 함수를 호출하여 Done() 함수를 통해서 얻은 Channel을 닫을 수 있다.

[Shell 3]은 [Code 4]를 실행하였을때의 출력을 나타낸다. [Code 4]에서는 Deaeline을 현재시간을 기준으로 5초를 이후로 설정하였다. 따라서 function() 함수가 생성한 Goroutine은 5초동안 1초 간격으로 변수 n을 5번 출력하고 종료된다. main 함수에 cancel()은 호출될 필요는 없지만, Golang에서는 다양한 상황을 위해서 가능하면 cancel() 함수를 적절한 시점에 호출하도록 권장하고 있다. Context 객체의 Err() 함수를 통해서 Context 객체의 Deaeline이 만료되어 Channel이 닫혔다는 내용도 출력된것을 확인할 수 있다.

{% highlight golang linenos %}
package main

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
                fmt.Printf("err:%s\n", ctx.Err())
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
    cancel() // Although not required, it is recommended to call cancel()
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] Context를 이용한 Timeout 예제</figcaption>
</figure>

Context는 Deadline 기능을 활용하여 Timeout 기능도 제공한다. [Code 5]는 Context 객체를 이용하여 Timeout을 구현하는 예제이다. WithTimeout() 함수를 이용하여 Timeout 만료 Signal 및 취소 Signal을 받을수 있도록 설정된 새로운 Context 객체와, 해당 Context 객체에 취소 Signal을 전송하는 cancel() 함수를 얻는다. `WithTimeout(ctx Context, timeout time.Duration)`는 `WithDeadline(ctx Context, time.Now().Add(timeout))`와 동일하다. 따라서 [Code 5]는 [Code 4]와 동일한 동작을 수행한다.

### 2. Context Example

{% highlight golang linenos %}
package main

import (
    "fmt"
    "net/http"
    "time"
)

func hello(w http.ResponseWriter, req *http.Request) {
    // Get context from request and set Request ID
    ctx := context.WithValue(req.Context(), "requestID", req.Header.Get("X-Request-Id"))

    select {
    // Write response
    case <-time.After(5 * time.Second):
        fmt.Fprintf(w, "hello\n")
    // Process error
    case <-ctx.Done():   
        err := ctx.Err()
        fmt.Printf("requestID:%s err:%s", ctx.Value("requestID"), err)
        http.Error(w, err.Error(), http.StatusInternalServerError)
    }
}

func main() {
    // Set HTTP handler
    http.HandleFunc("/hello", hello)

    // Serve
    http.ListenAndServe(":8080", nil)
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] Context를 이용한 HTTP Server 예제</figcaption>
</figure>

[Code 5]는 Context를 이용하는 HTTP Server의 예제를 나타내고 있다. Context 객체는 하나의 Client의 Request를 처리하는 과정 동안에만 이용되기 때문에, 일반적으로 HTTP Request Handler 가장 윗부분에 Context 객채를 선언하고 초기화 한다. http.Request 객체는 Context() 함수를 통해서 취소 Signal을 받을 수 있는 Context 객체를 반환한다. Context 객체는 취소 Signal을 Client에서 먼저 Connection을 종료할 경우 전달된다.

[Code 5]에서 HTTP Handler인 hello() 함수의 첫 부분에 http.Request 객체는 Context() 함수를 통해서 Context 객채를 받은 다음, 받은 Context 객체에 "X-Request-Id" HTTP Header의 값을 저장하는 것을 확인할 수 있다. hello() 함수는 Client의 요청을 받으면 5초 대기후에 "hello" 문자열을 반환한다. 하지만 Client가 5초가 되기전에 먼저 Connection을 끊는다면, Error Log를 남기고 요청 처리를 중단한다.

### 3. 참조

* [https://golang.org/pkg/context/](https://golang.org/pkg/context/)
* [https://www.popit.kr/go%EC%96%B8%EC%96%B4%EC%97%90%EC%84%9C-context-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0/](https://www.popit.kr/go%EC%96%B8%EC%96%B4%EC%97%90%EC%84%9C-context-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0/)
* [https://devjin-blog.com/golang-context/](https://devjin-blog.com/golang-context/)
* [https://gobyexample.com/context](https://gobyexample.com/context)