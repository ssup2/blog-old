---
title: C Macro 문법
category: Language
date: 2017-01-20T13:10:00Z
lastmod: 2016-01-22T13:10:00Z
comment: true
adsense: true
---
### 1. # - 문자열화 연산자

#### 1.1. 기능

* Macro Parameter를 문자열로 변경 한다. " "를 붙이는 효과와 동일하다.

#### 1.2. 예제

{% highlight C %}
#include <stdio.h>
#define PRINT(s)    printf(#s)

int main()
{
    PRINT(THIS IS TEST CODE);                          
    return 0;
}
{% endhighlight %}

~~~
THIS IS TEST CODE
~~~

### 2. ## - 토큰 붙여넣기 연산자

#### 2.1. 기능

* 분리된 토큰을 하나로 합친다.

#### 2.2. 예제

{% highlight C %}
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

~~~
i0 = 0
~~~

### 3. 가변 인자 Macro

#### 3.1. 기능

* Macro에서 가변인자를 나타낸다.
* 1999년 C 표준에서는 '...'와 '__VA_ARGS__'을 이용하여 가변인자를 나타낸다.
* GCC에서는 '[name]...'와 '[name]'을 이용하여 가변인자를 나타낸다.

#### 3.2. 예제

##### 3.2.1. 1999년 C 표준

{% highlight C %}
#define debug(format, ...) fprintf (stderr, format, __VA_ARGS__)
{% endhighlight %}

##### 3.2.2. GCC

{% highlight C %}
#define debug(format, args...) fprintf (stderr, format, args)
{% endhighlight %}

### 4. 참조

* [http://msdn.microsoft.com/en-us/library/7e3a913x.aspx](http://msdn.microsoft.com/en-us/library/7e3a913x.aspx)
* [https://www.google.co.kr/?gfe_rd=cr&ei=HzoMVIOrEYTN8ge3oYGgDw&gws_rd=ssl#newwindow=1&q=c+macro+%EB%AC%B8%EB%B2%95](https://www.google.co.kr/?gfe_rd=cr&ei=HzoMVIOrEYTN8ge3oYGgDw&gws_rd=ssl#newwindow=1&q=c+macro+%EB%AC%B8%EB%B2%95)
* [https://gcc.gnu.org/onlinedocs/cpp/Variadic-Macros.html](https://gcc.gnu.org/onlinedocs/cpp/Variadic-Macros.html)
