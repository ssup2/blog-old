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

![[그림 1] Forward Proxy]({{site.baseurl}}/images/theory_analysis/gRPC/gRPC_Architecture.PNG){: width="500px"}

gRPC는 다양한 환경에서 구동 가능한 RPC (Remote Procedure Call) Framework이다. [그림 1]은 gRPC Architecture를 나타내고 있다. 요청을 처리하는 Service에서는 gRPC Server가 동작하며, Client에서는 gRPC Stub이 동작한다. gRPC Server와 gRPC Stub 사이의 Interface는 ProtoBuf를 이용하여 정의한다. gRPC Server와 gRPC Stub 사이에는 다양한 Protocol을 통해서 통신이 가능하지만 일반적으로는 HTTP2를 이용한다.

#### 1.1. ProtoBuf

#### 1.2. vs HTTP1 + JSON

### 2. 참조

* [https://grpc.io/docs/](https://grpc.io/docs/)
* [https://medium.com/@goinhacker/microservices-with-grpc-d504133d191d](https://medium.com/@goinhacker/microservices-with-grpc-d504133d191d)
* [https://github.com/HomoEfficio/dev-tips/blob/master/gRPC%20-%20Overview.md](https://github.com/HomoEfficio/dev-tips/blob/master/gRPC%20-%20Overview.md)