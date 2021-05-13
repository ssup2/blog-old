---
title: Redis Data Type
category: Theory, Analysis
date: 2021-05-14T12:00:00Z
lastmod: 2021-05-14T12:00:00Z
comment: true
adsense: true
---

Redis의 Data Type을 분석한다.

### 1. Redis Data Type

Redis는 기본적으로 Key-Value Store 역활을 수행하는 저장소 이지만, **Value**에 다양한 Data Type을 지원한다는 특징을 가지고 있다.

#### 1.1. Strings

Strings Type은 의미 그대로 문자열을 저장하는 Type이다. 문자열은 실제 문자열 뿐만 아니라 JPEG Image와 같은 다양한 Data를 저장하는 용도로 이용할 수 있다. 숫자를 저장하는 경우 숫자를 Atomic 하게 변경하는 "INCR", "DECR", "INCRBY" 명령어를 이용할 수 있으며, 문자열을 저장하는 경우 문자열을 조작하는 "APPEND", "GETRANGE", "SETRANGE" 명령어를 이용할 수 있다. "SETBIT", "GETBIT" 명령어를 통해서 Bit Operation도 가능하다. 최대 512MB까지 저장이 가능하다.

#### 1.2. Lists

Lists Type은 의미 그대로 문자열 List를 저장하는 Type이다. List의 문자열을 추가 순서에 따라서 정렬되며 "LPUSH", "RPUSH" 명령어를 이옹하여 양쪽으로 추가 가능하며, "LPOP", "RPOP" 명령어를 이용하여 양쪽으로 제거가 가능하다. List 중간의 문자열 제거 및 Sorting을 지원하지 않는다.

#### 1.3. Sets

Sets Type은 Lists Type과 유사하지만 중복 값을 허용하지 않는 Type이다. 내부적으로 Hash Table 기반으로 문자열을 관리하고 있어서, 문자열 추가 및 문자열 검색 시간이 O(1)이라는 특징을 갖는다. "SADD" 명령어를 이용하여 문자열을 추가할 수 있으며, "SPOP" 명령어를 이용하여 문자열을 제거할 수 있다.

#### 1.4. Sorted sets

Sorted sets Type은 Sets Type과 유사하지만 문자열과 같이 저장되는 **Score**라는 값으로 정렬한다는 점이 다르다. 따라서 문자열 추가시 Score도 같이 설정하여 추가해야 한다. "ZADD" 명령어를 이용하여 문자열 및 Score를 추가할 수 있으며, "ZPOPMIN", "ZPOPMAX" 명령어를 이용하여 Score가 가장 크거가 작은 문자열을 제거할 수 있다. 문자열을 지정하여 제거하는 기능은 제공하지 않는다. "ZRANGE" 명령어를 이용하여 Score를 기준으로 특정 범위의 문자열도 얻을 수 있다.

#### 1.5. Hashes

Hashes Type은 문자열로 구성된 Key-Value를 저장하는 Type이다. "HSET" 명령어를 이용하여 문자열 Key-Value를 저장하고, "HGET" 명령어를 이용하여 문자열 Key를 통해서 문자열 Value를 얻는다.

### 2. 참조

* [https://redis.io/topics/data-types](https://redis.io/topics/data-types)
* [https://redis.io/topics/data-types-intro](https://redis.io/topics/data-types-intro)
* [https://kimpaper.github.io/2016/07/27/redis-datatype/](https://kimpaper.github.io/2016/07/27/redis-datatype/)
* [https://stackoverflow.com/questions/15216897/how-does-redis-claim-o1-time-for-key-lookup](https://stackoverflow.com/questions/15216897/how-does-redis-claim-o1-time-for-key-lookup)
