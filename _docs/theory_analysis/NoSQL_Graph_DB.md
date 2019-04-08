---
title: NoSQL Graph DB
category: Theory, Analysis
date: 2018-09-10T12:00:00Z
lastmod: 2018-09-10T12:00:00Z
comment: true
adsense: true
---

NoSQL DB중 하나인 Graph DB를 분석한다.

### 1. Graph DB

![[그림 1] NoSQL Graph DB]({{site.baseurl}}/images/theory_analysis/NoSQL_Graph_DB/NoSQL_Graph.PNG){: width="500px"}

Graph DB는 의미그대로 Data를 Graph 형태로 저장하고 관리하는 DB를 의미한다. 여기서 Graph는 **Data와 Data 사이를 연결하는 Data Relationship**으로 구성된다. [그림 1]은 Graph 형태의 Data를 나타내고 있다. Graph의 Node는 Data를 의미하고, Graph의 Edge는 Data Relationship을 나타낸다. 사용자는 Schema의 정의없이 자유롭게 Data와 Data Relation를 Graph DB에 저장할 수 있다. Transaction은 지원하지 않는다.

#### 1.1. vs RDBMS

RDBMS는 Data Relationship을 Table의 PK (Primary Key)와 FK (Foreign Key)를 이용하여 **간접적**으로 나타낸다. 따라서 여러 Table에 저장된 연관된 Data를 한꺼번에 조회, 조작하기 위해서는 **Join** 명령어를 이용하여 반드시 Table을 연결해야 한다. 반면 Graph DB는 Data와 Data Relationship을 같이 저장하기 때문에, 연관된 Data를 한꺼번에 조회, 조작하는 경우에도 Join과 같은 Data를 연결하는 동작이 불필요하다. RDBMS의 Join 명령어는 Data가 커질수록 많은 부하가 발생한다. 따라서 많은 Data 및 Data Relation을 저장하는 경우 Graph DB의 사용을 고려할 필요가 있다.

### 2. 참조

* [https://database.guide/what-is-a-graph-database/](https://database.guide/what-is-a-graph-database/)
* [https://www.infoworld.com/article/3263764/what-is-a-graph-database-a-better-way-to-store-connected-data.html](https://www.infoworld.com/article/3263764/what-is-a-graph-database-a-better-way-to-store-connected-data.html)
* [https://medium.com/@mtbuzzerseo/graph-database-vs-relational-database-e5798281f6ef](https://medium.com/@mtbuzzerseo/graph-database-vs-relational-database-e5798281f6ef)
* [https://stackoverflow.com/questions/13046442/comparison-of-relational-databases-and-graph-databases](https://stackoverflow.com/questions/13046442/comparison-of-relational-databases-and-graph-databases)
