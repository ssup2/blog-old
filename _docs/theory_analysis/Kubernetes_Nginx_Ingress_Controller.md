---
title: Kubernetes Nginx Ingress Controller
category: Theory, Analysis
date: 2019-12-30T12:00:00Z
lastmod: 2019-12-30T12:00:00Z
comment: true
adsense: true
---

Kubernetes에서 Nginx Ingress를 제어하는 Nginx Ingress Controller를 분석한다.

### 1. Kubernetes Nginx Ingress Controller

![[그림 1] Nginx Ingress Controller]({{site.baseurl}}/images/theory_analysis/Kubernetes_Nginx_Ingress_Controller/Nginx_Ingress_Controller.PNG)

Nginx Ingress Controller는 Kubernetes의 Ingress 및 관련 Ojbect들에 따라서 Nginx를 제어하고, Nginx 관련 Metric 정보를 수집하여 외부로 전달하는 역활을 수행한다. [그림 1]은 Nginx Ingress Controller를 나타내고 있다. Nginx Ingress Controller는 Nginx Ingress Controller Pod에 Nginx와 같이 존재한다. Nginx Ingress Controller는 Leader(Active)/Non-leader(Standby) 방식으로 동작하지만 Leader/Non-leader 둘다 자신과 같은 Pod안에서 구동중인 Nginx를 제어하고, 관련 Metric 정보를 수집하는 것은 동일하다.

{% highlight yaml %}
...
http {
        lua_shared_dict certificate_data 20M;
        lua_shared_dict certificate_servers 5M;
        lua_shared_dict configuration_data 20M;  
...
        upstream upstream_balancer {
                balancer_by_lua_block {
                        balancer.balance()
                }
        }
...
        server {
                ssl_certificate_by_lua_block {
                        certificate.call()
                }                     
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Lua Module을 이용하는 Nginx의 nginx.conf </figcaption>
</figure>

Nginx는 Lua Module을 이용하여 Nginx Config를 Reload를 최소화 하여 Packet 손실을 최소화 하도록 구현되어 있다. [파일 1]은 Lua Module을 이용하는 Nginx의 nginx.conf 파일을 나타내고 있다. [파일 1]의 http 윗부분은 Nginx의 Backend 정보와 Certificate가 저장되는 Dictionary 기반 Shared Memory를 나타내고 있다. nginx.conf의 upstream 부분에는 일반적으로 Load Balancing의 대상이 되는 Server의 정보가 저장되어 있는데, [파일 1]에서는 Server 정보 대신 balancer Lua Module을 호출하는 것을 확인할 수 있다. nginx.conf의 server 부분에는 일반적으로 Certificate Path 정보가 저장되는데, [파일 1]에서는 Certificate Path 정보 대신 certificate Lua Module을 호출하는 것을 확인할 수 있다.

#### 1.1. Configuration

Nginx Ingress Controller의 Store는 Kubernetes Client인 client-go를 이용하여 Ingress Object 및 Ingress와 관련된 Endpoint, Secret, ConfigMap, Service Object들을 **Watch**한다. Watch하고 있는 Object가 Update된다면 Store는 Update된 Object를 받아 Ingress Sync에게 전달한다. Ingress Sync는 Update된 Object를 바탕으로 Nginx Config를 구성하고 새롭게 구성한 Nginx Config와 기존에 적용된 Nginx Config를 비교한다. 두 Nginx Config가 동일하면 Nginx Config를 변경하지 않지만, 다르다면 변경된 Nginx Config를 Nginx에 적용한다.

Nginx Config 중에서 Backend 부분이 변경되었다면 변경된 내용은 nginx.conf 파일과 Nginx의 /configuration/backends URL을 통해서 Nginx의 Shared Memory에 저장된다. Nginx Config 중에서 Ceritificate가 변경되었다면 변경 내용은 /configuration/servers URL을 통해서 Nginx의 Shared Memory에 저장된다. Kubernetes Cluster의 Ingress Object의 변경으로 인해서 Nginx의 Backend가 변경되는 경우, nginx.conf 파일의 내용도 변경되어야 하기 때문에 Nginx는 nginx.conf Reload 해야한다. 하지만 단순히 Ingress Object에 Mapping 되어 있는 Service의 Pod의 개수가 변경되는 경우에는 nginx.conf의 변경이 필요없고 Shared Memory에 저장되어 있는 Backend의 Endpoint만 변경하면 되기 때문에, Nginx는 nginx.conf Reload를 수행하지 않는다.

이와 유사하게 Ingress Object의 변경으로 인해서 Nginx의 Ceritificate만 변경되야하는 경우에도 Shared Memory에 저장되어 있는 Certificate만 변경하면 되기 때문에, Nginx는 nginx.conf Reload를 수행하지 않는다. 이처럼 Nginx는 Lua Module을 이용하여 Nginx의 nginx.conf Reload를 최소화 하도록 구현되어 있다.

#### 1.2. Metric Collector

Nginx Ingress Controller의 Metric Collector는 Metric 정보를 수집하여 Prometheus에게 전송하는 역활을 수행한다. [그림 1]은 Metric Collector로 전송되는 Metric의 경로를 나타내고 있다. Metric Collector는 3가지 경로를 통해서 Metric 정보를 수집한다. 첫번째로 Nginx 내부의 HTTP Stub Status Module이 제공하는 Metric 정보를 Nginx의 /nginx_status URL을 통해서 얻어온다. 두번째로 Nginx의 Monitor Lua Module을 통해서 Metric 정보를 얻어온다. Client가 Nginx를 통해서 App에게 Packet을 전송할때 마다 관련 Metric 정보는 Monitor Lua Module로 전송된다. Monitor Lua Module은 받은 Metirc 정보를 모아 한꺼번에 주기적으로 Domain Socket을 이용하여 Metric Collector로 전송한다.

마지막으로 Nginx Ingress Controller Pod의 procfs를 통해서 Nginx Process의 Metric 정보를 얻는다. 얻은 Metric 정보는 Nginx Ingress Controller의 /metrics를 통해서 Prometheus에게 전달된다. 따라서 각 Nginx Ingress Controller는 Prometheus의 Exporter 역활을 수행하게된다.

#### 1.3. Load Balancing, TLS

{% highlight yaml %}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  tls:
  - secretName: tls-secret
  rules:
  - host: ssup2.com
    http:
      paths:
      - path: /app
        backend:
          serviceName: app
          servicePort: 443
---
apiVersion: v1
kind: Service
metadata:
  name: app
spec:
  ports:
  - port: 443
    targetPort: 443
    protocol: TCP
    name: http
  selector:
    app: app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: ssup2/demo:latest
        ports:
        - containerPort: 443
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Ingress, Service, Deployment</figcaption>
</figure>

Nginx는 Lua Module을 이용하여 Client의 Packet을 Load Balancing하고 필요에 따라서 TLS 암호화/복호화도 수행한다. [파일 2]은 Kubernetes의 Ingress, Service, Deployment의 예제를 나타내고 있다. [파일 2]의 내용처럼 Ingress는 Service에 Mapping이되고 Service는 Pod(Deployment)에 Mapping이 된다. 따라서 [파일 2]의 내용을 보면 Client의 Packet은 Nginx에서 Service IP로 DNAT되고 다시 Service IP에서 Pod IP로 2번 DNAT 및 Load Balancing 되어 전송되는것 처럼 보인다. 하지만 실제로 Nginx는 Client가 전송한 Packet을 Configuration Lua Module이 Shared Memory에 저장한 Backend의 Service 및 Endpoint(Pod IP/Port) 정보를 바탕으로 **한번만 DNAT를 수행**하여 Load Balancing 및 Packet을 Pod으로 바로 전송한다.

Load Balancing 알고리즘은 기본적으로 Round Robin을 이용하고 configmap을 이용하여 설정 할 수 있다. Protocol은 HTTP/HTTPS 뿐만 아니라 TCP/UDP Protocol도 지원한다. Ingress 설정시 TLS를 이용하도록 설정되어 있다면, Nginx의 Certificate Lua Module은  Configuration Lua Module이 Shared Memory에 저장한 Certificate 정보를 바탕으로 TLS 암호화/복호화를 수행한다.

#### 1.4. Health Check

{% highlight yaml %}
...
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Nginx Ingress Controller Pod의 Liveness, Readiness Probe</figcaption>
</figure>

Nginx Ingress Controller는 Nginx의 /healthz URL로 Packet을 Redirect하는 /healthz URL을 제공한다. 따라서 Nginx Ingress Controller의 /healthz로 전송한 요청의 응답을 받을 수 없다면 Nginx Ingress Controller 또는 Nginx에 문제가 생겼다는걸 의미한다. 일반적으로 Nginx Ingress Controller Pod의 Liveness, Readiness Probe를 Nginx Ingress Controller의 /healthz로 지정하여 Nginx Ingress Controller 및 Nginx의 Health를 검사한다. [파일 3]은 Nginx Ingress Controller Pod의 Liveness, Readiness Probe의 설정 Example을 나타내고 있고, [그림 1]은 Nginx Ingress Controller의 /healthz로 전송된 요청이 다시 Nginx의 /healthz로 Redirect 되는걸 나타내고 있다.

### 2. 참조

* [https://kubernetes.github.io/ingress-nginx/](https://kubernetes.github.io/ingress-nginx/)