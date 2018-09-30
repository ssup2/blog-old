---
title: 직렬화 (Serialization), 마샬링 (Marshaling)
category: Theory, Analysis
date: 2017-02-20T00:07:00Z
lastmod: 2017-02-20T00:07:00Z
comment: true
adsense: true
---

유사 의미를 갖고 있는 Serialization과 Marshaling을 비교한다. 

### 1. Serialization (직렬화)

Serialization는 **Object의 Member Data**를 외부로 전달할 수 있게 Byte Stream같은 Primitive 형태로 변형하는 과정을 의미한다. 반대로 Primitive를 Object의 Member Data로 변형하는 과정을 Unserialization (역직렬화)라고 한다.

### 2. Marshaling

Marshaling은 **Object 자체**를 외부로 전달 할 수 있게 변형하는 과정을 의미한다. Object의 Member Data뿐만 아니라 필요에 따라서 **Object의 Meta Data**도 같이 전송한다. Marshaling 과정에서 Object의 Member Data를 위한 Serialization 과정이 발생한다. 따라서 Serialization이 Marshaling의 일부분이라고 할 수 있다. Marsaling 과정을 통해 변형된 Object를 원래의 Object로 돌리는 과정을 Unmarshalling이라고 한다.

### 3. 참조

* [http://stackoverflow.com/questions/770474/what-is-the-difference-between-serialization-and-marshaling](http://stackoverflow.com/questions/770474/what-is-the-difference-between-serialization-and-marshaling)
