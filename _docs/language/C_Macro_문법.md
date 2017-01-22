---
date: 2017-01-22T13:10:00.000Z
lastmod: 2016-01-22T13:10:00.000Z
comment: true
adsense: true
published: true
category: Language
---
### 1. # - 문자열화 연산자

#### 1.1. 기능

* Macro Parameter를 문자열로 변경 한다. " "를 붙이는 효과와 동일하다.

#### 1.2. 예제

##### 1.2.1. Code

{% highlight C %}
#include <stdio.h>
#define PRINT(s)    printf(#s)
 
int main()
{
    PRINT(THIS IS TEST CODE);                          
    return 0;
}
{% endhighlight %}


