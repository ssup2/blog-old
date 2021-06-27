---
title: Process/Thread Synchronization
category: Theory, Analysis
date: 2021-06-27T12:00:00Z
lastmod: 2021-06-27T12:00:00Z
comment: true
adsense: true
---

Process/Thread 동기화 기법을 분석한다.

### 1. Process/Thread Syncronization

#### 1.1. Mutex

{% highlight cpp %}
#include <pthread.h>  

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
int count; // shared resource

void IncreaseCount() {
    pthread_mutex_lock(&mutex); // lock
    count++;
    pthread_mutex_unlock(&mutex); // unlock
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Mutex CPP Example on Linux</figcaption>
</figure>

Mutex는 가장 기본적인 Process/Thread 동기화 기법이다. Shared Resource를 접근하는 영역인 Critical Section을 Mutex의 Lock 함수와 Unlock 함수로 감싸면 된다. [Code 1]은 Linux에서 동작하는 CPP 기반의 Mutex 예제를 나타내고 있다. pthread_mutex_lock() 함수가 Lock 함수 역활을 수행하고, pthread_mutex_unlock() 함수가 Unlock 함수 역활을 수행한다.

Mutex의 Lock 함수가 호출되면 해당 Mutex의 상태가 Lock/Unlock 상태인지 확인한다. 만약 Mutex가 Lock 상태라면 Lock 함수는 Mutex가 Unlock 상태가 될때까지 대기하다가 Unlock 상태가 되면 종료되고 Critical Section에 진입한다. 만약 Mutex가 Unlock 상태라면 Lock 함수는 바로 종료되고, Critical Section에 진입한다.

Mutex의 Lock 상태는 Mutex의 Unlock 함수의 호출을 통해서 Unlock 상태가 된다. 이때 Mutex의 Unlock 함수는 반드시 Mutex의 Lock 함수를 통해서 해당 Mutex를 Lock 상태로 만든 Thread에서 호출해야 한다. 즉 Mutex의 Lock 상태는 외부의 Thread에서 Unlock 상태로 변경할 수 없다. 이러한 특징은 Binary Semaphore와의 가장 큰 차이점이다.

Mutex가 Lock 상태에서 Mutex의 Lock 함수를 호출한 Thread는 Sleep 상태로 변경되고 Scheduling Out되어 Mutex가 Unlock 상태가 되기를 대기한다. 이후에 해당 Mutex가 Unlock 상태가 Sleep 상태의 Thread는 깨어나고, Lock 함수가 종료되면서 Critical Section에 진입하게 된다. 만약 동일한 Mutex에 다수의 Thread가 대기중이라면, Linux Mutex의 경우에는 우선순위가 가장 높은 Thread 하나만이 깨어난다.

#### 1.2. Spinlock

#### 1.3. Condition Variable

{% highlight cpp %}
#include <pthread.h>  

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
pthread_cond_t cond = PTHREAD_COND_INITIALIZER; // condition variable instance
queue<request*> req_queue; // shared resource

void ProduceReqWakeupOne(request* req) {
    pthread_mutex_lock(&mutex); // lock
    req_queue.enqueue(req);
    pthread_mutex_unlock(&mutex); // unlock
    pthread_cond_signal(&cond); // wake up one thread
}

void ProduceReqWakeupAll(request* req) {
    pthread_mutex_lock(&mutex); // lock
    req_queue.enqueue(req);
    pthread_mutex_unlock(&mutex); // unlock
    pthread_cond_broadcast(&cond); // wake up all thread
}

request* ConsumeReq() {
    pthread_mutex_lock(&mutex); // lock
    while(req_queue.empty()) {
        pthread_cond_wait(&cond, &mutex);
    }
    request* req = req_queue.dequeue();
    pthread_mutex_unlock(&mutex); // unlock
    return req;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] Condition Variable CPP Example on Linux</figcaption>
</figure>

#### 1.4. Monitor

{% highlight cpp %}
#include <pthread.h>  

class ReqQueue {
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
    pthread_cond_t cond = PTHREAD_COND_INITIALIZER; // condition variable instance
    queue<request*> req_queue; // shared resource

    void ProduceReq(request* req) {
        pthread_mutex_lock(&mutex); // lock
        req_queue.enqueue(req);
        pthread_mutex_unlock(&mutex); // unlock
        pthread_cond_signal(&cond); // wake up one thread
    }

    request* ConsumeReq() {
        pthread_mutex_lock(&mutex); // lock
        while(req_queue.empty()) {
            pthread_cond_wait(&cond, &mutex);
        }
        request* req = req_queue.dequeue();
        pthread_mutex_unlock(&mutex); // unlock
        return req;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] Monitor CPP Example on Linux</figcaption>
</figure>

#### 1.5. Semaphore

{% highlight cpp %}
#include <semaphore.h>

queue<request*> req_queue; // shared resource
sem_t sem; // semaphore instance

void ProduceReq(request* req) {
    sem_wait(sem); // wait and decrease value
    req_queue.enqueue(req);
}

request* ConsumeReq() {
    request* req = req_queue.dequeue();
    sem_post(sem); // increase value
    return req;
}

int main() {
    sem_init(&sem, 0, 5); // initial value 5
    ...
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] Semaphore CPP Example on Linux</figcaption>
</figure>

### 2. 참조

* Mutex : [https://www.joinc.co.kr/w/Site/Thread/Beginning/Mutex](https://www.joinc.co.kr/w/Site/Thread/Beginning/Mutex)
* Mutex : [http://www.qnx.com/developers/docs/6.5.0/index.jsp?topic=%2Fcom.qnx.doc.neutrino_lib_ref%2Fp%2Fpthread_mutex_unlock.html](http://www.qnx.com/developers/docs/6.5.0/index.jsp?topic=%2Fcom.qnx.doc.neutrino_lib_ref%2Fp%2Fpthread_mutex_unlock.html)
* Spinlock : [https://seokbeomkim.github.io/posts/locks-in-the-kernel-1/](https://seokbeomkim.github.io/posts/locks-in-the-kernel-1/)
* Condition Variable : [https://elecs.tistory.com/135](https://elecs.tistory.com/135)
* Semaphore : [https://yebig.tistory.com/305](https://yebig.tistory.com/305)
* Semaphore : [https://www.joinc.co.kr/w/Site/system_programing/IPC/semaphores](https://www.joinc.co.kr/w/Site/system_programing/IPC/semaphores)
