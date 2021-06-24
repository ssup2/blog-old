---
title: Golang Goroutine Stack
category: Theory, Analysis
date: 2021-06-24T12:00:00Z
lastmod: 2021-06-24T12:00:00Z
comment: true
adsense: true
---

Golang의 Goroutine Stack을 분석한다.

### 1. Goroutine Stack

Golang Runtime은 Goroutine의 Stack을 자체적으로 관리한다. 새로 생성된 Goroutine은 기본적으로 **1KB** 크기의 Stack을 이용할 수 있으며, 필요에 따라서 동적으로 Stack을 더 할당받아 이용한다. Goroutine은 함수를 실행하기 전에 Goroutine이 이용 가능한 Stack의 크기와 현재 Stack Pointer를 비교한다. 만약 Stack Pointer가 이용 가능한 Stack의 크기를 초과 했다면, 동적으로 Stack을 더 할당받아 이용한다.

{% highlight asm %}
foo:
mov %fs:-8, %RCX     // load G descriptor from TLS
cmp 16(%RCX), %RSP   // compare the stack limit and RSP (stack pointer)
jbe morestack        // jump to slow-path if not enough stack
sub $64, %RSP
...
mov %RAX, 16(%RSP)
...
add $64, %RSP
retq
...
morestack:           // call runtime to allocate more stack
callq <runtime.morestack>
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Goroutine Function Call</figcaption>
</figure>

[Code 1]은 이러한 Logic을 Assembly Code로 나타내고 있다. 함수 첫부분에서 TLS (Thread Local Storage)에 저장된 Goroutine이 이용 가능한 Stack의 크기 (Limit)와 Stack Pointer를 저장하고 있는 RSP를 비교하고 있다. RSP가 Stack의 크기를 초과하고 있다면 morestack 함수를 통해서 동적으로 Stack을 할당 받는다.

![[그림 1] Goroutine Split Stack]({{site.baseurl}}/images/theory_analysis/Golang_Goroutine_Stack/Split_Stack.PNG){: width="600px"}

![[그림 2] Goroutine Growable Stack]({{site.baseurl}}/images/theory_analysis/Golang_Goroutine_Stack/Growable_Stack.PNG){: width="550px"}

Stack을 동적으로 할당하는 기법에는 기존의 Stack은 그대로 유지하고 1KB 크기의 새로운 Stack을 할당받는 **Split Stack** 기법과, 1KB 이상의 Stack을 새로 할당받고 기존의 Stack의 내용을 복사해오는 **Growable Stack** 기법이 존재한다. [그림 1]은 Split Stack 기법을 나타내고 있고, [그림 2]는 Growable Stack 기법을 나타내고 있다.

**Split Stack** 기법은 빠른 Stack Memory 확보가 가장 큰 장점이다. 하지만 Code의 내용만으로는 언제 새로운 Stack이 할당 될지 모르기 때문에, Stack 할당으로 인한 성능 저하가 언제 발생할지 추정하기 힘들다는 큰 단점을 가지고 있다. 예를들어 [그림 1]에서 func1() 함수가 더 많은 지역변수를 이용하도록 변경한다면 func1() 함수가 이용하는 Stack의 크기는 더 커지게 되고, func2() 함수는 func1() 함수와 동일한 Stack을 이용하지 못하고 별도의 Stack을 이용하게 될 수 있다.

이 경우 func1() 함수가 func2() 함수를 호출 할때마다 func2() 함수 내부에서 새로운 Stack이 할당되기 때문에, func2() 함수의 성능 저하가 발생한다. 이러한 성능 저하는 func1() 함수가 func2()을 거의 호출하지 않고 있다면 큰 문제가 되지 않겠지만 자주 호출이 된다면 성능에 큰 영향을 주게 된다. 결과적으로 func1() 함수를 변경했지만 func2() 함수의 성능이 느려지는 예상하기 힘든 성능 저하가 나타날수 있게 된다. 이처럼 Split Stack 기법은 예상하기 힘들 성능 저하의 원인이 될 수 있다.

**Growable Stack** 기법은 Stack이 증가 할때마다 기존 Stack의 내용을 복사해야하기 때문에 Stack 할당시간이 Split Stack과 비교하면 오래걸린다. 하지만 한번 증가한 Stack은 줄어들지 않기 때문에 Stack이 충분히 증가한 이후에는 Stack 할당으로 인한 예상하기 힘든 성능저하가 발생하지 않는다. 이러한 이유때문에 Goroutine은 Growable Stack을 이용한다.

### 2. 참조

* [https://www.youtube.com/watch?v=-K11rY57K7k](https://www.youtube.com/watch?v=-K11rY57K7k)
* [https://assets.ctfassets.net/oxjq45e8ilak/48lwQdnyDJr2O64KUsUB5V/5d8343da0119045c4b26eb65a83e786f/100545_516729073_DMITRII_VIUKOV_Go_scheduler_Implementing_language_with_lightweight_concurrency.pdf](https://assets.ctfassets.net/oxjq45e8ilak/48lwQdnyDJr2O64KUsUB5V/5d8343da0119045c4b26eb65a83e786f/100545_516729073_DMITRII_VIUKOV_Go_scheduler_Implementing_language_with_lightweight_concurrency.pdf)
* [https://kuaaan.tistory.com/449](https://kuaaan.tistory.com/449)