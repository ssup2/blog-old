---
title: AWS DynamoDB
category: Theory, Analysis
date: 2022-12-24T12:00:00Z
lastmod: 2022-12-24T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

AWS의 DynamoDB Service를 분석한다. DynamoDB Service는 Managed Key-value Data 또는 Documented Data 저장을 지원하는 Managed NoSQL DB Service이다.

### 1. Table

![[그림 1] DynamoDB Table]({{site.baseurl}}/images/theory_analysis/AWS_DynamoDB/AWS_DynamoDB_BaseTable.PNG)

[그림 1]은 DynamoDB의 Table을 나타내고 있다. Table은 크게 **Primary Key**와 **Attributes**로 구성되어 있다.

#### 1.1. Primary Key

Primary Key는 Table에서 반드시 고유한 값을 가져야 한다. Primary Key는 **Partition Key** 또는 **Partition Key** + **Sort Key**로 구성되어 있다. 즉 Partition Key는 필수 요소지만 Sort Key는 필수 요소가 아니다.

##### 1.1.1. Partition Key

Partition Key는 이름 그대로 Row가 위치할 Disk의 Partition를 결정하는 Key이다. [그림 1]에서 "USER#1111"를 Partition Key로 갖는 3개의 Row는 모두 동일한 Disk의 Partition에 위치하게 된다. DynamoDB는 Parition Key를 기반으로 **Consistent Hashing**을 이용하여 Disk의 Partition을 결정하는 것으로 알려져 있다.

DynamoDB의 성능을 끌어올리기 위해서는 Row들을 여러 Disk의 Parition으로 분배하여 각 Disk Partition의 성능을 이끌어내야 한다. 따라서 Partition Key를 잘 설계하여 Row들이 다수의 Disk Partition으로 골고루 분배되도록 설계해야 한다. 만약 요청이 하나의 Partition Key 또는 하나의 Disk Partition으로 쏠릴경우 Throttling이 발생하여 일시적으로 Data Read/Write 동작이 수행되지 않을 수 있다.

Partition Key는 "=", "!="과 같은 비교 연산자만 이용할 수 있다.

##### 1.1.2. Sort Key

Sort Key는 이름 그대로 Disk 내부의 Partition에서 Column을 정렬하는데 이용하는 Key이다. Sort Key는 비교 연산자와 ">", "<="과 같은 범위 연산를 이용할 수 있다. 따라서 DynamoDB에서 정렬과 같은 동작을 수행하기 위해서는 반드시 Sort Key를 활용해야 한다.

#### 1.2. Attribute

### 2. Data Type

TODO

### 3. Secondary Index

#### 3.1. LSI (Local Secondary Index)

![[그림 2] DynamoDB LSI]({{site.baseurl}}/images/theory_analysis/AWS_DynamoDB/AWS_DynamoDB_LSI.PNG){: width="700px"}

#### 3.2. GSI (Global Secondary Index)

![[그림 3] DynamoDB GSI]({{site.baseurl}}/images/theory_analysis/AWS_DynamoDB/AWS_DynamoDB_GSI.PNG){: width="650px"}

### 4. Consistency

TODO

### 5. Throughput

TODO

### 6. DAX (DynamoDB Accelerator)

### 7. TTL

### 8. Locking

### 9. REST API

TODO

### 10. 참조

* [https://www.youtube.com/watch?v=I7zcRxHbo98](https://www.youtube.com/watch?v=I7zcRxHbo98)
* [https://www.hardcoded.se/2021/01/20/graphql-api-with-appsync-and-dynamodb/](https://www.hardcoded.se/2021/01/20/graphql-api-with-appsync-and-dynamodb/)
* Single Table Design : [https://emshea.com/post/part-1-dynamodb-single-table-design](https://emshea.com/post/part-1-dynamodb-single-table-design)
* Secondary Index : [https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html)
* Secondary Index : [https://www.dynamodbguide.com/local-or-global-choosing-a-secondary-index-type-in-dynamo-db](https://www.dynamodbguide.com/local-or-global-choosing-a-secondary-index-type-in-dynamo-db)
* Secondary Index : [https://stackoverflow.com/questions/21381744/difference-between-local-and-global-indexes-in-dynamodb](https://stackoverflow.com/questions/21381744/difference-between-local-and-global-indexes-in-dynamodb)
* Architecture : [https://medium.com/swlh/architecture-of-amazons-dynamodb-and-why-its-performance-is-so-high-31d4274c3129](https://medium.com/swlh/architecture-of-amazons-dynamodb-and-why-its-performance-is-so-high-31d4274c3129)