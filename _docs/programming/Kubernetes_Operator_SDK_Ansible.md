---
title: Kubernetes Operator SDK를 이용한 Ansible Operator 개발
category:
date: 2019-06-12T12:00:00Z
lastmod: 2019-06-12T12:00:00Z
comment: true
adsense: true
---

Operator SDK User Guide에 소개된 Memcached Operator 예제를 통해 Operator SDK와 Memcached Operator를 분석한다.

### 1. Operator SDK, Ansible Operator

#### 1.1. Ansible Operator Component

#### 1.2. Ansible Operator HA

### 2. Memcached Helm Operator

#### 2.1. 개발 환경

개발 환경은 다음과 같다.
* Ubuntu 18.04 LTS, root user
* Kubernetes 1.12

#### 2.2. Operator SDK 설치

{% highlight text %}
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

{% highlight text %}
# operator-sdk new example-k8s-operator-ansible --api-version=cache.example.com/v1alpha1 --kind=Memcached --type=ansible
# cd example-k8s-operator-ansible && ls
build  deploy  molecule  roles  watches.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Project 생성</figcaption>
</figure>

#### 2.4. Memcached Spec 설정

{% highlight yaml %}
---
size: 1
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] roles/memcached/defaults/main.yml</figcaption>
</figure>

{% highlight yaml %}
---
- name: start memcached
  k8s:
    definition:
      kind: Deployment
      apiVersion: apps/v1
      metadata:
        name: '{{ meta.name }}-memcached'
        namespace: '{{ meta.namespace }}'
      spec:
        replicas: "{{size}}"
        selector:
          matchLabels:
            app: memcached
        template:
          metadata:
            labels:
              app: memcached
          spec:
            containers:
            - name: memcached
              command:
              - memcached
              - -m=64
              - -o
              - modern
              - -v
              image: "docker.io/memcached:1.4.36-alpine"
              ports:
                - containerPort: 11211
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] roles/memcached/tasks/main.yml</figcaption>
</figure>

#### 2.5. Memcached CRD 생성

{% highlight text %}
# kubectl create -f deploy/crds/cache_v1alpha1_memcached_crd.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Memcached CRD 생성</figcaption>
</figure>

#### 2.5. Memcached Operator 구동

{% highlight text %}
# operator-sdk build supsup5642/memcached-operator:v0.0.1
# docker push supsup5642/memcached-operator:v0.0.1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Memcached Operator Image 생성 및 Push</figcaption>
</figure>

{% highlight text %}
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Memcached Operator 구동</figcaption>
</figure>

#### 2.6. Memcached CR 생성을 통한 Memcached 구동

{% highlight text %}
# kubectl create -f deploy/crds/cache_v1alpha1_memcached_cr.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] Memcached 구동</figcaption>
</figure>

{% highlight text %}
# kubectl get pod
NAME                                                       READY   STATUS    RESTARTS   AGE
example-k8s-operator-ansible-b67c8d8b4-xgrqr               2/2     Running   0          9m31s
example-memcached-memcached-5d489fcf76-8q26l               1/1     Running   0          116s
example-memcached-memcached-5d489fcf76-cd4ph               1/1     Running   0          116s
example-memcached-memcached-5d489fcf76-sc7g5               1/1     Running   0          117s
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 7] Nginx 구동 확인</figcaption>
</figure>

### 3. 참조

* [https://github.com/operator-framework/operator-sdk](https://github.com/operator-framework/operator-sdk)
* [https://github.com/operator-framework/operator-sdk/blob/master/doc/ansible/user-guide.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/ansible/user-guide.md)