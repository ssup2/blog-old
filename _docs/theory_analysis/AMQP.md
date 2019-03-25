---
title: AMQP
category: Theory, Analysis
date: 2017-12-13T12:00:00Z
lastmod: 2017-12-13T12:00:00Z
comment: true
adsense: true
---

MQ(Message Queue) Protocol인 AMQP(Advanced Message Queuing Protocol)를 분석한다.

### 1. AMQP (Advanced Message Queuing Protocol)

AMQP는 **표준 MQ Protocol**으로써 App사이의 Message를 전달할 때 Message를 어떻게 Queuing하고 Routing 할지 정의하고 있다. AMQP는 다양한 Message 전달 옵션을 정의하고 있기 때문에 많은 App들이 AMQP를 이용하여 Message 전달 규칙을 설계하고 이용하고 있다. RabbitMQ는 AMQP를 제공하는 대표적인 MOM(Message-Oriented Middleware)으로써 많은 곳에서 이용되고 있다.

![]({{site.baseurl}}/images/theory_analysis/AMQP/AMQP_Architecture.PNG){: width="700px"}

위의 그림은 AMQP의 Architecture를 나타내고 있다. AMQP는 Producer, Consumer, Broker로 구성되어 있다. Producer는 Message를 생산하여 전송하는 주체이고, Consumer는 Producer가 생산한 Message를 받아서 소비하는 주체이다. Broker는 Producer와 Consumer 사이에서 Message를 중개하는 역활을 수행한다. Broker는 다시 **Exchange**와 **Queue**로 구성되어 있다.

Producer는 임의의 Exchange를 선택하여 자유롭게 Message를 전송할 수 있다. Producer는 Exchange에게 Message와 함께 Message Routing을 위한 **Routing Key**를 같이 전달한다. Exchange는 Routing Key를 이용하여 해당 Message를 **Filtering** 하거나, Queue 또는 다른 Exchange에게 **Routing** 한다. Exchange는 자신과 연결되어 있는 Queue 또는 Exchange에게만 Message를 전달 할 수 있는데, 이러한 연결 과정을 **Binding**이라고 표현한다.

Queue는 Consumer에게 전달될 Message를 임시로 저장하는 곳이다. Broker는 Queue의 Message를 Consumer에게 전송 한뒤 바로 삭제하지 않고, Consumer에게 ACK Message를 받은 후에 삭제 한다. Broker는 Consumer에게 ACK Message를 받지 못하면 Broker에 설정된 일정 횟수만큼 Message를 재전송한다. 여러번 Message를 전송한 후에도 ACK Message를 받지 못하면 Message를 Queue에서 삭제하거나, 다시 Exchange로 보내어 다른 Consumer에게 전달 되도록 할 수 있다. 하나의 Queue에게 다수의 Consumer가 붙으면 Message는 Round-Robin 알고리즘에 따라 Consumer에게 전달된다. 이러한 특징은 Consumer를 쉽게 Scale-Out 할 수 있도록 만든다.

#### 1.1 Exchange Type

Exchange는 Routing 규칙에 따라서 Fanout, Direct, Topic, Header 4가지 Type을 지원한다.

##### 1.1.1. Direct

![]({{site.baseurl}}/images/theory_analysis/AMQP/AMQP_Exchange_Direct.PNG){: width="500px"}

Direct Exchange는 하나의 Queue 또는 Exchange에게 Message를 Unicast하는 Exchange이다. Unicast의 기준은 Message와 함께 전달되는 Routing Key이다. Direct Exchange와 Binding하기 위해서는 Direct Exchange에게 Routing Key를 넘겨주어야 한다. Direct Exchange는 Message와 함께온 Routing Key와 동일한 Routing Key로 자신과 Binding된 Queue 또는 Exchange에게 해당 Message를 전달한다.

##### 1.1.2. Fanout

![]({{site.baseurl}}/images/theory_analysis/AMQP/AMQP_Exchange_Fanout.PNG){: width="500px"}

Fanout Exchange는 자신과 Binding된 모든 Queue에게 Message를 Broadcast하는 Exchange이다. Fanout Exchange와 Binding하기 위해서 Fanout Exchange에게 추가적으로 넘겨주어야할 정보는 없다.

##### 1.1.3. Topic

![]({{site.baseurl}}/images/theory_analysis/AMQP/AMQP_Exchange_Topic.PNG){: width="500px"}

Topic Exchange는 다수의 Queue 또는 Exchange에게 Message를 Multicast하는 Exchange이다. Mulicast의 기준은 Message와 함께 전달되는 Routing Key이다. Topic Exchange와 Binding하기 위해서는 Topic Exchange에게 패턴이 포함된 Routing Key를 넘겨주어야 한다. 이용하는 패턴은 '\*'과 '#'이다. '\*'은 하나의 문자로 치환이 가능하다는 의미이다. '#'은 아무것도 없는 문자부터 문자열까지 어떠한 문자들과도 치환이 가능하다는 의미이다. Topic Exchange는 Message와 함께온 Routing Key에 부합하는 패턴 Routing Key로 자신과 Binding한 모든 Queue 또는 Exchange에게 Message를 전달한다.

##### 1.1.4. Headers

![]({{site.baseurl}}/images/theory_analysis/AMQP/AMQP_Exchange_Headers.PNG){: width="600px"}

Headers Exchange는 다수의 Queue 또는 Exchange에게 Message를 Multicast하는 Exchange이다. Mulicast의 기준은 Message Header에 포함되어 있는 Key, Value 값이다. Headers Exchange와 Binding하기 위해서는 Message Header에 포함될 Key, Value 값을 넘겨주어야 한다. Headers Exchange는 Message Header의 Key, Value 값과 동일한 Key, Value로 자신과 Binding한 모든 Queue 또는 Exchange에게 Message를 전달한다.

Headers Exchange는 **x-match**라는 Option을 제공하는데 x-match는 'all'과 'any' 2가지 값이 존재한다. 'all'은 Message Header에 있는 모든 Key, Value 값이 Binding시에 전달 받은 Key, Value 값과 일치하는 경우에만 해당 Queue 또는 Exchange에게 Messsage를 전달한다. 'any'는 Message Header에 있는 Key, Value값의 일부만 Binding시에 전달 받은 Key, Value과 일치하더라도 해당 Queue 또는 Exchange에게 Message를 전달한다.

### 2. 참조

* [https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns](https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns)
* [http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/](http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/)
* [https://www.cloudamqp.com/blog/2015-09-03-part4-rabbitmq-for-beginners-exchanges-routing-keys-bindings.html](https://www.cloudamqp.com/blog/2015-09-03-part4-rabbitmq-for-beginners-exchanges-routing-keys-bindings.html)