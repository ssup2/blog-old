---
title: Istio Sidecar
category: Theory, Analysis
date: 2021-01-03T12:00:00Z
lastmod: 2021-01-03T12:00:00Z
comment: true
adsense: true
---

Istio의 Sidecar 기법을 분석한다.

### 1. Istio Sidecar

![[그림 1] Istio Sidecar]({{site.baseurl}}/images/theory_analysis/Istio_Sidecar/Istio_Sidecar.PNG){: width="500px"}

Istio의 Sidecar 기법은 각 Pod 마다 전용 Proxy Server를 띄우는 기법을 의미한다. [그림 1]은 Istio Sidecar 기법의 Architecture를 나타내고 있다. Sidecar는 Pod으로 전달되는 모든 Inbound Packet을 대신 수신한 다음, 처리후 Pod의 Container에게 전송하는 역활을 수행한다. 또한 Sidecar는 Pod에서 밖으로 전송되는 모든 Packet을 대신 수신한 다음, 처리후 Pod의 외부로 전송하는 역활을 수행한다.

이러한 Sidecar의 특징 때문에 Sidecar는 Packet 전송에 필요한 모든 정보를 알고 있어야 한다. Sidecar는 이러한 Packet 전송에 필요한 정보를 Istiod라고 불리는 중앙 Controller로 부터 받는다. Istiod가 Sidecar에게 전송하는 정보에는 Pod에서 동작하는 App이 제공하는 Service 정보, Packet 전송에 필요한 Routing 정보, Packet 송수신 허용 여부를 결정하는 Policy 정보, Packet 암호화를 위한 인증서 정보등이 포함되어 있다. Sidecar는 Istiod로 부터 받은 정보들을 바탕으로 Service Discovery, Packet Load Balancing, Packet Encap/Decap, Circuit Breaker 역활 등을 수행한다.

Istio의 Sidecar는 Envoy라고 불리는 Proxy 서버를 이용하며 HTTP, gRPC, TCP등 다양한 Protocol을 지원한다. 따라서 App에서도 다양한 Protocol을 기반으로 Packet을 주고받을 수 있다.

#### 1.1. Sidecar Injection

Sidecar는 Pod안에서 Container로 동작 해야한다. 따라서 Sidecar가 Pod안에서 Container로 Injection되어 동작할 수 있도록 설정해주어야 한다. Sidecar 설정은 각 Pod마다 수동으로 설정할 수도 있고, Namespace 단위로 설정하여 Namespace안에서 생성되는 모든 Pod에서 Sidecar가 동작하도록 설정할 수 있다.

##### 1.1.1. Manual 설정

{% highlight console %}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] istioctl kube-inject 적용전 nginx Deployment Manifest</figcaption>
</figure>

{% highlight console %}
apiVersion: apps/v1
kind: Deployment
...
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      - args:
        - proxy
        - sidecar
        - --domain
        - $(POD_NAMESPACE).svc.cluster.local
        - --serviceCluster
        - nginx.$(POD_NAMESPACE)
        - --proxyLogLevel=warning
        - --proxyComponentLogLevel=misc:error
        - --concurrency
        - "2"
        env:
        - name: JWT_POLICY
          value: first-party-jwt
        - name: PILOT_CERT_PROVIDER
          value: istiod
        - name: CA_ADDR
          value: istiod.istio-system.svc:15012
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: INSTANCE_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName
        - name: HOST_IP
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        - name: CANONICAL_SERVICE
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['service.istio.io/canonical-name']
        - name: CANONICAL_REVISION
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['service.istio.io/canonical-revision']
        - name: PROXY_CONFIG
          value: |
            {"proxyMetadata":{"DNS_AGENT":""}}
        - name: ISTIO_META_POD_PORTS
          value: |-
            [
                {"containerPort":80}
            ]
        - name: ISTIO_META_APP_CONTAINERS
          value: nginx
        - name: ISTIO_META_CLUSTER_ID
          value: Kubernetes
        - name: ISTIO_META_INTERCEPTION_MODE
          value: REDIRECT
        - name: ISTIO_META_WORKLOAD_NAME
          value: nginx-deployment
        - name: ISTIO_META_OWNER
          value: kubernetes://apis/apps/v1/namespaces/default/deployments/nginx-deployment
        - name: ISTIO_META_MESH_ID
          value: cluster.local
        - name: TRUST_DOMAIN
          value: cluster.local
        - name: DNS_AGENT
        image: docker.io/istio/proxyv2:1.8.1
        imagePullPolicy: Always
        name: istio-proxy
        ports:
        - containerPort: 15090
          name: http-envoy-prom
          protocol: TCP
        readinessProbe:
          failureThreshold: 30
          httpGet:
            path: /healthz/ready
            port: 15021
          initialDelaySeconds: 1
          periodSeconds: 2
          timeoutSeconds: 3
        resources:
          limits:
            cpu: "2"
            memory: 1Gi
          requests:
            cpu: 10m
            memory: 40Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          privileged: false
          readOnlyRootFilesystem: true
          runAsGroup: 1337
          runAsNonRoot: true
          runAsUser: 1337
        volumeMounts:
        - mountPath: /var/run/secrets/istio
          name: istiod-ca-cert
        - mountPath: /var/lib/istio/data
          name: istio-data
        - mountPath: /etc/istio/proxy
          name: istio-envoy
        - mountPath: /etc/istio/pod
          name: istio-podinfo
      initContainers:
      - args:
        - istio-iptables
        - -p
        - "15001"
        - -z
        - "15006"
        - -u
        - "1337"
        - -m
        - REDIRECT
        - -i
        - '*'
        - -x
        - ""
        - -b
        - '*'
        - -d
        - 15090,15021,15020
        env:
        - name: DNS_AGENT
        image: docker.io/istio/proxyv2:1.8.1
        imagePullPolicy: Always
        name: istio-init
        resources:
          limits:
            cpu: "2"
            memory: 1Gi
          requests:
            cpu: 10m
            memory: 40Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - NET_ADMIN
            - NET_RAW
            drop:
            - ALL
          privileged: false
          readOnlyRootFilesystem: false
          runAsGroup: 0
          runAsNonRoot: false
          runAsUser: 0
      securityContext:
        fsGroup: 1337
      volumes:
      - emptyDir:
          medium: Memory
        name: istio-envoy
      - emptyDir: {}
        name: istio-data
      - downwardAPI:
          items:
          - fieldRef:
              fieldPath: metadata.labels
            path: labels
          - fieldRef:
              fieldPath: metadata.annotations
            path: annotations
        name: istio-podinfo
      - configMap:
          name: istio-ca-root-cert
        name: istiod-ca-cert
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] istioctl kube-inject 적용후 nginx Deployment Manifest</figcaption>
</figure>

"istioctl kube-inject" 명령어를 통해서 Deployment, StatefulSet, DaemonSet등의 Pod를 관리하는 Object의 Manifest를 변경하여 Pod에 Sidecar가 생성되도록 만든다. [파일 1]은 "istioctl kube-inject" 명령어 적용 전 nginx Deployment Manifest 파일을 나타내고 있고, [파일 2]는 "istioctl kube-inject" 명령어 적용 후 nginx Deployment Manifest 파일을 나타내고 있다. Sidecar인 istio-proxy Container가 추가되었고, Init Container가 추가된 것을 확인할 수 있다.

{% highlight console %}
# istioctl kube-inject -f nginx-deployment.yaml | kubectl apply -f -
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] istioctl kube-inject 이용</figcaption>
</figure>

[Console 1]과 같이 "istioctl kube-inject" 명령어를 수행하면 Pod이 새로 생성되면서 Sidecar가 Injection 된다.

##### 1.1.2. Namespace 설정

Label에 "istio-injection=enabled"이 붙어있는 Namespace안에 Pod이 생성될 경우에는 Istio는 Sidecar Injection을 수행하여 Kubernetes의 사용자의 개입없이 Pod안에 Sidecar를 강제로 생성한다. Kubernetes 사용자의 개입없이 Sidecar Injection을 강제로 수행할 수 있는 이유는 Kubernetes에서 제공하는 Admission Controller 기능을 이용하기 때문이다.

Admission Controller의 Mutating Webhook 기능을 통해서 Pod 관련 Object 생성 요청이 Kubernetes API Server에게 전달되면, Kubernetes API Server는 해당 Pod 생성 요청을 Istiod에게 전송한다. Istiod는 Pod 생성 요청에 Sidecar 및 Init Container 설정을 추가(Mutating)한 다음에 Kubernetes API 서버에 전달하여 Sidecar와 Init Container가 생성되도록 한다.

#### 1.2. Packet Capture

{% highlight console %}
# iptables -t nat -nvL
Chain PREROUTING (policy ACCEPT 11729 packets, 704K bytes)
 pkts bytes target     prot opt in     out     source               destination
11729  704K ISTIO_INBOUND  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain INPUT (policy ACCEPT 11729 packets, 704K bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 1074 packets, 95511 bytes)
 pkts bytes target     prot opt in     out     source               destination
   54  3240 ISTIO_OUTPUT  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain POSTROUTING (policy ACCEPT 1077 packets, 95691 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain ISTIO_INBOUND (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:15008
    0     0 RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
    0     0 RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:15090
11727  704K RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:15021
    2   120 RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:15020
    0     0 ISTIO_IN_REDIRECT  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain ISTIO_IN_REDIRECT (3 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            redir ports 15006

Chain ISTIO_OUTPUT (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  *      lo      127.0.0.6            0.0.0.0/0
    0     0 ISTIO_IN_REDIRECT  all  --  *      lo      0.0.0.0/0           !127.0.0.1            owner UID match 1337
    0     0 RETURN     all  --  *      lo      0.0.0.0/0            0.0.0.0/0            ! owner UID match 1337
   51  3060 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            owner UID match 1337
    0     0 ISTIO_IN_REDIRECT  all  --  *      lo      0.0.0.0/0           !127.0.0.1            owner GID match 1337
    0     0 RETURN     all  --  *      lo      0.0.0.0/0            0.0.0.0/0            ! owner GID match 1337
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            owner GID match 1337
    0     0 RETURN     all  --  *      *       0.0.0.0/0            127.0.0.1
    3   180 ISTIO_REDIRECT  all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain ISTIO_REDIRECT (1 references)
 pkts bytes target     prot opt in     out     source               destination
    3   180 REDIRECT   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            redir ports 15001
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] Pod iptables NAT Table with Istio Sidecar</figcaption>
</figure>

Sidecar가 Injection된 Pod으로 전송되는 모든 Inbound Packet이 Sidecar로 전송되는 이유, 또는 Sidecar가 Injection된 Pod에서 전송되는 모든 Outbound Packet이 Sidecar로 전송되는 이유는 Pod에 Sidecar와 같이 설정되는 Init Container 때문이다. Init Container는 Pod의 Network Namespace에 iptables를 이용하여 Pod의 Inbound/Outbound Packet이 Sidecar로 전송되도록 Redirect하는 Rule을 설정한다. [Console 2]는 Sidecar가 Injection된 Pod안에서 iptables DNAT Table을 조회한 결과이다.

#### 1.3. Packet Load Balancing

### 2. 참조

* [https://istio.io/latest/docs/reference/config/networking/virtual-service/](https://istio.io/latest/docs/reference/config/networking/virtual-service/)
* [https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)
* [https://istio.io/latest/docs/ops/deployment/requirements/](https://istio.io/latest/docs/ops/deployment/requirements/)