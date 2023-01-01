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

[그림 1]은 DynamoDB의 Table을 나타내고 있다. Table은 **Item**의 집합으로 구성되어 있다.

#### 1.1. Item

Item은 Table의 **Row** 역할을 수행한다. 각 Item은 **Primary Key**와 **Attribute**로 구성되어 있다.

#### 1.2. Primary Key

Primary Key는 Table에서 반드시 고유한 값을 가져야 한다. Primary Key는 **Partition Key** 또는 **Partition Key** + **Sort Key**로 구성되어 있다. 즉 Partition Key는 필수 요소지만 Sort Key는 필수 요소가 아니다. Primary Key 값은 반드시 

##### 1.2.1. Partition Key

Partition Key는 이름 그대로 Item이 위치할 Disk의 Partition를 결정하는 Key이다. [그림 1]에서 "USER#1111"를 Partition Key로 갖는 3개의 Item은 모두 동일한 Disk의 Partition에 위치하게 된다. DynamoDB는 Parition Key를 기반으로 **Consistent Hashing**을 이용하여 Disk의 Partition을 결정하는 것으로 알려져 있다.

DynamoDB의 성능을 끌어올리기 위해서는 Item들을 여러 Disk의 Parition으로 분배하여 각 Disk Partition의 성능을 이끌어내야 한다. 따라서 Partition Key를 잘 설계하여 Item들이 다수의 Disk Partition으로 골고루 분배되도록 설계해야 한다. 만약 요청이 하나의 Partition Key 또는 하나의 Disk Partition으로 쏠릴경우 Throttling이 발생하여 일시적으로 Data Read/Write 동작이 수행되지 않을 수 있다.

Partition Key는 "=", "!="과 같은 비교 연산자만 이용할 수 있다.

##### 1.2.2. Sort Key

Sort Key는 이름 그대로 Disk 내부의 Partition에서 Column을 정렬하는데 이용하는 Key이다. Sort Key를 기반으로 내부적으로 Index를 생성하기 때문에 비교 연산자와 ">", "<="과 같은 범위 연산를 이용할 수 있다. 따라서 DynamoDB에서 정렬과 같은 동작을 수행하기 위해서는 반드시 Sort Key를 활용해야 한다.

#### 1.3. Attribute

Attribute는 Table의 **Column** 역할을 수행한다. 각 Item마다 다른 Attribute를 갖을 수 있다. [그림 1]에서 첫번째 Item에서는 "Email Address", "Total Amount", "Phone"을 Attribute를 갖고 있고, 두번째 Item에서는 "Purchase Price", "Purchase Count"를 Attribute로 가지고 있다. 서로 다른 Attribute를 갖고 있는 것을 확인할 수 있다.

일반적인 Attribute를 대상으로는 비교 연산자, 또는 범위 연산자를 이용할 수 없고, **LSI (Local Secondary Index)** 또는 **GSI (Global Secondary Index)**와 같은 Secondary Index를 생성하고 이용해야 한다.

### 2. Secondary Index

Secondary Index는 Table 생성시 Sort Key로 인해서 생성되는 Index와 별개의 Index가 필요할 경우 이용할 수 있는 기능이다. LSI (Local Secondary Index)와 GSI (Global Secondary Index)가 존재한다. Secondary Index의 경우에도 Partition Key와 Sort Key의 조합으로 구성된 Primary Key가 반드시 존재하며, Secondary Index를 생성하기 위해서 참조하는 원본의 Table을 **Base Table**이라고 명칭한다.

#### 2.1. LSI (Local Secondary Index)

![[그림 2] DynamoDB LSI]({{site.baseurl}}/images/theory_analysis/AWS_DynamoDB/AWS_DynamoDB_LSI.PNG){: width="700px"}

[그림 2]은 [그림 1]의 Table을 Base Table로 하여 생성한 LSI의 예제를 나타내고 있다. LSI의 Partition Key는 반드시 Base Table의 Partition Key와 동일해야 한다. 하지만 Sort Key의 경우에는 Base Table의 임의의 Attribute를 선택하여 이용할 수 있다. [그림 2]에서도 [그림 1]과 Partition Key는 "PK"로 동일하지만, Sort Key는 Base Table의 "Created Date" Attribute를 "LSI_SK"라는 이름으로 이용하고 있다.

LSI 구성시 Base Table의 전체 또는 일부 Attribute들을 Projection 수행을 통해서 LSI의 Projected Attribute로 가져올 수 있다. [그림 2]에서는 "Email Address", "Purchase Price", "Purchase Count", "Count" 4개의 Attribute를 Projected Attribute로 이용하고 있다. LSI의 경우에는 Projected Attribute로 존재하지 않더라도 Base Table에서 Attribute를 가져올 수 있는 장점을 가지고 있다. 하지만 Base Table을 한번더 읽으면서 비용이 추가적으로 발생하고 성능도 느려지는 문제가 있기 때문에, LSI를 이용하는 경우에는 가능하면 Projected Attribute만 이용하는 것이 권장된다.

LSI의 Read 동작은 Base Table의 RCU (Read Capacity Unit)를 소모한다. Base Table의 Write 동작이 발생하면 LSI에도 Write된 내용이 반영되며 이경우에도 Base Table의 WCU (Write Capacity Unit)를 소모하며, Base Table, LSI 두번 Write를 수행하기 때문에 WCU도 두배 많이 소모된다.

LSI는 (Base) Table을 생성할 경우에만 설정을 통해서 같이 생성이 가능하며, (Base) Table 생성 이후에는 생성, 삭제가 불가능하다. 또한 하나의 Base Table당 최대 5개의 LSI만 생성 가능하며, LSI의 하나의 Partiton의 크기는 10GB를 넘지 못한다는 제약조건을 가지고 있다. 하지만 LSI는 **Strongly-Consistency Read**를 지원하고, Base Table의 RCU, WCU를 소모하기 때문에 Provisioned Capacity Mode를 이용하는 경우 별도의 RCU, WCU를 소모하는 GSI에 대비하여 비용 절감효과를 얻을 수 있다는 장점을 가지고 있다.

#### 2.2. GSI (Global Secondary Index)

![[그림 3] DynamoDB GSI]({{site.baseurl}}/images/theory_analysis/AWS_DynamoDB/AWS_DynamoDB_GSI.PNG){: width="650px"}

[그림 3]은 [그림 1]의 Table을 Base Table로 하여 생성한 GSI의 예제를 나타내고 있다. GSI의 Partition Key와 Sort Key는 Base Table의 임의의 Attribute를 선택하여 구성할 수 있다.

### 3. Capacity Mode

TODO

### 4. Data Type

DynamoDB의 Data Type은 Scalar, Document, Set 3가지로 분류할 수 있다. 각 분류마다 아래의 Data Type들이 존재한다.

* Scalar : String, Number, Binary, Boolean, Null
* Document : List, Map
* Set : String Set, Number Set, Binary Set

### 5. Consistency

TODO

### 6. DAX (DynamoDB Accelerator)

TODO

### 7. TTL

TODO

### 8. Locking

TODO

### 9. REST API

TODO

### 10. 참조

* [https://www.youtube.com/watch?v=I7zcRxHbo98](https://www.youtube.com/watch?v=I7zcRxHbo98)
* Single Table Design : [https://emshea.com/post/part-1-dynamodb-single-table-design](https://emshea.com/post/part-1-dynamodb-single-table-design)
* Secondary Index : [https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html)
* Secondary Index : [https://www.dynamodbguide.com/local-or-global-choosing-a-secondary-index-type-in-dynamo-db](https://www.dynamodbguide.com/local-or-global-choosing-a-secondary-index-type-in-dynamo-db)
* Secondary Index : [https://stackoverflow.com/questions/21381744/difference-between-local-and-global-indexes-in-dynamodb](https://stackoverflow.com/questions/21381744/difference-between-local-and-global-indexes-in-dynamodb)
* Architecture : [https://medium.com/swlh/architecture-of-amazons-dynamodb-and-why-its-performance-is-so-high-31d4274c3129](https://medium.com/swlh/architecture-of-amazons-dynamodb-and-why-its-performance-is-so-high-31d4274c3129)