---
title: gRPC
category: Theory, Analysis
date: 2019-08-25T12:00:00Z
lastmod: 2019-08-25T12:00:00Z
comment: true
adsense: true
---

gRPC를 분석한다.

### 1. gRPC

![[그림 1] Forward Proxy]({{site.baseurl}}/images/theory_analysis/gRPC/gRPC_Architecture.PNG){: width="450px"}

gRPC는 다양한 환경에서 구동 가능한 RPC (Remote Procedure Call) Framework이다. [그림 1]은 gRPC Architecture를 나타내고 있다. 요청을 처리하는 Service에서는 gRPC Server가 동작하며, Client에서는 gRPC Stub이 동작한다. gRPC Server와 gRPC Stub 사이의 Interface는 ProtoBuf를 이용하여 정의한다. gRPC Server와 gRPC Stub 사이에는 HTTP/2를 이용하여 통신한다. gRPC는 현재 Java, C++, Golang, Ruby, Python등 다양한 언어를 지원한다.

#### 1.1. ProtoBuf

{% highlight text %}
message Person {
  string name = 1;
  int32 id = 2;
  string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    string number = 1;
    PhoneType type = 2;
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] addressbook.proto </figcaption>
</figure>

ProtoBuf는 Server와 Client 사이에서 구조화된 Data를 쉽게 주고 받을수 있도록, Interface를 정의하고 구조화된 Data를 Serialization하는 역할을 수행한다. [파일 1]은 구조화된 Data인 Person Data를 ProtoBuf 규격에 맞게 저장하고 있는 .proto 파일을 나타내고 있다. ProtoBuf는 .proto 파일을 컴파일하여 gRPC Server와 gRPC Client에서 이용할 수 있는 Code를 생성한다. 생성된 Code를 이용하여 Server와 Client는 gRPC를 수행한다.

#### 1.2. vs HTTP/1.1 + JSON

gRPC가 현재 주목받는 가장큰 이유는 기존의 HTTP/1.1 + JSON Protocol보다 빠르기 때문이다. HTTP/1.1과 JSON은 Text Protocol인 만큼 성능면에서는 불리하다. gRPC에서 이용하는 HTTP/2와 ProtoBuf는 Binray Protocol인만큼 상대적을 적은양의 Packet을 주고 받는다. 또한 gRPC는 HTTP/2에서 지원하는 Connection Multiplexing, Server/Client Streaming을 이용하여 효율성을 좀더 끌어 올리고 있다.

### 2. 참조

* [https://grpc.io/docs/](https://grpc.io/docs/)
* [https://medium.com/@goinhacker/microservices-with-grpc-d504133d191d](https://medium.com/@goinhacker/microservices-with-grpc-d504133d191d)
* [https://github.com/HomoEfficio/dev-tips/blob/master/gRPC%20-%20Overview.md](https://github.com/HomoEfficio/dev-tips/blob/master/gRPC%20-%20Overview.md)
* [https://github.com/protocolbuffers/protobuf/blob/master/examples/addressbook.proto](https://github.com/protocolbuffers/protobuf/blob/master/examples/addressbook.proto)