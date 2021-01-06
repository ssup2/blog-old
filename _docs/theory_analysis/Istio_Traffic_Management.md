---
title: Istio Traffic Management
category: Theory, Analysis
date: 2021-01-05T12:00:00Z
lastmod: 2021-01-05T12:00:00Z
comment: true
adsense: true
---

Istio의 Traffic 제어를 담당하는 Virtual Service, Destination Rule, Gateway를 분석한다.

### 1. Istio Traffic Management

![[그림 1] Version Service, Deployment]({{site.baseurl}}/images/theory_analysis/Istio_Traffic_Management/Version_Service_Deploy.PNG){: width="650px"}

{% highlight yaml%}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: version-v1
  labels:
    app: version
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: version
      version: v1
  template:
    metadata:
      labels:
        app: version
        version: v1
    spec:
      containers:
      - name: version
        image: docker.io/ssup2/version:v1
        ports:
        - containerPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: version-v2
  labels:
    app: version
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: version
      version: v2
  template:
    metadata:
      labels:
        app: version
        version: v2
    spec:
      containers:
      - name: version
        image: docker.io/ssup2/version:v2
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: version
  labels:
    app: version
    service: version
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: version
---
apiVersion: v1
kind: Service
metadata:
  name: version-v1
  labels:
    app: version
    service: version
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: version
    version: v1
---
apiVersion: v1
kind: Service
metadata:
  name: version-v2
  labels:
    app: version
    service: version
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: version
    version: v2
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] version-app-deploy-service.yaml</figcaption>
</figure>

Istio에서는 Traffic 제어를 위해서 Virtual Service, Destination Rule, Gateway 3가지 Resource를 제공한다. [그림 1]과 [파일 1]은 Virtual Service, Destination Rule, Gateway 실습을 위한 "version" 이라고 불리는 App을 위한 Service와 Deployment를 나타내고 있다. verion:v1 Image에 포함된 version App은 HTTP 요청시 "version v1" 문자열을 반환하고, version:v2 Image에 포함된 App은 HTTP 요청시 "version v2" 문자열을 반환하는 간단한 App이다.

verion:v1/v2 Container는 Deployment를 통해서 배포되며, version:v1을 연결하는 version-v1 Service와 version:v2를 연결하는 version-v2 Service가 존재한다. 또한 version:v1/v2 둘다 연결하는 version Service도 존재한다. 따라서 version-v1 Service에 HTTP 요청을 전송하면 "version v1" 문자열이 반환되고, version-v2 Service에 HTTP 요청을 전송하면 "version v2" 문자열이 반환된다. version Service에 HTTP 요청을 전송하면 "version v1", "version v2" 문자열이 Random으로 반환된다.

### 1.1. Virtual Service

![[그림 2] Version Virtual Service]({{site.baseurl}}/images/theory_analysis/Istio_Traffic_Management/Version_Virtual_Service.PNG){: width="700px"}

{% highlight yaml%}
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: version-v1-v2
spec:
  hosts:
  - version
  http:
  - route:
    - destination:
        host: version-v1
      weight: 10
    - destination:
        host: version-v2
      weight: 90
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] version-virtual-service.yaml</figcaption>
</figure>

### 1.2. Destination Rule

![[그림 3] Version Virtual Service, Destination Rule]({{site.baseurl}}/images/theory_analysis/Istio_Traffic_Management/Version_Virtual_Service_Desitination_Rule.PNG){: width="750px"}

{% highlight yaml%}
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: version
spec:
  host: version
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: version
spec:
  hosts:
  - version
  http:
  - route:
    - destination:
        host: version
        subset: v1
      weight: 10
    - destination:
        host: version
        subset: v2
      weight: 90
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] version-virtual-service-destination-rule.yaml</figcaption>
</figure>

### 1.3. Gateway

![[그림 4] Version Gateway, Virtual Service]({{site.baseurl}}/images/theory_analysis/Istio_Traffic_Management/Version_Gateway_Virtual_Service.PNG){: width="750px"}

{% highlight yaml%}
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: version
spec:
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "ssup2.com"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: version-gateway
spec:
  hosts:
  - version
  - ssup2.com
  gateways:
  - version
  http:
  - route:
    - destination:
        host: version
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] version-gateway-virtual-service.yaml</figcaption>
</figure>

### 2. 참고

* [https://istio.io/latest/docs/concepts/traffic-management/](https://istio.io/latest/docs/concepts/traffic-management/)
* [https://istio.io/latest/docs/reference/config/networking/virtual-service/](https://istio.io/latest/docs/reference/config/networking/virtual-service/)
* [https://istio.io/latest/docs/reference/config/networking/destination-rule/](https://istio.io/latest/docs/reference/config/networking/destination-rule/)
* [https://medium.com/better-programming/how-to-manage-traffic-using-istio-on-kubernetes-cd4b96e00b57](https://medium.com/better-programming/how-to-manage-traffic-using-istio-on-kubernetes-cd4b96e00b57)
* [https://bcho.tistory.com/1367](https://bcho.tistory.com/1367)
* [http://itnp.kr/post/istio-routing-api](http://itnp.kr/post/istio-routing-api)