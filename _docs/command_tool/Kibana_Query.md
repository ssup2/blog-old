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

* <Field>:<Value> : Field에 Value가 존재하는 Document만 출력한다.
  * respose:200 : response Field에 200 Value가 존재하는 Document만 출력한다.
  * message:"ssup2" : message Field에 ssup2 문자열 Value가 존재하는 Document만 출력한다.

#### 1.2. Boolean Query

#### 1.3. Range Query

#### 1.4. Exist Query

#### 1.5. Wildcard Query

#### 1.6. Nested Field Query

### 2. 참조

* [https://www.elastic.co/guide/en/kibana/master/kuery-query.html](https://www.elastic.co/guide/en/kibana/master/kuery-query.html)
* [https://www.elastic.co/guide/en/beats/packetbeat/current/kibana-queries-filters.html](https://www.elastic.co/guide/en/beats/packetbeat/current/kibana-queries-filters.html)
