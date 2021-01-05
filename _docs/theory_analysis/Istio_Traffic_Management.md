---
title: Istio Traffic Management
category: Theory, Analysis
date: 2021-01-05T12:00:00Z
lastmod: 2021-01-05T12:00:00Z
comment: true
adsense: true
---

Istio의 Traffic 제어를 담당하는 Gateway, Virtual Service, Destination Rule를 분석한다.

### 1. Istio Traffic Management

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

### 1.1. Virtual Service

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