---
title: REST API
category: Theory, Analysis
date: 2017-03-29T12:00:00Z
lastmod: 2017-03-29T12:00:00Z
comment: true
adsense: true
---

REST(Representational State Transfer) API를 분석한다.

### 1. REST API

REST는 Representational State Transfer의 약자로 **분산 시스템** 환경에 최적화된 **Architectural Style**이다. REST는 Server와 Client 사이의 표준을 정의하고 있지는 않지만, **Stateless, Uniform Interface, Server/Client의 역활**같은 몇가지 제한을 두고 있다. 이러한 REST의 특징에 가장 잘 부합하고 있는 Protocol이 **HTTP**이기 때문에 대부분의 REST API는 HTTP를 이용하고 있다. (REST API로 반드시 HTTP를 이용할 필요는 없다.)

#### 1.1. 특징

위에서 언급한 REST의 특징이 REST API에도 그대로 반영되어 나타난다.

##### 1.1 Stateless

REST API는 Client Session(State)에 관계 없이 언제나 같은 동작만을 수행한다. 이전 Architecture의 Server는 Client와의 Session을 유지한다. Server API는 Session에 따라서 다른 동작을 수행 할 수 있었다. REST API를 제공하는 Server는 Client와의 Session을 유지 하지 않고, 언제나 동일한 동작을 수행한다.

기존의 Architecture에서는 Session 유지를 위해서 Client는 언제나 동일한 Server와 연결되어야 한다. 따라서 Server의 **Scale Out**시 Session을 고려한 Load Balancing 기법이 반드시 적용되야 한다. REST API는 Stateless하기 때문에 Client는 임의의 Server에 연결하여 REST API를 이용 할 수 있다. 따라서 REST API를 이용하면 단순한 Load Balancing 알고리즘만으로 쉽게 Scale Out을 구현 할 수 있다.

Stateless 특징 때문에 Client는 REST API를 호출할때 마다 이전에 Sever에게 보냈던 정보도 반복해서 보내야 한다. 이렇게 반복되는 정보는 Encoding 되거나 암호화 되어 **Token**형태로 주고 받는다. 현재 인증/인가시 많이 이용되고 있다. Client의 인증/인가 정보를 Token으로 저장한뒤 Client가 REST API를 호출 할때 마다 해당 Token도 같이 Server에게 보내어 매번 인증/인가를 받는다.

##### 1.2. Uniform Interface

REST API는 URI를 통해서 Resource의 위치를 나타내고, HTTP Method를 통해 해당 Resource를 대상으로 어떤 동작을 수행할지를 결정하는 단순하고도 제한된 Interface를 제공한다.

*

#### 1.2. Resource, Collection

#### 1.2. HTTP Method

REST API에서는 다음과 같은 HTTP Method들이 이용된다.

* GET - Resource를 가져 온다.
* POST -
* PUT
* DELETE
* HEAD
* PATCH
* OPTION

#### 1.3. Design

Subquery

#### 1.4. Response Code

### 2. 참조

* [http://meetup.toast.com/posts/92](http://meetup.toast.com/posts/92)
* [https://spring.io/understanding/REST](https://spring.io/understanding/REST)
* [http://restful-api-design.readthedocs.io/en/latest/methods.html](http://restful-api-design.readthedocs.io/en/latest/methods.html)
