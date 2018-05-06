---
title: Java Synchronized, Monitor
category: Language
date: 2018-05-06T12:00:00Z
lastmod: 2018-05-06T12:00:00Z
comment: true
adsense: true
---

Thread 사이의 동기화(Synchronization)를 위한 Monitor 기법을 분석하고, Monitor를 이용하는 Java의 Synchronized Keyword를 분석한다.

### 1. Monitor

Monitor는 Thread 사이의 동기화를 맞추기 위한 High Level 동기화 기법이다. Monitor는 **하나의 Lock**과 **여러개의 Condition Variable들**로 구성 되어있다. Monitor는 Lock을 이용하여 여러개의 쓰레드가 동시에 Critical Section에 접근하지 못하도록 제어역활을 수행한다. 또한 Condtion Variable들을 이용하여 대기하고 있는 Thread들을 깨워주는 역활도 수행한다.

### 2. Java Synchronized

Java에서 Monitor Instance는 별도로 존재하지 않고 **일반 Instance안에 존재**한다. 또한 각 Monitor Instance는 하나의 Lock과 **하나의 Condition Variable**만을 이용한다. 따라서 Java의 모든 일반 Instance들은 내부적으로 하나의 Lock과 하나의 Condition Variable을 갖게된다. Java의 Synchronized Keywork는 각 일반 Instance안에 존재하는 Monitor Instance를 이용하여 동기화를 맞춘다.

#### 2.1 Synchronized with Method

{% highlight Java %}
import java.util.HashMap;
import java.util.Map;

public class TwoMap {
    private Map<String, String> map1 = new HashMap<String, String>();
    private Map<String, String> map2 = new HashMap<String, String>();
    
    public synchronized void put1(String key, String value){
        map1.put(key, value);
    }
    public synchronized void put2(String key, String value){
        map2.put(key, value);
    }
    
    public synchronized String get1(String key){
        return map1.get(key);
    }
    public synchronized String get2(String key){
        return map2.get(key);
    }
}
{% endhighlight %}

Synchronized Keyword는 일반적으로 Method와 많이 이용된다. 위의 예제는 Synchronized Method 이용 예제이다. Synchronized Keyword가 Method에 붙으면 Method를 호출하는 Instance의 Monitor Instance를 이용한다는 의미이다. TwoMap이라는 Instance를 하나를 만들고 여러개의 Thread들이 동시에 TwoMap Instance의 Method들을 호출해도, 동시에 오직 하나의 Method만 실행된다.

#### 2.2. Synchronized with Instance

{% highlight Java %}
import java.util.HashMap;
import java.util.Map;

public class TwoMap {
    private Map<String, String> map1 = new HashMap<String, String>();
    private Map<String, String> map2 = new HashMap<String, String>();
    private final Object syncObj1 = new Object();
    private final Object syncObj2 = new Object();
    
    public void put1(String key, String value){
        synchronized (syncObj1) {
            map1.put(key, value);
        }
    }
    public void put2(String key, String value){        
        synchronized (syncObj2) {
            map2.put(key, value);
        }
    }
  
    public String get1(String key){
        synchronized (syncObj1) {
            return map1.get(key);
        }
    }
    public String get2(String key){
        synchronized (syncObj2) {
            return map2.get(key);
        }
    }
}
{% endhighlight %}

Synchronized Keyword는 일반 Instance와 같이 이용될 수 있다. 위의 예제는 Synchronized Keyword에 Instance를 이용하는 예제이다. Synchronized Keyword는 괄호안에 명시된 일반 Instance의 Monitor Instance를 이용한다. 위의 예제에서 put1(), get1() Method는 syncObj1의 Monitor Instance를 이용하기 때문에 put1(), get1() Method는 동시에 실행되지 않는다. 하지만 syncObj2의 Monitor Instance를 이용하는 put2() Method는 put1() Method와 동시에 실행 될 수 있다.

### 3. 참조

* [http://www.javacreed.com/undestanding-threads-monitors-and-locks/](http://www.javacreed.com/understanding-threads-monitors-and-locks/)
* [http://christian.heinleins.net/apples/sync/](http://christian.heinleins.net/apples/sync/)
* [http://egloos.zum.com/iilii/v/4071694](http://egloos.zum.com/iilii/v/4071694)
