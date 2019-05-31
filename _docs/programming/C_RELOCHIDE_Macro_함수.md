---
title: C RELOC_HIDE() Macro 함수
category: Programming
date: 2017-01-22T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

RELOC_HIDE() Macro 함수를 분석한다.

### 1. Macro

{% highlight c linenos %}
#define RELOC_HIDE(ptr, off)                    \
  ({ unsigned long __ptr;                       \
    __asm__ ("" : "=r"(__ptr) : "0"(ptr));      \
    (typeof(ptr)) (__ptr + (off)); })
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] RELOC_HIDE() Macro 함수</figcaption>
</figure>

RELOC_HIDE() Macro 함수는 Parameter로 들어가는 ptr과 off의 합을 구하는 함수이다. Compiler의 최적화 기법에 의해서 발생할 수 있는 Error를 제거하기 위해서 이용한다. [Code 1]은 RELOC_HIDE() Macro 함수를 나타내고 있다. [Code 3]의 3번째 줄의 Inline Assembly 때문에 Compiler는 최적화를 하지 못한다. '\_\_asm\_\_ ("" : "=r"(__ptr) : "0"(ptr))'는 '__ptr = ptr'과 동일하다.

### 2. 참조

* [http://studyfoss.egloos.com/viewer/5374731](http://studyfoss.egloos.com/viewer/5374731)
