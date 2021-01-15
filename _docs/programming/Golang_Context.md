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

[Code 1]은 Context를 선언하고 함수에 전달하는 방법을 나타내고 있다. Context 객체는 context.Background() 함수를 통해서 얻는다. Context.Background()를 통해서 얻은 Context 객체는 어떠한 값도 갖지 않는 비어있는 상태이다. Golang에서는 Context 객체를 함수로 전달할때는 Struct에 포함하여 전달하지 않고 Context 객체 자체를 함수의 Parameter로 전달하는 것을 권장한다.

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

[Code 2]에서는 WithValue() 함수를 통해서 Key, Value가 설정된 새로운 Context 객채를 생성한 다음, 함수의 Parameter로 넘겨주는 것을 확인할 수 있다. [Code 2]를 실행하면 [Shell 1]의 내용처럼 key, value 문자열을 출력한다.

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

Context 객체를 이용하여 취소 Signal을 전송할 수 있다. [Code 3]은 Context 객체를 이용하여 취소 Signal을 전송하는 예제이다. WithCancel() 함수를 통해서 취소 Signal을 받을수 있도록 설정된 새로운 Context 객체와, 해당 Context 객체에 취소 Signal을 전송하는 cancel() 함수를 얻는다.

Context 객체를 받은 함수안에서는 Context 객체의 Done() 함수를 통해서 취소 Signal이 전달되는 Channel을 얻을 수 있다. 여기서 취소 Signal은 Channel을 통해서 어떠한 값이 전달되는 것이 아니라, Channel이 닫히는 것을 의미한다. [Code 3]에서 Main 함수에서 cancel() 함수가 호출되면 Channel이 닫히게 되고, Done() 함수의 Channel을 통해서 대기하던 Goroutine은 Channel이 닫힌것을 확인하고 종료된다.

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
    cancel() // Although not required, it is recommended to call cancel()
}

{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] Context를 이용한 Timeout 예제</figcaption>
</figure>

### 2. Context Example

### 3. 참조

* [https://golang.org/pkg/context/](https://golang.org/pkg/context/)
* [https://www.popit.kr/go%EC%96%B8%EC%96%B4%EC%97%90%EC%84%9C-context-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0/](https://www.popit.kr/go%EC%96%B8%EC%96%B4%EC%97%90%EC%84%9C-context-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0/)
* [https://devjin-blog.com/golang-context/](https://devjin-blog.com/golang-context/)