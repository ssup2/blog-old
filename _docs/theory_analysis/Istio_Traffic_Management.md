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

Istio에서는 Traffic 제어를 위해서 Virtual Service, Destination Rule, Gateway 3가지 Resource를 제공한다. [그림 1]과 [파일 1]은 Virtual Service, Destination Rule, Gateway 이해 및 적용을 위한 "version" 이라고 불리는 App을 위한 Service와 Deployment를 나타내고 있다. verion:v1 Image에 포함된 version App은 HTTP 요청시 "version v1" 문자열을 반환하고, version:v2 Image에 포함된 App은 HTTP 요청시 "version v2" 문자열을 반환하는 간단한 App이다.

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

Virtual Service는 Host를 기반으로 Traffic을 Routing하는 역활을 수행한다. 여기서 Host는 Client가 접속하는 주소를 의미한다. [그림 2], [파일 2]는 version Host를 대상으로 version-v1, version-v2 Service로 Traffic을 1:9로 Routing하는 version-v1-v2 Virtual Service를 나타내고 있다. Weigth뿐만 아니라 요청의 URI(PATH) 또는 Header에 따라서 Routing하는 L7 기반의 Routing 기법도 재공한다. Routing의 대상이 Service뿐만 아니라 다른 Virtual Service가 될 수도 있다.

version-v1-v2 Version Service가 version을 Host로 이용할 수 있는 이유는 version Service가 선언되어 있기 때문이다. version Service를 통해서 실제로 Traffic이 Routing이 되는것은 아니지만 version Service가 존재하지 않으면 version-v1-v2 Version Service가 version을 Host로 이용할 수 없기 때문에, 반드시 version Service도 선언되어 있어야 한다.

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
    trafficPolicy:
      loadBalancer:
        simple: LEAST_CONN
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

Destination Rule은 Traffic이 Virtual Service로 인해서 Routing되어 어느 Service로 전달될지 결정된 이후에, 결정된 Service로 Traffic을 전송하기전 마지막으로 적용되는 Routing 규칙을 의미한다. 따라서 Destination Rule은 하나의 Service에 대해서만 정의한다. [그림 3], [파일 3]은 Destination Rule의 예제를 나타내고 있다.

version Destiniation Rule은 version Service에 대해서 Routing 규칙을 정의한다. subsets는 version Service에 연결되어 있는 Pod들을 Pod의 Label에 따라서 Subset(Group)으로 분리한다. v1, v2 이름을 갖는 2개의 Subset이 존재하며, v1 Subset에는 "version: v1" Label을 갖는 Pod들이 포함되고 v2 Subset에는 "version: v2" Label을 갖는 Pod들이 포함된다. Destiniation Rule에 정의된 Subset은 Virtual Service에서 이용된다. version Virtual Service에 version Service (Host)의 Subset v1과 v2에 1:9로 Traffic을 Routing 하도록 설정되어 있는것을 확인할 수 있다.

v2 SubSet에는 loadBalancer LEAST_CONN가 설정 되어있기 때문에, v2 SubSet에 포함되어 있는 Pod들 사이에 Traffic은 Least Connection Algorithm에 따라서 Load Balancing 된다. Load Balancing Algorithm은 Default로 ROUND_ROBIN이 적용되며 LEAST_CONN, RANDOM, L7 기반 Consistent Hashing 기법등을 적용할수 있다.

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

Gateway는 Virtual Service를 Kubernetes Cluster 외부로 노출시키는 역활을 수행한다. [그림 4], [파일 4]는 version-gateway Virtual Service를 version Gateway를 통해서 Kubernetes Cluster 외출에 노출시키는 예제를 나타내고 있다. Gateway에는 Protocol,  Port 번호 Kubernetes Cluster에서 Virtual Service에 접근할 Host (Domain)등을 설정할 수 있다. 또한 [파일 4]에는 명시되어 있지 않지만, 필요에 따라서는 인증서 (TLS) 정보도 설정하여 HTTPS 요청을 받을 수 있도록 설정할 수 있다.

Virtual Service를 Gateway에 연결하기 위해서는 Virtual Service의 hosts에는 Gateway에서 설정한 Host를 추가해야 한다. 또한  Virtual Service의 gateways에는 Virtual Service가 연결된 Gateway의 이름을 명시해야 한다.

### 2. 참고

* [https://istio.io/latest/docs/concepts/traffic-management/](https://istio.io/latest/docs/concepts/traffic-management/)
* [https://istio.io/latest/docs/reference/config/networking/virtual-service/](https://istio.io/latest/docs/reference/config/networking/virtual-service/)
* [https://istio.io/latest/docs/reference/config/networking/destination-rule/](https://istio.io/latest/docs/reference/config/networking/destination-rule/)
* [https://medium.com/better-programming/how-to-manage-traffic-using-istio-on-kubernetes-cd4b96e00b57](https://medium.com/better-programming/how-to-manage-traffic-using-istio-on-kubernetes-cd4b96e00b57)
* [https://bcho.tistory.com/1367](https://bcho.tistory.com/1367)
* [http://itnp.kr/post/istio-routing-api](http://itnp.kr/post/istio-routing-api)