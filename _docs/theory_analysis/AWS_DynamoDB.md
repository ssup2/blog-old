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

![[그림 1] DynamoDB Base Table]({{site.baseurl}}/images/theory_analysis/AWS_DynamoDB/AWS_DynamoDB_BaseTable.PNG){: width="700px"}

#### 1.1. Partition Key

#### 1.2. Sorted Key

#### 1.3. Primary Key

### 2. Data Type

TODO

### 3. Secondary Index

#### 3.1. LSI (Local Secondary Index)

![[그림 2] DynamoDB Base Table]({{site.baseurl}}/images/theory_analysis/AWS_DynamoDB/AWS_DynamoDB_LSI.PNG){: width="650px"}

#### 3.2. GSI (Global Secondary Index)

![[그림 3] DynamoDB Base Table]({{site.baseurl}}/images/theory_analysis/AWS_DynamoDB/AWS_DynamoDB_GSI.PNG){: width="600px"}

### 4. Consistency

TODO

### 5. Throughput

TODO

### 6. REST API

TODO

### 7. 참조

* [https://www.youtube.com/watch?v=I7zcRxHbo98](https://www.youtube.com/watch?v=I7zcRxHbo98)
* [https://www.hardcoded.se/2021/01/20/graphql-api-with-appsync-and-dynamodb/](https://www.hardcoded.se/2021/01/20/graphql-api-with-appsync-and-dynamodb/)
* Single Table Design : [https://emshea.com/post/part-1-dynamodb-single-table-design](https://emshea.com/post/part-1-dynamodb-single-table-design)
* Secondary Index : [https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html)
* Secondary Index : [https://www.dynamodbguide.com/local-or-global-choosing-a-secondary-index-type-in-dynamo-db](https://www.dynamodbguide.com/local-or-global-choosing-a-secondary-index-type-in-dynamo-db)
* Secondary Index : [https://stackoverflow.com/questions/21381744/difference-between-local-and-global-indexes-in-dynamodb](https://stackoverflow.com/questions/21381744/difference-between-local-and-global-indexes-in-dynamodb)