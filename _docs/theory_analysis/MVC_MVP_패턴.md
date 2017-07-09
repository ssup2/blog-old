---
title: MVC, MVP 패턴
category: Theory, Analysis
date: 2017-03-14T11:00:00Z
lastmod: 2017-03-14T11:00:00Z
comment: true
adsense: true
---

GUI 프로그래밍에 많이 이용되는 프로그래밍 모델인 MVC 패턴과 MVP 패턴을 분석한다.

### 1. MVC 패턴

![]({{site.baseurl}}/images/theory_analysis/MVC_MVP_Pattern/MVC_Pattern.PNG){: width="600px"}

MVC 패턴은 Model, View, Controller 3가지로 구성된다. Model은 Application에서 이용하는 Data를 DB로부터 얻어오고, Data를 가공하는 부분(Business Logic)이다. View는 User가 이용하는 UI를 보여주는 부분이다. 마지막으로 Controller는 User의 요청을 받아 Model이나 View에게 전달하고, Model과 View사이의 조율 역활도 수행한다. JSP/Servlet에서 이용된다.

#### 1.1. JSP, Servlet

![]({{site.baseurl}}/images/theory_analysis/MVC_MVP_Pattern/MVC_Pattern_Model1_with_JSP.PNG){: width="700px"}

위 그림은 JSP를 이용한 MVC Model 1을 나타내고 있다. JSP는 View와 Controller의 역활을 수행한다. 간단한 WebPage를 제작할때 이용하는 Model이다.

![]({{site.baseurl}}/images/theory_analysis/MVC_MVP_Pattern/MVC_Pattern_Model2_with_JSP_Servlet.PNG){: width="700px"}

위 그림은 Servlet과 JSP를 이용한 MVC Model 2를 나타내고 있다. JSP는 View의 역활을 수행하고 Servlet은 Controller의 역활을 수행한다. JSP MVC Model 2는 Model이 직접 View를 Update하지 않고 Conroller를 통해 Update한다.

### 2. MVP 패턴

![]({{site.baseurl}}/images/theory_analysis/MVC_MVP_Pattern/MVP_Pattern.PNG){: width="600px"}

MVP 패턴은 Model, View, Presenter 3가지로 구성된다. MVC 패턴과는 다르게 Presenter가 구성요소로 포함되어 있다. Presenter는 Model과 View의 징검다리 역활을 수행한다. MVC 패턴과 다르게 모든 User의 요청은 View로 먼저 전달되고 Model과 View 사이의 의존성이 없다는게 특징이다. Android Application에서 이용된다.

### 3. 참조

* [http://hackersstudy.tistory.com/71](http://hackersstudy.tistory.com/71)
