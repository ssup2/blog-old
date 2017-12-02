---
title: C++ Type Casting
category: Language
date: 2017-12-03T12:00:00Z
lastmod: 2017-12-03T12:00:00Z
comment: true
adsense: true
---

C++ Type Casting을 분석한다.

### 1. C++ Type Casting

{% highlight CPP %}
#include <iostream>
using namespace std;

class CDummy {
  float i,j;
};

class CAddition {
  int x,y;
  public:
	CAddition (int a, int b) { x=a; y=b; }
	int result() { return x+y;}
};

int main () {
  CDummy d;
  CAddition * padd;
  padd = (CAddition*) &d;
  cout << padd->result(); // Runtime Error
  return 0;
}
{% endhighlight %}

C++은 C와 동일하게 ()문법으로 Type Casting을 수행 할 수 있다. 위의 예제는 ()문법을 통해서 Class간의 Type Casting을 보여주고 있다. C++에서는 C와 동일하게 Pointer간의 Type Casting에는 제약이 없다. 따라서 CDummy Instance의 주소를 CAddition Class의 Pointer에 Type Casting을 통해서 넣는게 가능하다. 하지만 result 함수 호출시 CDummy Instance에는 result 함수가 없기 때문에 Runtime Error가 발생하게 된다. 이러한 Class간의 Type Casting을 세밀하게 제어하기 위해서 C++에서는 4가지의 추가적인 Type Casting 문법을 제공한다.

#### 1.1. dynamic_cast

dynamic_cast는 Runtime시 Class간의 Type 변환이 가능한지, 불가능한지 파악하여 Type Casting을 수행한다. Type Casting 실패시 Casting 하려던 Pointer를 NULL로 만든다.

{% highlight CPP %}
#include <iostream>
using namespace std;

class CBase { virtual void dummy() {} };
class CDerived: public CBase { int a; };

int main () {
  CBase* pba = new CDerived;
  CBase* pbb = new CBase;
  CDerived* pd;

  pd = dynamic_cast<CDerived*>(pba);
  if (pd==0) cout << "Null pointer on first type-cast" << endl;

  pd = dynamic_cast<CDerived*>(pbb);
  if (pd==0) cout << "Null pointer on second type-cast" << endl;

  return 0;
}
{% endhighlight %}

~~~
Null pointer on second type-cast
~~~

위의 예제는 dynamic_cast를 이용하여 CBase Class의 Pointer를 CDerived Class의 Pointer로 2번 Downcasting을 수행하는 예제이다. pba에 다형성을 이용하여 CDerived Instance를 가리키도록 설정하였기 때문에 첫번째 Type Casting의 경우 성공하지만, pbb에는 Base Instance를 가리키도록 설정되어있기 때문에 두번째 Type Casting은 실패하게 된다.

dynamic_cast은 runtime시 각 Instance에 대한 추가적인 정보가 필요하기 때문에, dynamic_cast를 이용하려면 Compiler가 **Run-Time Type Information (RTTI)** 옵션을 이용해야 한다.

#### 1.2. static_cast

{% highlight CPP %}
{% endhighlight %}

#### 1.3. interpret_cast

{% highlight CPP %}
{% endhighlight %}

#### 1.4. const_cast

Type의 const 속성이나 volatile 속성을 제거하기 위해 사용된다.

{% highlight CPP %}
#include <iostream>
using namespace std;

void print (char * str)
{
  cout << str << endl;
}

int main () {
  const char* c = "sample text";
  print ( const_cast<char *> (c) );
  return 0;
}
{% endhighlight %}

~~~
sample text
~~~

위의 예제에서 const char* Type의 c를 const_cast를 이용하여 char*로 Type Casting 한것을 알 수 있다.

### 2. 참조
* [http://www.cplusplus.com/doc/oldtutorial/typecasting/](http://www.cplusplus.com/doc/oldtutorial/typecasting/)
