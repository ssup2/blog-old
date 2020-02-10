---
title: ZeroMQ
category: Theory, Analysis
date: 2020-02-09T12:00:00Z
lastmod: 2020-02-09T12:00:00Z
comment: true
adsense: true
---

### 1. ZeroMQ

#### 1.1. Messaging Pattern

##### 1.1.1. Request-reply

![[그림 1] Request-reply Sync]({{site.baseurl}}/images/theory_analysis/ZeroMQ/Request-reply_Sync.PNG){: width="200px"}

![[그림 2] Request-reply Async]({{site.baseurl}}/images/theory_analysis/ZeroMQ/Request-reply_Async.PNG){: width="650px"}

##### 1.1.2. Pub-sub

![[그림 3] Pub-sub]({{site.baseurl}}/images/theory_analysis/ZeroMQ/Pub-sub.PNG){: width="650px"}

##### 1.1.3. Pipeline

![[그림 4] Push-pull]({{site.baseurl}}/images/theory_analysis/ZeroMQ/Push-pull.PNG){: width="650px"}

##### 1.1.4. Exclusive pair

![[그림 5] Exclusive pair]({{site.baseurl}}/images/theory_analysis/ZeroMQ/Exclusive_pair.PNG){: width="200px"}

#### 1.2. Reliability

##### 1.2.1. Client-side Reliability : Lazy Pirate Pattern

##### 1.2.2. Basic Reliable Queuing : Simple Pirate Pattern

##### 1.2.3. Robust Reliable Queuing : Paranoid Pirate Pattern

##### 1.2.4. Service-Oriented Reliable Queuing : Majordomo Pattern

##### 1.2.5. Disconnected Reliability : Titanic Pattern

##### 1.2.6. High-Availability Pair : Binary Star Pattern

##### 1.2.7. Brokerless Reliability : Freelance Pattern

### 2. 참고

* [http://zguide.zeromq.org/page:all](http://zguide.zeromq.org/page:all)
* [https://blog.scottlogic.com/2015/03/20/ZeroMQ-Quick-Intro.html](https://blog.scottlogic.com/2015/03/20/ZeroMQ-Quick-Intro.html)