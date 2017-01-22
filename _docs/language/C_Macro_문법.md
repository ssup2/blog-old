---
date: 2016-03-14T12:00:00.000Z
lastmod: 2016-03-15T12:00:00.000Z
comment: true
adsense: true
published: true
category: language
---
### 1. # - 문자열화 연산자

#### 1.1. 기능

* Macro Parameter를 문자열로 변경 한다. " "를 붙이는 효과와 동일하다.

#### 1.2. 예제

##### 1.2.1. Code
{% highlight bash linenos %}
#include <stdio.h>
#define PRINT(s)    printf(#s)
 
int main()
{
    PRINT(THIS IS TEST CODE);                          
    return 0;
}
{% endhighlight %}

##### 1.2.2. Result


