---
title: Golang Error Wrapping
category: Programming
date: 2021-05-17T12:00:00Z
lastmod: 2021-05-17T12:00:00Z
comment: true
adsense: true
---

Golang의 Error Wrapping 기법을 정리한다.

### 1. Golang Error Wrapping

{% highlight golang linenos %}
package main

import (
	"fmt"
)

var (
	innerError = &innerErr{Msg: "innerMsg"}
)

// Custom error
type innerErr struct {
	Msg string
}

func (i *innerErr) Error() string {
	return "innerError"
}

// Functions
func innerFunc() error {
	return innerError
}

func middleFunc() error {
	if err := innerFunc(); err != nil {
		return fmt.Errorf("middleError")
	}
	return nil
}

func outerFunc() error {
	if err := middleFunc(); err != nil {
		return fmt.Errorf("outerError")
	}
	return nil
}

func main() {
	// Get a error
	outerErr := outerFunc()

	// Print a error
	fmt.Printf("error: %v\n", outerErr)
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Golang Error Example</figcaption>
</figure>

{% highlight console %}
# go run main.go
error: outerError
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Code 1 Output</figcaption>
</figure>

Golang의 Error Wrapping은 의미 그대로 Error를 다른 Error로 감싸는 기법이다. Error Wrapping을 통해서 내부 함수가 반환하는 Error를 외부 함수에서도 판별할 수 있게 된다. [Code 1]과 [Console 1]은 Golang에서 Error Wrapping 없이 Error를 처리하는 일반적인 방법을 나타내고 있다. main() 함수에서는 outerFunc() 함수를 호출하면 outerFunc(), middleFunc(), innerFunc() 함수 순서대로 호출이 발생하고, innerFunc() 함수에서 Error를 Return하기 때문에, outerFunc() 함수도 Error를 반환 한다.

문제는 main() 함수에서는 outerFunc() 함수가 반환하는 "outerErr" Error만 확인이 가능할 뿐, middleFunc() 또는 innerFunc() 함수가 반환하는 Error의 내용을 확인할 수가 없다. 이와 같은 문제를 해결하기 위해서 가장 떠오르기 쉬운 방법은, 내부 함수가 반환하는 Error에 따라서 외부 함수의 Error도 달라지게 구현하는 방법이다. 문제는 이렇게 구현하면 외부 함수의 Error 처리 부분이 복잡해 진다. 이러한 문제는 Error Wrapping 기법을 통해서 쉽게 해결이 가능하다.

#### 1.1. with Standard errors Package

{% highlight golang linenos %}
package main

import (e
	"errors"
	"fmt"
)

var (
	innerError = &innerErr{Msg: "innerMsg"}
	myError    = &myErr{Msg: "myMsg"}
)

// Custom errors
type innerErr struct {
	Msg string
}

func (i *innerErr) Error() string {
	return "innerError"
}

type myErr struct {
	Msg string
}

func (i *myErr) Error() string {
	return "myError"
}

// Functions
func innerFunc() error {
	return innerError
}

func middleFunc() error {
	if err := innerFunc(); err != nil {
		return fmt.Errorf("middleError: %w", err)
	}
	return nil
}

func outerFunc() error {
	if err := middleFunc(); err != nil {
		return fmt.Errorf("outerError: %w", err)
	}
	return nil
}

func main() {
	// Get a wrapped error
	outerErr := outerFunc()
	
	// Unwrap
	fmt.Printf("--- Unwrap ---\n")
	fmt.Printf("unwrap x 0: %v\n", outerErr)
	fmt.Printf("unwrap x 1: %v\n", errors.Unwrap(outerErr))
	fmt.Printf("unwrap x 2: %v\n", errors.Unwrap(errors.Unwrap(outerErr)))

	// Is (Compare)
	fmt.Printf("\n--- Is ---\n")
	if errors.Is(outerErr, innerError) {
		fmt.Printf("innerError true\n") // Print
	} else {
		fmt.Printf("innerError false\n")
	}
	if errors.Is(outerErr, myError) {
		fmt.Printf("myError true\n")
	} else {
		fmt.Printf("myError false\n") // Print
	}

	// As (Assertion, Type Casting)
	fmt.Printf("\n--- As ---\n")
	var iErr *innerErr
	if errors.As(outerErr, &iErr) {
		fmt.Printf("innerError true: %v\n", iErr.Msg) // Print
	} else {
		fmt.Printf("innerError false\n")
	}
	var mErr *myErr
	if errors.As(outerErr, &mErr) {
		fmt.Printf("myError true: %v\n", mErr.Msg)
	} else {
		fmt.Printf("myError false\n") // Print
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] Golang Error Wrapping Example with Standard errors Package</figcaption>
</figure>

{% highlight console %}
# go run main.go
--- Unwrap ---
unwrap x 0: outerError: middleError: innerError
unwrap x 1: middleError: innerError
unwrap x 2: innerError

--- Is ---
innerError true
myError false

--- As ---
innerError true: innerMsg
myError false
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] Code 2 Output</figcaption>
</figure>

Golang 1.13 이후 Version 부터 **fmt.Errorf()** 함수를 통해서 Error Wrapping이 가능하며, Wrapping된 Error는 **errors.Unwrap()** 함수를 통해서 다시 얻을 수 있다. 또한 Wrapping된 Error의 비교는 **errors.Is()** 함수를 통해서 가능하며, Wrapping된 Error의 Assertion은 **errors.As()** 함수를 통해서 가능하다. 여기서 fmt Package와 errors Package는 모두 Golang의 Standard Package이다. [Code 2], [Console 2]는 Standard Package를 활용하여 Error Wrapping을 이용하는 예제를 나타내고 있다.

* 37,44: fmt.Errorf() 함수를 통해서 Error Wrapping을 수행한다. 이 경우 반드시 `%w` 문법을 통해서 Error Wrapping을 수행해야 한다. innerError Error가 middleFunc(), outerFunc() 함수를 통해서 2번 Wrapping되는 것을 확인할 수 있다.
* 54~57: Wrapping된 Error를 errors.Unwrap() 함수를 통해서 하나씩 Unwrapping하며 출력한다.
* 60~70: Wrapping된 Error를 errors.Is() 함수를 통해서 비교한다. outerFunc() 함수의 Error 내부에는 innerError Error가 존재하기 때문에, 61 Line의 결과는 True가 된다. 반면에 outerFunc() 함수의 Error 내부에는 myError Error가 존재하지 않기 때문에, 66 Line의 결과는 False가 된다.
* 73~85: outerErr Error를 errors.As() 함수를 통해서 Assertion을 수행한다. outerFunc() 함수의 Error 내부에는 innerError Error가 존재하기 때문에, 75 Line의 결과는 True가 된다. 반면에 outerFunc() 함수의 Error 내부에는 myError Error가 존재하지 않기 때문에, 78 Line의 결과는 False가 된다.

#### 1.2. with github.com/pkg/errors Package

{% highlight golang linenos %}
package main

import (
	"fmt"

	"github.com/pkg/errors"
)

var (
	innerError = &innerErr{Msg: "innerMsg"}
	myError    = &myErr{Msg: "myMsg"}
)

// Custom errors
type innerErr struct {
	Msg string
}

func (i *innerErr) Error() string {
	return "innerError"
}

type myErr struct {
	Msg string
}

func (i *myErr) Error() string {
	return "myError"
}

// Functions
func innerFunc() error {
	return innerError
}

func middleFunc() error {
	if err := innerFunc(); err != nil {
		return errors.Wrap(err, "middleError")
	}
	return nil
}

func outerFunc() error {
	if err := middleFunc(); err != nil {
		return errors.Wrap(err, "outerError")
	}
	return nil
}

func main() {
	// Get a wrapped error
	outerErr := outerFunc()

	// Cause
	fmt.Printf("\n--- Cause ---\n")
	fmt.Printf("cause: %v\n", errors.Cause(outerErr))

	// Stack
	fmt.Printf("\n--- Stack ---\n")
	fmt.Printf("%+v\n", outerErr)

	// Is (Compare)
	fmt.Printf("\n--- Is ---\n")
	if errors.Is(outerErr, innerError) {
		fmt.Printf("innerError true\n") // Print
	} else {
		fmt.Printf("innerError false\n")
	}
	if errors.Is(outerErr, myError) {
		fmt.Printf("myError true\n")
	} else {
		fmt.Printf("myError false\n") // Print
	}

	// As (Assertion, Type Casting)
	fmt.Printf("\n--- As ---\n")
	var iErr *innerErr
	if errors.As(outerErr, &iErr) {
		fmt.Printf("innerError true: %v\n", iErr.Msg) // Print
	} else {
		fmt.Printf("innerError false\n")
	}
	var mErr *myErr
	if errors.As(outerErr, &mErr) {
		fmt.Printf("myError true: %v\n", mErr.Msg)
	} else {
		fmt.Printf("myError false\n") // Print
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] Golang Error Wrapping Example with Standard errors Package</figcaption>
</figure>

{% highlight console %}
# go run main.go
--- Cause ---
cause: innerError

--- Stack Trace ---
innerError
middleError
main.middleFunc
        /root/test/go_profile_http/main.go:38
main.outerFunc
        /root/test/go_profile_http/main.go:44
main.main
        /root/test/go_profile_http/main.go:52
runtime.main
        /usr/local/go/src/runtime/proc.go:250
runtime.goexit
        /usr/local/go/src/runtime/asm_amd64.s:1571
outerError
main.outerFunc
        /root/test/go_profile_http/main.go:45
main.main
        /root/test/go_profile_http/main.go:52
runtime.main
        /usr/local/go/src/runtime/proc.go:250
runtime.goexit
        /usr/local/go/src/runtime/asm_amd64.s:1571

--- Is ---
innerError true
myError false

--- As ---
innerError true: innerMsg
myError false
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] Code 3 Output</figcaption>
</figure>

Golang의 Standard Package를 활용하여 Error Wrapping을 수행할 경우 단점은 Error가 Code 어디서 발생하는 파악이 어렵다는 단점을 가지고 있다. 이러한 단점은 github.com/pkg/errors Package 이용을 통해서 극복할 수 있다. [Code 3]과 [Console 3]은 github.com/pkg/errors Package를 활용하여 Error Wrapping을 이용하는 모습을 나타내고 있다. Standard Package와 사용성은 큰 차이가 없지만 약간의 차이점이 존재한다. github.com/pkg/errors Package를 이용할 경우 Stack Trace 출력이 가능하기 때문에 Error가 Code 어디서 발생하였는지 쉽게 파악이 가능하다.

* 38,45: github.com/pkg/errors.Wrap() 함수를 통해서 Wrapping을 수행한다. Wrapping을 위해서 fmt Package를 이용할 필요가 없다.
* 56: github.com/pkg/errors Package에서는 Wrapping된 Error를 하나씩 Unwrapping 하는 함수를 제공하지 않는다. 대신에 가장 내부에 존재하는 Error를 반환하는 Cause() 함수를 제공한다. 참고로 github.com/pkg/errors.Unwrap() 함수가 존재하는데, github.com/pkg/errors.Wrap() 함수를 통해서 Wrapping한 Error가 아니라 fmt Package를 활용하여 Wrapping한 Error를 Unwrapping 하는 함수이다.
* 60: fmt.Printf() 함수와 함께 `%+v` 문법을 이용하여 Wrapping된 Error를 출력하면 Stack Trace도 같이 출력된다.

### 2. 참조

* [https://earthly.dev/blog/golang-errors/](https://earthly.dev/blog/golang-errors/)
* [https://gosamples.dev/check-error-type/](https://gosamples.dev/check-error-type/)
* [https://stackoverflow.com/questions/39121172/how-to-compare-go-errors](https://stackoverflow.com/questions/39121172/how-to-compare-go-errors)
* [https://www.popit.kr/golang-error-stack-trace%EC%99%80-%EB%A1%9C%EA%B9%85/](https://www.popit.kr/golang-error-stack-trace%EC%99%80-%EB%A1%9C%EA%B9%85/)
* [https://dev-yakuza.posstree.com/ko/golang/error-handling/](https://dev-yakuza.posstree.com/ko/golang/error-handling/)
* [https://github.com/pkg/errors/issues/223](https://github.com/pkg/errors/issues/223)