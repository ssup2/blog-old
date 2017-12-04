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
  CAddition* padd;
  padd = (CAddition*) &d;
  cout << padd->result(); // Runtime Error
  return 0;
}
{% endhighlight %}

C++은 C와 동일하게 ()문법으로 Type Casting을 수행 할 수 있다. 위의 예제는 ()문법을 통해서 Class간의 Type Casting을 보여주고 있다. C++에서는 C와 동일하게 Pointer간의 Type Casting에는 제약이 없다. 따라서 CDummy Instance의 주소를 CAddition Class의 Pointer에 Type Casting을 통해서 넣는게 가능하다. 하지만 result 함수 호출시 CDummy Instance에는 result 함수가 없기 때문에 Runtime Error가 발생하게 된다. 이러한 Class간의 Type Casting을 세밀하게 제어하기 위해서 C++에서는 4가지의 추가적인 Type Casting 문법을 제공한다.

#### 1.1. dynamic_cast

{% highlight CPP %}
class CBase { virtual void dummy() {} };
class CDerived: public CBase {};

CBase b; CBase* pb;
CDerived d; CDerived* pd;

pb = dynamic_cast<CBase*>(&d);      // OK
pd = dynamic_cast<CDerived*>(&b);   // Error - NULL
{% endhighlight %}

dynamic_cast는 **상속관계**에 있는 Class간의 **안전한** Type Casting을 위해 이용된다. Type Casting 실패시 Type Casting의 대상 Pointer를 NULL로 만든다. 위의 예제에서 첫번째 dynamic_cast는 Upcasting이기 때문에 성공하지만, 두번째 dynamic_cast는 Downcasting이기 때문에 실패하고, pd는 NULL로 초기화 된다.

{% highlight CPP %}
class CBase { virtual void dummy() {} };
class CDerived: public CBase {};

CBase* pba = new CDerived;
CBase* pbb = new CBase;
CDerived* pd;

pd = dynamic_cast<CDerived*>(pba); // Success
pd = dynamic_cast<CDerived*>(pbb); // Error - NULL
{% endhighlight %}

하지만 다형성이 적용된 포인터에는 dynamic_cast를 이용하여 안전한 Downcasting을 수행 할 수 있다. 위의 예제에서 pba에는 다형성을 이용하여 CDerived Instance를 가리키도록 설정하였기 때문에 첫번째 dynamic_cast는 경우 성공하지만, pbb에는 Base Instance를 가리키도록 설정되어있기 때문에 두번째 dynamic_cast는 실패하게 된다.

dynamic_cast은 runtime시 각 Instance에 대한 추가적인 정보가 필요하기 때문에, dynamic_cast를 이용하려면 Compiler가 **Run-Time Type Information (RTTI)** 옵션을 이용하여 프로그램을 Compile해야 한다. 또한 부모 Class는 반드시 Virtual 함수를 가지고 있어야한다. 부모 Class가 Virtual 함수를 갖고있지 않으면 Compile Error가 발생한다.

#### 1.2. static_cast

{% highlight CPP %}
class CBase {};
class CDerived: public CBase {};

CBase * a = new CBase;
CDerived * b = static_cast<CDerived*>(a);
{% endhighlight %}

static_cast는 **상속관계**에 있는 Class간의 **자유로운** Type Casting시 이용한다. dynamic_cast는 Runtime시 RTTI확인 과정이 필요하기 때문에 추가 Overhead가 발생하지만, static_cast는 Compile 단계에서 Class 상속관계만 확인하기 때문에 Rumtime시 추가 Overhead가 발생하지 않는다. 하지만 다형성으로 인한 Downcasting 가능 유무를 개발자가 직접 판단하여 프로그램을 작성해야 한다.

#### 1.3. reinterpret_cast

{% highlight CPP %}
class A {};
class B {};

A * a = new A;
B * b = reinterpret_cast<B*>(a);
{% endhighlight %}

reinterpret_cast는 **상속 관계에 있지 않은** Class간의 자유로운 Type Casting시 이용한다.

#### 1.4. const_cast

{% highlight CPP %}
void print (char * str)
{
  cout << str << endl;
}

int main () {
  const char* c = "const_cast";
  print ( const_cast<char *> (c) );
  return 0;
}
{% endhighlight %}

const_cast는 Type의 const 속성이나 volatile 속성을 제거하기 위해 이용된다. 위의 예제에서 const char* Type의 포인터 c를 const_cast를 이용하여 char*로 Type Casting하여 이용하고 있다.

### 2. 참조
* [http://www.cplusplus.com/doc/oldtutorial/typecasting/](http://www.cplusplus.com/doc/oldtutorial/typecasting/)
