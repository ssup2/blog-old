---
title: PromQL Data Type
category: Theory, Analysis
date: 2022-02-14T12:00:00Z
lastmod: 2022-02-14T12:00:00Z
comment: true
adsense: true
---

PromQL의 Data Type을 정리한다.

### 1. PromQL Data Type

PromQL에는 String, Scalar, Instant Vector, Range Vector 4가지 Data Type이 존재한다.

#### 1.1. String

![[그림 1] String Type]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_String_Type.PNG)

String은 의미 그대로 문자열을 나타내는 Data Type이다. ""(큰따옴표)로 표현된다. [그림 1]에서 "ssup2" 문자열로 질의시 String Type인걸 확인할 수 있다.

#### 1.2. Scalar

![[그림 2] Scalar Type, Integer]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Scalar_Type1.PNG)

![[그림 3] Scalar Type, Float]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Scalar_Type2.PNG)

Scalar는 의미 그대로 값을 나타내는 Data Type이다. 정수, 실수 모두 표현할 수 있다. [그림 2]에서 정수 10 질의시 Scalar Type인걸 확인할 수 있다. [그림 3]에서 실수 1.1 질의시에도 Scalar Type인걸 확인할 수 있다.

#### 1.3. Instanct Vector

![[그림 4] Instanct Vector, node_memory_MemAvailable_bytes Graph]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Instant_Vector_Type2.PNG)

Instant Vector는 시간별 Data를 저장하고 있는 Data Type이다. 따라서 Instant Vector Type은 Graph로 표현이 가능하다. 각 시간대별로 여러개의 값을 가질 수 있다. [그림 4]는 Node Exporter가 노출하는 Node의 가용 Memory 크기를 시간별로 저장하고 있는 "node_memory_MemAvailable_bytes" Data의 Graph를 나타내고 있다. 각 시간대별로 3개의 값을 가지고 있기 때문에 Graph도 3개가 나타난다.

![[그림 5] Instanct Vector, node_memory_MemAvailable_bytes]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Instant_Vector_Type1.PNG)

Instant Vector에 질의시에는 **가장 최근 시간대에 저장된 Data**만 출력되며, 이전 시간의 Data를 출력하기 위해서는 **offset** 문법을 통해서 이전 시간을 지정해야 한다. [그림 5]는 "node_memory_MemAvailable_bytes" Data의 질의 결과를 나타내고 있다. 마지막 시간대에 3개의 값이 저장되어 있기 때문에 3개의 값이 모두 출력되는 것을 확인할 수 있다. 동일한 시간대에 각 값을 구분하는데 이용되는 **Label**도 확인할 수 있다. Label은 {}(중괄호)아래 Key-value 형태로 존재한다.

![[그림 6] Instanct Vector, node_memory_MemAvailable_bytes Selector]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Instant_Vector_Type3.PNG)

특정 시간대의 다수의 값 중에서 특정 값만 선택하여 얻고 싶을때는 값에 존재하는 Label을 **Selector**로 선택하면 된다. Selector는 Query에 {}(중괄호)로 나타난다. [그림 6]의 경우에는 "node_memory_MemAvailable_bytes" Data 중에서 Instance가 "192.168.0.31:9100"인 값만 선택하는 예제를 나타내고 있다. Selector는 다음과 같은 비교문을 제공한다.

* = : 값이 일치하는 경우
* != : 값이 일치하지 않는 경우
* =~ : 정규표현식이 일치하는 경우
* !~ : 정규표현식이 일치하지 않는 경우

#### 1.4. Range Vector

![[그림 7] Range Vector, node_memory_MemAvailable_bytes[1m]]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Range_Vector_Type.PNG)

### 2. 참조

* [https://prometheus.io/docs/prometheus/latest/querying/basics/#expression-language-data-types](https://prometheus.io/docs/prometheus/latest/querying/basics/#expression-language-data-types)
* [https://devthomas.tistory.com/15](https://devthomas.tistory.com/15)
* [https://gurumee92.tistory.com/244](https://gurumee92.tistory.com/244)