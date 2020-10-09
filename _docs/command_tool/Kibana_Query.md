---
title: Kibana Query Language (KQL)
category: Command, Tool
date: 2020-10-09T12:00:00Z
lastmod: 2020-10-09T12:00:00Z
comment: true
adsense: true
---

Kibana Query Language (KQL)을 정리한다.

***

* TOC
{:toc}

***

### 1. Kibana Query Language (KQL)

#### 1.1 Terms Query

Field와 Value가 정확히 일치하는 Document만 출력하는 Query를 의미한다.

* \[Field\]:\[Value\] : Field에 Value가 존재하는 Document만 출력한다.
  * respose:200 : response Field에 200 Value가 존재하는 Document만 출력한다.
  * message:ssup2 : message Field에 "ssup2" 문자열 Value가 존재하는 Document만 출력한다.
  * message:"ssup2 blog" : message Field에 "ssup2 blog" 문자열 Value가 존재하는 Document만 출력한다.

#### 1.2. Boolean Query

not, and, or 논리 연산자를 이용하는 Query를 의미한다. 괄호를 이용하여 연산자 비교 대상 제한 및 우선순위를 변경할 수 있다.

* not \[Field\]:\[Value\] : Field에 Value가 존재하지 않는 Document만 출력한다.
  * not respose:200 : response Field에 200 Value가 존재하지 않는 Document만 출력한다.

* \[Field1\]:\[Value1\] and \[Field2\]:\[Value2\] : Field1에 Value1하고 Field2에 Value2가 존재하는 Document만 출력한다.
  * respose:200 and message:"ssup2" : response Field에 200 Value가 존재하고 message Field에 ssup2 문자열 Value가 존재하는 Document만 출력한다.

* \[Field\]:(\[Value1\] or \[Value2\]) : Field에 Value1이 존재하거나 Value2가 존재하는 Document만 출력한다.
  * response:(200 or 404) : response Field에 200 Value가 존재학거나 404 Value가 존재하는 Document만 출력한다.

#### 1.3. Range Query

\>, >=, <, <= 비교 연산자를 이용하는 Query를 의미한다.

* * \[Field\]:\[Value\]\>Number : Field에 Number보다 작은 Value가 존재하는 Document만 출력한다.

#### 1.4. Wildcard Query

Wildcard(*)를 이용하는 Query를 의미한다.

* \[Field\]:* : Field가 존재하는 Document만 출력한다.
  * respose:* : response Field가 존재하는 Document만 출력한다.

* \[Field\]:\[Value\]* : Field에 "Value" 문자열로 시작하는 Value가 존재하는 Document만 출력한다.
  * message:ssup* : message Field에 "ssup" 문자열로 시작하는 Value가 존재하는 Document만 출력한다.

* \[Field\]*:\[Value\] : "Field" 문자열로 시작하는 Field에 Value가 존재하는 Document만 출력한다.
  * mess*:ssup2 : "mess" 문자열로 시작하는 Field에 "ssup2" 문자열 Value가 존재하는 Document만 출력한다.

#### 1.5. Nested Field Query

Field 내부에 Field가 존재하는 Nested Field에 존재하는 쿼리를 의미한다.

* \[Field1\]*:{\[Field2\]:\[Value\]} : Field1 내부의 Field2에 Value가 존재하는 Document만 출력한다. 

### 2. 참조

* [https://www.elastic.co/guide/en/kibana/master/kuery-query.html](https://www.elastic.co/guide/en/kibana/master/kuery-query.html)
* [https://www.elastic.co/guide/en/beats/packetbeat/current/kibana-queries-filters.html](https://www.elastic.co/guide/en/beats/packetbeat/current/kibana-queries-filters.html)
