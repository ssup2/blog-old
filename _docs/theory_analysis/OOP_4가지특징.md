---
title: OOP (Object Oriented Programming) 4가지 특징
category: Theory, Analysis
date: 2017-01-23T14:08:00Z
lastmod: 2017-01-23T14:08:00Z
comment: true
adsense: true
---

### 1. 추상화(Abstraction)

객체를 **Class로 설계하는 과정**을 추상화라고 부른다. 객체는 실제 사물을 의미한다. 객체는 수많은 상태(State)와 행동(Behavior)으로 표현될 수 있다. 이러한 수많은 요소들은 추상화를 통해 프로그램에서 이용하는 Class로 설계된다. 사람 Class가 성을 기준으로 추상화 된다면 사람 Class는 남/여 라는 정보 및 그에 따른 Method를 갖게 된다. 사람 Class가 나이를 기준으로 추상화 된다면 유아/청소년/성인/노인 정보 및 그에 따른 Method를 갖게 된다.

### 2. 캡슐화(Encapsulation)

Class의 Logic이나 상태를 외부에서 알 수 없도록 **숨기는 과정**을 캡슐화라고 부른다. Class의 변수나 메소드에 붙는 Private / Public Keyword는 Class를 캡슐화시키는 중요한 문법이다. Class 캡슐화를 통해 Class를 이용하는 개발자는 단순히 Class의 Public Method를 호출해서 Class를 쉽게 이용할 수 있다. Class간의 Interface를 이용한 느슨한 결합도 캡슐화를 잘 이용하는 예라고 할 수 있다.

### 3. 상속성(Inheritance)

Class의 변수와 Method를 **물려받아** Class를 정의하는 방법을 상속이라고 한다. 상속 되는 Class를 **부모 Class**라고 부르고 상속 받은 Class를 **자식 Class**라고 부른다. 자식 Class는 물려받은 Method를 재정의 할 수 있는데 이러한 기능을  **Overwriting**이라고 부른다.

### 4. 다형성(polymorphism)

Class의 같은 Method를 호출해도 각기 **다른 Method**가 호출되는 특징을 다형성의 특징이라고 부른다. Method의 이름은 같지만 Method의 Parameter의 Type, Parameter의 개수, Return Type에 따라서 실제로 다른 Method가 호출되도록 구현할 수 있는데 이러한 기능을 **Overloading**이라고 한다.

Instance에 따라서도 다른 Method가 호출 될 수 있다. 아래의 Code는 Parent라는 부모 Class와 Child라는 자식 Class로 구성이 되어있다. 15줄에서는 iparent라는 Parent Class 변수에 Parent Instance를 할당하였고, 16줄에서는 ichild라는 Parent Class 변수에 Child Instance를 할당하였다. 두 Instance 모두 Parent Class 변수에 할당되었기 때문에 Code상으로는 Parent 문자열이 두 줄 출력되는것 처럼 보이지만, ichild 인스턴스는 Child 문자열을 출력한다. Parent Class의 변수에 실제 할당된 Instance가 다르기 때문이다. 이렇게 Instance에 따라서 호출되는 Method가 달라지는 과정을 **동적바인딩(Dynamic Dispatch)**라고 부른다.

{% highlight Java %}
class Parent {
    public void print(){
        System.out.println("Parent");
    }
}

class Child extends Parent {
    public void print(){
        System.out.println("Child");
    }
}

public class BlogMain {
    public static void main(String[] args){
        Parent iparent = new Parent();
        Parent ichild = new Child();

        System.out.println(iparent.toString());
        System.out.println(ichild.toString());
    }
}
{% endhighlight %}

~~~
Parent
Child
~~~
