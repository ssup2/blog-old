---
title: JVM (Java Virtual Machine)
category: Theory, Analysis
date: 2017-11-20T12:00:00Z
lastmod: 2017-11-20T12:00:00Z
comment: true
adsense: true
---

JVM (Java Virtual Machine)을 분석한다.

### 1. JVM (Java Virtual Machine)

![]({{site.baseurl}}/images/theory_analysis/JVM/JVM_Architecture.PNG)

Java는 **Write once, Run anywhere**라는 철학 위에서 만들어진 언어이다. 한번 작성된 App이 다양한 Platform에서 동작하기 위해서는 App의 구동 환경이 Platform에 종속적이면 안된다. JVM은 이러한 문제를 해결하기 위해서 Platform과 Java App 사이에서 Java App에게 일정한 구동 환경을 제공하는 User Level Program이다. JVM은 크게 Class Loader, Runtime Memory, Execution Engine, Natvie Method Inteface (JNI)로 구성되어 있다.

#### 1.1. Class Loader

Class Loader는 Byte Code로 Compile된 Class File을 Memory에 올리는 역활을 수행한다. 기본 Class Loader에는 Bootstrap, Extension, Systme Class 3가지 Class Loader가 존재한다.

* Bootstrap Class Loader - rt.jar (runtime)라는 Java Core Library를 올린다. ex) java.lang.System
* Extension Class Loader - $JAVA_HOME/lib/ext아래의 Class들을 올린다.
* System Class Loader - $CLASSPATH에 있는 Class들을 올린다. 일반적을 App의 Class가 이에 속한다.

위의 3개의 Class Loader 말고도 Java App 개발자가 Class Loading을 관리하고 싶을때에는 직접 Class Loader Class를 상속하여 User Class Loader를 생성할 수 있다. Claas Loader는 **Parent Delegation Model**을 이용한다. Class Loader가 올릴 Class가 Memory에 없는걸 확인한 뒤 Class를 직접 올리기전에 무조건 Parent Class Loader를 호출하는 방식을 의미한다. Parent Class Loader 호출뒤에도 Class가 올라가있지 않으면, 직접 Class를 올린다. 호출된 Parent Class Loader 또한 자신이 직접 Class를 올리기전 자신의 Parent Class Loader를 호출한다. Parent Delegation Model을 통해서 Java App 개발자가 User Class Loader 개발시 Class 중복 Loading을 고민할 필요 없이 Class Loader를 쉽게 제작할 수 있다.

![]({{site.baseurl}}/images/theory_analysis/JVM/Class_Loader_Hierarchy.PNG){: width="500px"}

Parent Delegation Model로 인해서 Class Loader는 자연스럽게 계층을 형성하게 된다. 위의 그림은 Class Loader간의 계층을 나타내고 있다. Bootstrap Class를 제외한 모든 Class Loader는 반드시 Parent Class Loader를 갖는다. Class Loader는 다음과 같은 3단계의 동작을 수행한다.

* Loading - Bytecode로 구성된 Class를 Memory에 올린다.
* Linking - static 변수들을 초기화 하고, Symbol을 Resolve한다.
  * Verify - Bytecode가 올바른지 확인한다.
  * Prepare - static 변수들이 변수 Type에 따른 Default Value로 초기화 된다. ex) int -> 0
  * Resolve - Class Compile시 Class가 외부 Class를 이용하는 경우 외부 Class의 Memory 주소를 Compile 시점에서는 알지 못한다. 따라서 외부 Class를 Symbol로 나타내어 Bytecode에 삽입해 놓는다. 이전 Loading 단계에서 Class가 Memory에 올라오면서 각 Class의 Memory 주소가 정해진 상태이기 때문에 Bytecode에 삽입된 Symbol을 실제 Class Memory 주소로 바꾼다.
* Initialization - static 변수들을 Code에 있는 값으로 초기화 한다.

#### 1.2. Runtime Memory

![]({{site.baseurl}}/images/theory_analysis/JVM/Runtime_Memory.PNG)

Runtime Memory는 JVM이 관리하는 Memory 영역이다. Method Area, Heap, Stack, PC Register, Native Method Stack으로 구성되어 있다.

* Method Area - Method의 Bytecode가 올라가는 영역이다. 또한 static 변수도 Method Area에서 관리된다.
* Heap - new 문법으로 생성하는 Instance들이 올라가는 영역이다. 좀더 정확히 표현하면 Instance의 변수들이 Heap에서 관리 된다.
* Stack - 지역 변수들이 올라가는 영역이다. Thread가 Method를 Call하면 그에 따른 새로운 Stack Frame을 생성하고, 지역 변수를 할당한다. 해당 Method의 동작이 종료되면 할당했던 Stack Frame을 해제하고 이전의 Stack Frame을 이용한다. 각 Thread 별로 전용 Stack 공간을 갖는다. Stack을 이용하여 각 Thread의 Context를 유지한다고 할 수 있다.
* PC Register - PC (Program Counter) Register 영역은 각 Thread가 실행할 다음 Bytecode의 주소를 관리하는 영역이다. 따라서 Stack 처럼 각 Thread는 전용 PC Register를 갖고 있다.
* Native Method Stack - Native Method, 즉 CPP 처럼 Native 언어로 작성된 Method를 의미한다. Native Method를 실행 할때는 별도의 Native Method Stack을 이용하여 Native Method의 지역 변수를 관리한다. Stack과 유사하게 각 Thread 전용 PC Register를 갖고 있다.

#### 1.3. Execution Engine

Runtime Memory를 이용하여 실제 Bytecode를 수행한다. Execution Engine은 Interpreter, JIT Compiler, Garbage Collector로 구성되어 있다.

* Interpreter - Bytecode를 해석하여 수행한다.
* JIT (Just-In-Time) Compiler - Bytecode는 Interpreter에서 해석되어 실행되야 하기 때문에 성능 Overhead가 발생한다. JIT Compiler는 Rumtime 중에 자주 실행되는 Bytecode를 파악하여 Assembly 언어로 Compile한다. Assembly 언어로 Compile된 Bytecode는 CPU가 Interpreter 없이 실행 할 수 있기 때문에 Interpreter의 성능 Ovehread를 제거할 수 있다.
* Garbage Collector - Java는 Instance들이 올라가는 Heap 영역을 자동으로 관리하는 Garbage Collector를 가지고 있다. 따라서 Java는 CPP처럼 Delete 명령으로 할당된 Instance를 해지하지 않는다.

#### 1.4. Native Method Interface (JNI)

Execution Engine이 Native Method Library안의 Native Method를 실행 할 수 있도록 도와주는 Interface 역활을 수행한다.

### 2. 참조
* [https://dzone.com/articles/jvm-architecture-explained](https://dzone.com/articles/jvm-architecture-explained)
* [http://www.artima.com/insidejvm/ed2/lifetypeP.html](http://www.artima.com/insidejvm/ed2/lifetypeP.html)
* [https://www.artima.com/insidejvm/ed2/jvm2.html](https://www.artima.com/insidejvm/ed2/jvm2.html)
* [http://blog.cask.co/2015/08/java-class-loading-and-distributed-data-processing-frameworks/](http://blog.cask.co/2015/08/java-class-loading-and-distributed-data-processing-frameworks/)
