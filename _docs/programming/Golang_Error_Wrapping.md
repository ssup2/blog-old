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

#### 1.1. with Standard errors Package

{% highlight golang linenos %}
package main

import (
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

--- Stack ---
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

### 2. 참조

* [https://earthly.dev/blog/golang-errors/](https://earthly.dev/blog/golang-errors/)
* [https://gosamples.dev/check-error-type/](https://gosamples.dev/check-error-type/)
* [https://stackoverflow.com/questions/39121172/how-to-compare-go-errors](https://stackoverflow.com/questions/39121172/how-to-compare-go-errors)
* [https://www.popit.kr/golang-error-stack-trace%EC%99%80-%EB%A1%9C%EA%B9%85/](https://www.popit.kr/golang-error-stack-trace%EC%99%80-%EB%A1%9C%EA%B9%85/)
* [https://dev-yakuza.posstree.com/ko/golang/error-handling/](https://dev-yakuza.posstree.com/ko/golang/error-handling/)
* [https://github.com/pkg/errors/issues/223](https://github.com/pkg/errors/issues/223)