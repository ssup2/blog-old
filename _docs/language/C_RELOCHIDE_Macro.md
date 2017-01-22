---
title: C RELOCHIDE Macro
category: Language
date: 2017-01-22T14:10:00Z
lastmod: 2017-01-22T14:55:00
comment: true
adsense: true
---

### 1. Macro

{% highlight C %}
#define RELOC_HIDE(ptr, off)                    \
  ({ unsigned long __ptr;                       \
    __asm__ ("" : "=r"(__ptr) : "0"(ptr));      \
    (typeof(ptr)) (__ptr + (off)); })
{% endhighlight %}

### 2. 설명

* **ptr + off**을 Return한다.
* Compiler의 최적화 기법에 의해서 발생할 수 있는 Error를 제거한다.
* **__asm__ ("" : "=r"(__ptr) : "0"(ptr))**는 **__ptr = ptr**와 동일하다. 이 Inline asm에 의해서 Compiler는 최적화를 하지 못한다.

### 3. 참조
* [http://studyfoss.egloos.com/viewer/5374731](http://studyfoss.egloos.com/viewer/5374731)
