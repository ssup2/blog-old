---
title: C Macro 문법
category: Programming
date: 2017-01-20T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

C언어의 Macro 문법을 정리한다.

### 1. 문자열화 연산자 (#) 

{% highlight c linenos %}
#include <stdio.h>
#define PRINT(s)    printf(#s)

int main()
{
    PRINT(THIS IS TEST CODE);                          
    return 0;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] # Macro 예제</figcaption>
</figure>

{% highlight text %}
THIS IS TEST CODE
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] # Macro 예제의 출력</figcaption>
</figure>

문자열화 연산자 (#)는 Macro Parameter를 문자열로 변경한다. " "를 붙이는 효과와 동일하다. [Code 1]은 'THIS IS TEST CODE' Macro Parameter가 printf() 함수의 문자열로 넘어가는 예제를 보여주고 있다.

### 2. Token 붙여넣기 연산자 (##) 

{% highlight c linenos %}
#include <stdio.h>

#define INT_i(n)        int i##n = n;
#define PRINT(n)        printf("i%d = %d\n", n, i##n)

int main()
{
    INT_i(0);
    PRINT(0);

    return 0;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] ## Macro 예제</figcaption>
</figure>

{% highlight text %}
i0 = 0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] ## Macro 예제의 출력</figcaption>
</figure>

Token 붙여넣기 연산자 (##)는 분리된 Token을 하나로 합친다. [Code 2]에서 INT_i() Macro 함수는 'int i0 = 0'으로 치환되고, PRINT() Macro 함수는 'printf("i%d = %d\n", 0, i0)'으로 치환된다.

### 3. 가변 인자 Macro

{% highlight c linenos %}
#define debug(format, ...) fprintf (stderr, format, __VA_ARGS__)
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] 1999년 표준의 가변 인자 Macro</figcaption>
</figure>

{% highlight c linenos %}
#define debug(format, args...) fprintf (stderr, format, args)
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] GCC 가변 인자 Macro</figcaption>
</figure>

1999년 C 표준에서는 **...**와 **__VA_ARGS__**을 이용하여 가변 인자를 나타낸다. [Code 3]은 1999년 C 표준 문법의 가변 인자 Macro의 사용법을 나타내고 있다. GCC에서는 **[name]...**와 **[name]**을 이용하여 가변 인자를 나타낸다. [Code 4]는 GCC 가변 인자 Macro의 사용법을 나타내고 있다.

### 4. 참조

* [http://msdn.microsoft.com/en-us/library/7e3a913x.aspx](http://msdn.microsoft.com/en-us/library/7e3a913x.aspx)
* [https://www.google.co.kr/?gfe_rd=cr&ei=HzoMVIOrEYTN8ge3oYGgDw&gws_rd=ssl#newwindow=1&q=c+macro+%EB%AC%B8%EB%B2%95](https://www.google.co.kr/?gfe_rd=cr&ei=HzoMVIOrEYTN8ge3oYGgDw&gws_rd=ssl#newwindow=1&q=c+macro+%EB%AC%B8%EB%B2%95)
* [https://gcc.gnu.org/onlinedocs/cpp/Variadic-Macros.html](https://gcc.gnu.org/onlinedocs/cpp/Variadic-Macros.html)
