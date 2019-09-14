---
title: Kubernetes Operator SDK를 이용한 Helm Operator 개발
category:
date: 2019-06-11T12:00:00Z
lastmod: 2019-06-11T12:00:00Z
comment: true
adsense: true
---

Operator SDK User Guide에 소개된 Nginx Operator 예제를 통해 Operator SDK와 Helm Operator를 분석한다.

### 1. Operator SDK, Helm Operator

#### 1.1. Helm Operator Component

#### 1.2. Helm Operator HA

### 2. Nginx Helm Operator

#### 2.1. 개발 환경

개발 환경은 다음과 같다.
* Ubuntu 18.04 LTS, root user
* Kubernetes 1.12

#### 2.2. Operator SDK 설치

{% highlight console %}
# mkdir -p ~/operator-sdk
# cd ~/operator-sdk
# RELEASE_VERSION=v0.8.0
# curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
# chmod +x operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu && sudo cp operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu /usr/local/bin/operator-sdk && rm operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
# operator-sdk
An SDK for building operators with ease

Usage:
  operator-sdk [command]
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Operator SDK 설치</figcaption>
</figure>

Kubernetes Operator SDK CLI를 설치하고 동작을 확인한다.

#### 2.3. Project 생성

{% highlight console %}
# operator-sdk new example-k8s-operator-helm --api-version=example.com/v1alpha1 --kind=Nginx --type=helm
# cd example-k8s-operator-helm && ls
build  deploy  helm-charts  watches.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Project 생성</figcaption>
</figure>

#### 2.4. Nginx CRD 생성

{% highlight console %}
# kubectl create -f deploy/crds/example_v1alpha1_nginx_crd.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Nginx CRD 생성</figcaption>
</figure>

#### 2.5. Nginx Operator 구동

{% highlight console %}
# operator-sdk build supsup5642/nginx-operator:v0.0.1
# sed -i 's|REPLACE_IMAGE|supsup5642/nginx-operator:v0.0.1|g' deploy/operator.yaml
# docker push supsup5642/nginx-operator:v0.0.1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Nginx Operator Image 생성 및 Push</figcaption>
</figure>

{% highlight yaml %}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  name: example-k8s-operator-nginx
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - configmaps
  - secrets
  verbs:
  - '*'
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - '*'
- apiGroups:
  - example.com
  resources:
  - '*'
  verbs:
  - '*'
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] deploy/role.yaml</figcaption>
</figure>

{% highlight console %}
# kubectl create -f deploy/service_account.yaml
# kubectl create -f deploy/role.yaml
# kubectl create -f deploy/role_binding.yaml
# kubectl create -f deploy/operator.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Nginx Operator 구동</figcaption>
</figure>

#### 2.6. Nginx CR 생성을 통한 Nginx 구동

{% highlight console %}
# kubectl apply -f deploy/crds/example_v1alpha1_nginx_cr.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] Nginx 구동</figcaption>
</figure>

{% highlight console %}
# kubectl get pod
NAME                                                       READY   STATUS    RESTARTS   AGE
example-k8s-operator-helm-66496b4665-zhdzq                 1/1     Running   0          16m
example-nginx-2o18v8fiksct1fk0lol9r6yv7-5cc9b7f59f-qh87x   1/1     Running   0          16m
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 7] Nginx 구동 확인</figcaption>
</figure>

### 3. 참조

* [https://github.com/operator-framework/operator-sdk](https://github.com/operator-framework/operator-sdk)
* [https://github.com/operator-framework/operator-sdk/blob/master/doc/helm/user-guide.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/helm/user-guide.md)