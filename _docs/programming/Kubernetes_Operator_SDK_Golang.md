---
title: Kubernetes Operator SDK를 이용한 Golang Operator 개발
category: Programming
date: 2019-05-30T12:00:00Z
lastmod: 2019-05-30T12:00:00Z
comment: true
adsense: true
---

Operator SDK User Guide에 소개된 Memcached Operator 예제를 통해 Operator SDK와 Golang Operator를 분석한다.

### 1. Operator SDK, Golang Operator

Operator SDK는 의미 그대로 Kubernetes Operator 개발을 도와주는 SDK이다. Operator SDK를 이용하여 Golang Operator, Ansible Operator, Helm Operator 3가지 Type의 Operator를 개발할 수 있다. Golang Operator는 특정 **Kubernetes CR (Custom Resource)**을 관리하는 Golang 기반의 **Kubernetes Controller**이다. 따라서 Golang Operator를 개발하는 과정은 Kubernetes CR을 정의하는 과정과 Golang을 이용하여 Kubernetes Controller를 개발하는 과정으로 크게 분류할 수 있다.

Operator SDK는 Kubernetes CR과 관련된 대부분의 파일을 생성해준다. 개발자는 생성된 Kubernetes CR 관련 파일을 수정 만하면 되기 때문에 쉽게 Kubernetes CR을 정의할 수 있다. 또한 Operator SDK는 Standard Golang Project Layout을 준수하는 Kubernetes Controller Project를 생성해준다. Operator SDK가 생성한 Kubernetes Controller Project에는 모든 Kubernetes Controller가 수행 해야하는 공통 기능이 Golang으로 구현되어 포함되어 있다. 개발자는 Kubernetes Controller의 핵심 기능 개발에만 집중할 수 있기 때문에 쉽게 Kubernetes Controller를 개발할 수 있다.

### 2. Memcached Golang Operator

Memcached Golang Operator 예제에서는 Memcached CR을 정의하고, 정의한 Memcached CR을 관리하는 Kubernetes Controller를 개발한다. Memcached Golang Operator 전체 Code는 아래의 링크에서 확인할 수 있다.
* [https://github.com/operator-framework/operator-sdk-samples/tree/master/memcached-operator](https://github.com/operator-framework/operator-sdk-samples/tree/master/memcached-operator)
* [https://github.com/ssup2/example-k8s-operator-memcached](https://github.com/ssup2/example-k8s-operator-memcached)

#### 2.1. 개발 환경

개발 환경은 다음과 같다.
* Ubuntu 18.04 LTS, root user
* Kubernetes 1.12
* golang 1.12.2

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
# mkdir -p $GOPATH/src/github.com/ssup2 
# cd $GOPATH/src/github.com/ssup2
# export GO111MODULE=on
# operator-sdk new example-k8s-operator-memcached 
# cd example-k8s-operator-memcached && ls
build  cmd  deploy  go.mod  go.sum  pkg  tools.go  vendor  version
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Project 생성</figcaption>
</figure>

**operator-sdk new** 명령어를 통해서 Standard Golang Project Layout을 준수하는 Memcached Operator Project를 생성한다. [Shell 2]에서 조회되는 bulid, cmd, pkg, vendor Directory는 Memcached Operator Project를 위한 Standard Go Project Layout의 일부분이다. deploy Directory에는 Kubernetes에 Memcached Operator 구동을 위한 Kubernetes YAML 파일이 생성된다.

#### 2.4. Memcached CR 정의

{% highlight text %}
# operator-sdk add api --api-version=cache.example.com/v1alpha1 --kind=Memcached
# ls deploy/crds/
cache_v1alpha1_memcached_crd.yaml  cache_v1alpha1_memcached_cr.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Memcached CRD 생성</figcaption>
</figure>

**operator-sdk add api** 명령어를 이용하여 Memcached Operator에서 관리할 Memcached CR을 정의한다. Kubernetes에 정의한 Memcached CR 적용을 위한 Kubernetes YAML 파일들이 deploy/crds Directory 아래에 생성된다.

{% highlight golang linenos %}
type MemcachedSpec struct {
	  Size int32 `json:"size"`
}

type MemcachedStatus struct {
	  Nodes []string `json:"nodes"`
}

type Memcached struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec   MemcachedSpec   `json:"spec,omitempty"`
    Status MemcachedStatus `json:"status,omitempty"`
}

type MemcachedList struct {
    metav1.TypeMeta `json:",inline"`
    metav1.ListMeta `json:"metadata,omitempty"`
    Items           []Memcached `json:"items"`
}  
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] pkg/apis/cache/v1alpha1/memcached_types.go</figcaption>
</figure>

Memcached CR 관련 Golang Struct는 pkg/apis/cache/v1alpha1 Directory 아래의 memcached_types.go에 정의된다. [Code 1]처럼 memcached_types.go의 MemcachedSpec Struct와 MemcachedStatus Struct에 Memcached Object에 저장되어야할 정보를 직접 추가해야 한다. [Code 1]에는 다음의 내용이 추가되었다.
* MemcachedSpec Struct Size : 동작해야하는 Memcached Pod의 개수를 나타낸다.
* MemcachedStatus Struct Nodes : Memcached가 동작하는 Pod의 이름을 나타낸다.

#### 2.5. Memcached Controller 생성

{% highlight text %}
# operator-sdk add controller --api-version=cache.example.com/v1alpha1 --kind=Memcached
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Memcached Controller 생성</figcaption>
</figure>

**operator-sdk add controller** 명령어를 이용하여 Memcached Controller 관련 Golang Code를 생성한다. 생성된 Memcached Controller 관련 Golang Code는 pkg/controller/memcached Directory 아래에 위치한다.

{% highlight golang linenos %}
...
func add(mgr manager.Manager, r reconcile.Reconciler) error {
    c, err := controller.New("memcached-controller", mgr, controller.Options{Reconciler: r})
    if err != nil {
        return err
    }

    err = c.Watch(&source.Kind{Type: &cachev1alpha1.Memcached{}}, &handler.EnqueueRequestForObject{})
    if err != nil {
        return err
    }

    err = c.Watch(&source.Kind{Type: &appsv1.Deployment{}}, &handler.EnqueueRequestForOwner{
        IsController: true,
        OwnerType:    &cachev1alpha1.Memcached{},
    })
    if err != nil {
        return err
    }

    return nil
}  
...
func (r *ReconcileMemcached) Reconcile(request reconcile.Request) (reconcile.Result, error) {
    reqLogger := log.WithValues("Request.Namespace", request.Namespace, "Request.Name", request.Name)
    reqLogger.Info("Reconciling Memcached")

	  // Fetch the Memcached instance
	  memcached := &cachev1alpha1.Memcached{}
	  err := r.client.Get(context.TODO(), request.NamespacedName, memcached)
	  if err != nil {
		  if errors.IsNotFound(err) {
			  // Request object not found, could have been deleted after reconcile request.
			  // Owned objects are automatically garbage collected. For additional cleanup logic use finalizers.
			  // Return and don't requeue
			  reqLogger.Info("Memcached resource not found. Ignoring since object must be deleted.")
			  return reconcile.Result{}, nil
		  }
		  // Error reading the object - requeue the request.
		  reqLogger.Error(err, "Failed to get Memcached.")
		  return reconcile.Result{}, err
	  }

    found := &appsv1.Deployment{}
    err = r.client.Get(context.TODO(), types.NamespacedName{Name: memcached.Name, Namespace: memcached.Namespace}, found)
    if err != nil && errors.IsNotFound(err) {
        // Define a new deployment
        dep := r.deploymentForMemcached(memcached)
        reqLogger.Info("Creating a new Deployment.", "Deployment.Namespace", dep.Namespace, "Deployment.Name", dep.Name)
        err = r.client.Create(context.TODO(), dep)
        if err != nil {
            reqLogger.Error(err, "Failed to create new Deployment.", "Deployment.Namespace", dep.Namespace, "Deployment.Name", dep.Name)
            return reconcile.Result{}, err
        }
        // Deployment created successfully - return and requeue
        return reconcile.Result{Requeue: true}, nil
    } else if err != nil {
        reqLogger.Error(err, "Failed to get Deployment.")
        return reconcile.Result{}, err
    } 

    size := memcached.Spec.Size
    if *found.Spec.Replicas != size {
        found.Spec.Replicas = &size
        err = r.client.Update(context.TODO(), found)
        if err != nil {
            reqLogger.Error(err, "Failed to update Deployment.", "Deployment.Namespace", found.Namespace, "Deployment.Name", found.Name)
            return reconcile.Result{}, err
        }
        // Spec updated - return and requeue
        return reconcile.Result{Requeue: true}, nil
    }

    podList := &corev1.PodList{}
    labelSelector := labels.SelectorFromSet(labelsForMemcached(memcached.Name))
    listOps := &client.ListOptions{
        Namespace:     memcached.Namespace,
        LabelSelector: labelSelector,
    }
    err = r.client.List(context.TODO(), listOps, podList)
    if err != nil {
        reqLogger.Error(err, "Failed to list pods.", "Memcached.Namespace", memcached.Namespace, "Memcached.Name", memcached.Name)
        return reconcile.Result{}, err
    }
    podNames := getPodNames(podList.Items)

    if !reflect.DeepEqual(podNames, memcached.Status.Nodes) {
        memcached.Status.Nodes = podNames
        err := r.client.Status().Update(context.TODO(), memcached)
        if err != nil {
            reqLogger.Error(err, "Failed to update Memcached status.")
            return reconcile.Result{}, err
        }
    }

    return reconcile.Result{}, nil
}
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] pkg/controller/memcached/memcached_controller.go</figcaption>
</figure>

#### 2.6. Memcached CRD 적용

{% highlight text %}
# kubectl create -f deploy/crds/cache_v1alpha1_memcached_crd.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Memcached CRD 생성</figcaption>
</figure>

정의된 Memcached CR을 Kubernetes에서 생성하기 위해서는 Memcached CR을 정의하는 Memcached CRD (Custom Resource Definition)을 Kubernetes에 적용해야 한다. [Shell 3]에서 생성된 cache_v1alpha1_memcached_crd.yaml을 이용하여 Memcached CRD를 Kubernetes에 적용한다.

#### 2.7. Memcached Operator 구동

{% highlight text %}
# export GO111MODULE=on
# go mod vendor
# operator-sdk build supsup5642/memcached-operator:v0.0.1
# sed -i 's|REPLACE_IMAGE|supsup5642/memcached-operator:v0.0.1|g' deploy/operator.yaml
# docker push supsup5642/memcached-operator:v0.0.1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] Memcached Operator Image 생성 및 Push</figcaption>
</figure>

**operator-sdk build** 명령어를 이용하여 및 개발한 Memcached Operator를 기반으로 하는 Container Image로 생성한 다음 Docker Registry에 Push한다. Container Image의 이름은 개인 Repository에 맞도록 변경한다.

{% highlight text %}
# kubectl create -f deploy/service_account.yaml
# kubectl create -f deploy/role.yaml
# kubectl create -f deploy/role_binding.yaml
# kubectl create -f deploy/operator.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 7] Memcached Operator Image 생성 및 Push</figcaption>
</figure>

[Shell 2]에서 생성된 Memcached Operator 관련 Kubernetes YAML 파일을 이용하여 Kubernetes에 Memcached Operator를 구동한다.

#### 2.8. Memcached CR 생성을 통한 Memcached 구동

{% highlight text %}
# kubectl apply -f deploy/crds/cache_v1alpha1_memcached_cr.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 8] Memcached 구동</figcaption>
</figure>

[Shell 3]에서 생성된 cache_v1alpha1_memcached_cr.yaml을 이용하여 Kubernetes에 Memcached CR을 생성한다. Memcached Operator는 생성된 Memcached CR의 내용을 바탕으로 Memcached를 구동한다.

{% highlight text %}
# kubectl get pod
NAME                                              READY   STATUS    RESTARTS   AGE
example-k8s-operator-memcached-867bd5754d-pc2m9   1/1     Running   3          2m31s
example-memcached-c88c4dc9f-dj7t4                 1/1     Running   0          91s
example-memcached-c88c4dc9f-hkz9t                 1/1     Running   0          91s
example-memcached-c88c4dc9f-p87m4                 1/1     Running   0          91s
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 9] Memcached 구동 확인</figcaption>
</figure>

Pod 정보를 조회하여 Memcached의 동작을 확인한다.

### 3. 참조

* [https://github.com/operator-framework/operator-sdk](https://github.com/operator-framework/operator-sdk)
* [https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md)
* [https://github.com/operator-framework/operator-sdk-samples/tree/master/memcached-operator](https://github.com/operator-framework/operator-sdk-samples/tree/master/memcached-operator)
* [https://github.com/golang-standards/project-layout](https://github.com/golang-standards/project-layout)
