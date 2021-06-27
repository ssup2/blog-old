---
title: Process/Thread Synchronization
category: Theory, Analysis
date: 2021-06-27T12:00:00Z
lastmod: 2021-06-27T12:00:00Z
comment: true
adsense: true
---

### 1. Process/Thread Syncronization

#### 1.1. Mutex

{% highlight cpp %}
#include <pthread.h>  

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
int count; // shared resource

void increase_count() {
    pthread_mutex_lock(&mutex); // lock
    count++;
    pthread_mutex_unlock(&mutex); // unlock
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Mutex CPP Example on Linux</figcaption>
</figure>

#### 1.2. Condition Variable

{% highlight cpp %}
#include <pthread.h>  

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
pthread_cond_t cond = PTHREAD_COND_INITIALIZER; // condition variable instance
queue<request*> req_queue; // shared resource

void produce_req_wakeup_one(request* req) {
    pthread_mutex_lock(&mutex); // lock
    req_queue.enqueue(req);
    pthread_mutex_unlock(&mutex); // unlock
    pthread_cond_signal(&cond); // wake up one thread
}

void produce_req_wakeup_all(request* req) {
    pthread_mutex_lock(&mutex); // lock
    req_queue.enqueue(req);
    pthread_mutex_unlock(&mutex); // unlock
    pthread_cond_broadcast(&cond); // wake up all thread
}

request* consume_req() {
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

#### 1.3. Monitor

#### 1.4. Semaphore

{% highlight cpp %}
#include <pthread.h>  

queue<request*> req_queue; // shared resource
sem_t sem; // semaphore instance

void produce_req(request* req) {
    sem_wait(sem); // wait and decrease value
    req_queue.enqueue(req);
}

request* consume_req() {
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
<figcaption class="caption">[Code 3] Semaphore CPP Example on Linux</figcaption>
</figure>

### 2. 참조

* Mutex : [https://www.joinc.co.kr/w/Site/Thread/Beginning/Mutex](https://www.joinc.co.kr/w/Site/Thread/Beginning/Mutex)
* Condition Variable : [https://elecs.tistory.com/135](https://elecs.tistory.com/135)
* Semaphore : [https://yebig.tistory.com/305](https://yebig.tistory.com/305)
* Semaphore : [https://www.joinc.co.kr/w/Site/system_programing/IPC/semaphores](https://www.joinc.co.kr/w/Site/system_programing/IPC/semaphores)
