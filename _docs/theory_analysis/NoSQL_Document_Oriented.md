---
title: NoSQL Document-oriented
category: Theory, Analysis
date: 2018-09-01T12:00:00Z
lastmod: 2018-09-01T12:00:00Z
comment: true
adsense: true
---

NoSQL DB중 하나인 Document-oriented DB를 분석한다.

### 1. Document-oriented DB

![]({{site.baseurl}}/images/theory_analysis/NoSQL_Document-oriented/Document-oriented.PNG){: width="500px"}

Document-oriented DB는 의미그대로 Document 형태의 Data를 저장하고 관리하는 DB이다. 여기서 Document는 XML이나 JSON처럼 **계층을 이루는 Key-value Data**를 의미한다. 따라서 Document-oriented DB는 Key-value DB로부터 발전된 형태의 DB로 볼 수 있다. 위의 그림은 MongoDB Document의 예시를 나타내고 있다. Document의 Key/Value 규칙은 JSON과 거의 유사하다. Key는 Object안에서 (JSON에서는 {}안에서) 반드시 Unique해야 한다. Value는 Integer부터 String까지 다양한 Data가 들어 갈 수 있다.

Document-oriented DB는 Key-value DB처럼 Schema가 필요없다. 사용자는 필요에 따라 Data를 Document에 자유롭게 넣을 수 있고, 이러한 특징은 높은 유연성(Flexibility)으로 이어진다. 또한 Key의 Unique 조건과 Key간의 계층을 제외한 Key 사이의 Depedency가 없기 때문에 비교적 높은 확장성(Scalability)를 갖고 있다.

Document-oriented DB는 각 Document마다 고유의 ID를 붙여 Document를 관리한다. 위의 그림에서 _id는 MongoDB에서 Document 관리를 위한 고유의 ID 값을 의미한다. ID는 **Indexing**되어 Document-oriented DB가 좀 더 빨리 Document를 찾을 수 있도록 도와준다. ID뿐만 아니라 사용자 원하는 Key를 Indexing 할 수도 있다. 대부분의 Document-oriented DB는 Data 덧셈,곱셈 같은 간단한 연산 작업부터 Map/Reduce까지 다양한 Data 연산 작업 기능도 지원하기 때문에 App에서 쉽게 Data를 가공하고 이용 할 수 있다.

### 2. 참조

* [https://en.wikipedia.org/wiki/Document-oriented_database](https://en.wikipedia.org/wiki/Document-oriented_database)
* [https://database.guide/what-is-a-document-store-database/](https://database.guide/what-is-a-document-store-database/)
* [https://www.slideshare.net/fabiofumarola1/9-document-oriented-databases](https://www.slideshare.net/fabiofumarola1/9-document-oriented-databases)
* [http://cs.ulb.ac.be/public/_media/teaching/infoh415/student_projects/couchdb.pdf](http://cs.ulb.ac.be/public/_media/teaching/infoh415/student_projects/couchdb.pdf)
