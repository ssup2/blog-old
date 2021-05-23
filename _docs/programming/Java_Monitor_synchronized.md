---
title: Java Monitor, synchronized
category: Programming
date: 2018-05-06T12:00:00Z
lastmod: 2018-05-06T12:00:00Z
comment: true
adsense: true
---

Thread 사이의 동기화(Synchronization)를 위한 Monitor 기법을 정리하고, Java에서 Monitor를 기반으로 동작하는 synchronized 기법을 분석한다.

### 1. Monitor

Monitor는 Thread 사이의 동기화를 맞추기 위한 High Level 동기화 기법이다. Monitor는 **하나의 Lock**과 **여러개의 Condition Variable들**로 구성 되어있다. Monitor는 Lock을 이용하여 여러개의 쓰레드가 동시에 Critical Section에 접근하지 못하도록 제어역할을 수행한다. 또한 Condtion Variable들을 이용하여 대기하고 있는 Thread들을 깨워주는 역할도 수행한다.

### 2. Java Monitor

Java의 모든 Instance(Object)는 하나의 Monitor를 소유하고 있다. 각 Monitor는 **하나의 Lock과 하나의 Condition Variable (Wait Queue)**만을 이용한다. 따라서 Java의 모든 Instance들은 내부적으로 하나의 Lock과 하나의 Condition Variable을 갖게된다.

#### 2.1. synchronized

Java의 synchronized Keyword는 Thread 사이의 동기화를 맞추는 기법중 하나이다. synchronized Keywork는 각 일반 Instance안에 존재하는 Monitor를 이용하여 Thread 사이의 동기화를 수행한다.

{% highlight java linenos %}
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
<figure>
<figcaption class="caption">[Code 1] synchronized Method</figcaption>
</figure>

synchronized Keyword는 일반적으로 Method와 많이 이용된다. [Code 1]은 synchronized Method 이용 예제이다. synchronized Keyword가 Method에 붙으면 Thread는 Method를 호출하는 Instance의 Monitor의 Lock을 획득해야 실행이 가능하다. 따라서 TwoMap이라는 Instance를 하나를 만들고 다수의 Thread들이 동시에 TwoMap Instance의 Method들을 호출해도, 동시에 오직 하나의 Method만 실행된다.

{% highlight java linenos %}
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
<figure>
<figcaption class="caption">[Code 2] synchronized Instance</figcaption>
</figure>

synchronized Keyword는 일반 Instance와 같이 이용될 수 있다. [Code 2]는 synchronized Keyword에 Instance를 이용하는 예제이다. 이 경우 Thread가 synchronized Keyword의 괄호안에 명시된 Instance의 Monitor의 Lock을 획득해야 synchronized Keyword Block 내부의 Code들을 실행할 수 있다. 따라서 [Code 2]에서 put1(), get1() Method는 syncObj1의 Monitor를 이용하기 때문에 put1(), get1() Method는 동시에 실행되지 않는다. 반면에 syncObj2의 Monitor를 이용하는 put2() Method는 put1() Method와 동시에 실행 될 수 있다.

{% highlight java linenos %}
public class Channel {
    private String packet;
    private boolean isPacketExist;
 
    public synchronized void send(String packet) {
        while (isPacketExist) {
            try {
                wait();
            } catch (InterruptedException e)  {
                Thread.currentThread().interrupt(); 
                Log.error("Thread interrupted", e); 
            }
        }
        isPacketExist = true;
        
        this.packet = packet;
        notifyAll();
    }
 
    public synchronized String receive() {
        while (!isPacketExist) {
            try {
                wait();
            } catch (InterruptedException e)  {
                Thread.currentThread().interrupt(); 
                Log.error("Thread interrupted", e); 
            }
        }
        isPacketExist = false;

        notifyAll();
        return packet;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] wait(), notifyAll()</figcaption>
</figure>

Thread가 Instance의 Monitor의 Lock을 가지고 Code를 실행하다가 Lock을 다른 Thread에게 양도한 이후에 대기해야할 경우 wait() 함수를 이용하면 된다. wait() 함수는 Instance의 Monitor의 Condition Variable을 이용하여 구현되었다. Condition Variable에서 대기중인 Thread는 notify(), notifyAll() 함수를 통해서 깨울수 있다. notify() 함수는 Condition Variable에서 대기중인 임의의 하나의 Thread만을 깨우는 동작을 수행한다. notifyAll() 함수는 Condition Variable에서 대기중인 모든 Thread를 깨운다. 모든 Thread가 깨어나도 하나의 Thread만 Lock을 획득하고 나머지 Thread들은 다시 대기한다.

[Code 3]은 wait(), notifyAll() 함수를 이용하는 예제를 나타내고 있다. send() 함수는 Channel에 Packet이 존재할 경우 wait() 함수를 통해서 대기한다. 이후에 receive() 함수가 호출이 되어 Channel의 Packet이 제거되고 notifyAll() 함수가 호출되면 깨어나 Packet을 Channel에 저장한다. 반대로 receive() 함수는 Channel에 Packet이 존재하지 않을 경우 wait() 함수를 통해서 대기한다. 이후에 send() 함수가 호출이 되어 Channel에 Packet이 저장되고 notifyAll() 함수가 호출되면 깨어나 Packet을 Channel에서 제거한다.

### 2. 참조

* [https://en.wikipedia.org/wiki/Monitor_(synchronization)](https://en.wikipedia.org/wiki/Monitor_(synchronization))
* [http://christian.heinleins.net/apples/sync/](http://christian.heinleins.net/apples/sync/)
* [http://egloos.zum.com/iilii/v/4071694](http://egloos.zum.com/iilii/v/4071694)
* [https://www.baeldung.com/java-wait-notify](https://www.baeldung.com/java-wait-notify)
