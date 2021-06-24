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

{% highlight asm %}
foo:
mov %fs:-8, %RCX     // load G descriptor from TLS
cmp 16(%RCX), %RSP   // compare the stack limit and RSP
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

![[그림 1] Goroutine Split Stack]({{site.baseurl}}/images/theory_analysis/Golang_Goroutine_Stack/Split_Stack.PNG){: width="600px"}

![[그림 2] Goroutine Growable Stack]({{site.baseurl}}/images/theory_analysis/Golang_Goroutine_Stack/Growable_Stack.PNG){: width="550px"}

### 2. 참조

* [https://www.youtube.com/watch?v=-K11rY57K7k](https://www.youtube.com/watch?v=-K11rY57K7k)
* [https://assets.ctfassets.net/oxjq45e8ilak/48lwQdnyDJr2O64KUsUB5V/5d8343da0119045c4b26eb65a83e786f/100545_516729073_DMITRII_VIUKOV_Go_scheduler_Implementing_language_with_lightweight_concurrency.pdf](https://assets.ctfassets.net/oxjq45e8ilak/48lwQdnyDJr2O64KUsUB5V/5d8343da0119045c4b26eb65a83e786f/100545_516729073_DMITRII_VIUKOV_Go_scheduler_Implementing_language_with_lightweight_concurrency.pdf)