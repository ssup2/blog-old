---
title: Shared Lock, Exclusive Lock
category: Theory, Analysis
date: 2017-04-30T00:07:00Z
lastmod: 2017-04-30T00:07:00Z
comment: true
adsense: true
---

Shared Lock, Exclusive Lock 기법을 분석한다.

### 1. Shared Lock, Exclusive Lock

#### 1.1. Shared Lock

Read Lock이라고도 불리며 Critical Section 진입 후 Read 동작만 수행하는 경우 이용한다. Critical Section 진입 시 Shared Lock이 걸려 있어도, Shared Lock을 들고 Critical Section에 진입하여 Data를 Read 할 수 있다. 즉 여러개의 Thread가 동시에 Critical Section에 진입하여 Read 동작을 수행 할 수 있다. Critical Section 진입 시 Exclusive Lock이 걸려있는 경우, Exclusive Lock이 풀릴때 까지 대기한다.

#### 1.2. Exclusive Lock

Write Lock이라고도 불리며 Critical Section 진입 후 Write 동작을 수행하는 경우 이용한다. Critical Section 진입 시 Shared Lock, Exclusive Lock이 걸려있지 않은 경우에만 Exclusive Lock을 들고 Critical Section에 진입 할 수 있다. 즉 Write 수행시 동시에 오직 하나의 Thread만 Critical Section에 진입하여 Write를 수행 할 수 있다.

### 2. 장점

일반적인 Lock 기법은 무조건 동시에 오직 하나의 Thread만 Critical Section을 접근 할 수 있다. 따라서 Critical Section안에서의 Read 동작도 동시에 오직 하나의 Thread만 수행 할 수 있었다.

Shared Lock, Exclusive Lock 기법은 통해 동시에 여러 Thread가 Critical Section 안에서 Read 동작을 수행 할 수 있기 때문에, Critical Section안에서 Read 동작이 많은 경우 일반 Lock에 비해 좀더 병목현상을 줄일 수 있다.

### 3. 참조

* [http://jeong-pro.tistory.com/94](http://jeong-pro.tistory.com/94)
