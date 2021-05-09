---
title: Java Design Pattern Singleton
category: Programming
date: 2021-05-09T12:00:00Z
lastmod: 2021-05-09T12:00:00Z
comment: true
adsense: true
---

Java로 구현하는 Singleton Pattern을 분석한다. 

### 1. Java Singleton Pattern

**Singleton Pattern은 JVM에 하나의 Global Instance만을 할당하고 공유해서 이용하는 Pattern을 의미한다.** Java에서 Singleton Pattern을 구현하기 위한 몇가지 방법이 존재한다.

{% highlight java linenos %}
public class Singleton { 
    private static Singleton instance;

    private Singleton() {} // Private constructor

    public static Singleton getInstance() { 
        if(instance == null) { 
            instance = new Singleton();
        } 
        return instance; 
    } 
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Java Singleton Pattern Old Version</figcaption>
</figure>

[Code 1]은 고전 방식의 Singleton Pattern을 나타내고 있다. 생성자를 Private로 선언하였기 때문에 생성자 호출을 통해서 새로운 Instance를 생성할 수 없다. 오직 getInstance() 함수 호출을 통해서만 Instance를 얻을 수 있다. getInstance() 함수는 생성되어 있는 Instance가 존재하지 않을 경우에만 새로운 Instance를 할당 및 반환하고, 생성되어 있는 Instance가 존재하는 경우에는 기존에 생성되어 있는 Instance를 반환한다. 따라서 getIntance() 함수를 통해서 얻은 Instance는 모두 동일한 Instnace가 된다.

{% highlight java linenos %}
public class Singleton { 
    private static Singleton instance; 

    private Singleton(){} 
    
    public static synchronized Singleton getInstance() { // synchronized
        if(instance == null) { 
            instance = new Singleton();
        }
        return instance;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] Java Singleton Pattern Synchronized Version</figcaption>
</figure>

[Code 1]의 getInstance() 함수는 Multi-thread 환경에서 다수의 Thread가 동시에 호출할 경우 Instance 할당 과정중에 Race Condition이 발생하여 문제가 발생할 수 있다. 이러한 문제를 해결하기 위한 가장 간단한 방법은 "synchronized"를 이용하여 getInstance() 함수가 동시에 호출되지 못하도록 막는 방법이 존재한다.

{% highlight java linenos %}
public class Singleton {
    private static Singleton instance = new Singleton();

    private Singleton(){}
    
    public static Singleton getInstance() {
        return instance;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] Java Singleton Pattern Static Version</figcaption>
</figure>

{% highlight java linenos %}
public class Singleton { 
    private Singleton(){} 
    
    public static Singleton getInstance() { 
        return LazyHolder.INSTANCE; 
    }
    
    private static class LazyHolder { 
        private static final Singleton INSTANCE = new Singleton(); 
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] Java Singleton Pattern Lazy Holder Version</figcaption>
</figure>

### 2. 참조

* [https://javaplant.tistory.com/21](https://javaplant.tistory.com/21)
* [https://elfinlas.github.io/2019/09/23/java-singleton/](https://elfinlas.github.io/2019/09/23/java-singleton/)
