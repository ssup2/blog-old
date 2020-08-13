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

Operator SDK는 의미 그대로 Kubernetes Operator 개발을 도와주는 SDK이다. Operator SDK를 이용하여 Golang Operator, Ansible Operator, Helm Operator 3가지 Type의 Operator를 개발할 수 있다. Golang Operator는 특정 **Kubernetes CR (Custom Resource)**을 관리하는 Golang으로 개발된 **Controller들의 집합**을 의미한다. 따라서 Golang Operator를 개발하는 과정은 크게 Kubernetes CR을 정의하는 과정과 Golang을 이용하여 Controller를 개발하는 과정으로 분류할 수 있다.

Operator SDK는 Kubernetes CR과 관련된 대부분의 파일을 생성해준다. 개발자는 생성된 Kubernetes CR 관련 파일을 수정만 하면 되기 때문에 쉽게 Kubernetes CR을 정의할 수 있다. 또한 Operator SDK는 Standard Golang Project Layout을 준수하는 Controller Project를 생성해준다. Operator SDK가 생성한 Controller Project에는 모든 Controller가 수행 해야하는 공통 기능이 Golang으로 구현되어 포함되어 있다. 개발자는 Controller의 핵심 기능 개발에만 집중할 수 있기 때문에 쉽게 Controller를 개발할 수 있다.

#### 1.1. Controller Package

![[그림 1] Controller Package]({{site.baseurl}}/images/programming/Kubernetes_Operator_SDK_Golang/Controller_Package.PNG){: width="700px"}

[그림 1]은 Operator SDK로 구현한 Controller의 주요 Package를 나타내고 있다. Controller는 크게 SDK Controller Package, Runtime Controller Package, Runtime Manager Package로 구성되어 있다. SDK Controller Package는 Operator SDK를 이용하여 Controller를 개발하는 개발자가 생성하는 Package이다. **Runtime**은 Controller 개발을 도와주는 Library 역할을 수행하는 Package를 의미하며 Runtime Controller Package, Runtime Manager Package는 모두 Runtime의 하위 Package를 의미한다.

Runtime Controller Package는 Kubernetes API Server를 통해서 Controller가 관리 해야할 CR의 변경를 감지하고, 변경된 CR의 Name과 Namespace 정보를 자신의 Work Queue에 넣는다. 그 후 Runtime Controller Package는 Work Queue에 있는 CR의 Name과 Namespace 정보를 다시 SDK Controller Package의 Reconcile Loop에 전달하여 Reconcile Loop가 동작하도록 만든다.

Runtime Manager Package는 Controller가 이용하는 Kubernetes Client 및 Kubernetes Client가 이용하는 Cache를 초기화 하고, 초기화된 Kubernetes Client를 SDK Controller Package에게 전달한다. SDK Controller Package에서 Kubernetes Client를 이용하여 Kubernetes API Server에 Write 요청을 수행하는 경우 Kubernetes Client는 해당 Write 요청을 바로 Kubernetes API Server에 전달하지만, Read 요청을 수행하는 경우에는 Kubernetes API Server의 부하를 줄이기 위해서 Kubernetes API Server에서 직접 Read를 수행하지 않고 Runtime Manager Package의 Cache에서 Read한다. Kubernetes API Server와 Cache 사이의 동기화는 주기적으로 이루어진다.

SDK Controller Package는 실제 Controller Logic을 수행하는 Reconcile Loop와 Runtime Manager Package로부터 전달 받은 Kubernetes Client를 갖고 있다. Reconcile Loop는 Kubernetes Client를 이용하여 Runtime Controller Package로부터 전달받은 CR의 Name/Namespace 정보를 바탕으로 전체 CR 정보를 얻는다. 또한 CR과 연관된 현재 상태의 Resource 정보도 얻는다. **이후 Reconcile Loop는 현재 상태의 Resource가 CR과 일치하는지 확인한다. 일치하지 않는다면 Reconcile Loop는 Resource를 생성/삭제하여 CR과 일치하도록 만든다.**

Recocile Loop의 동작 수행중 Error가 발생하거나 일정 시간 대기가 필요한 경우, Recocile Loop는 Runtime Controller Package의 Work Queue에 CR의 Name, Namespace 정보를 Requeue하여 일정 시간을 대기한 이후에 다시 Controller가 Recocile Loop를 실행하도록 만든다. Controller가 Recocile Loop를 다시 실행시키기 위해서 대기하는 시간은 Exponentially하게 증가한다.

#### 1.2. Controller HA

Controller도 Kubernetes 위에서 동작하는 App이기 때문에, Controller의 HA를 위해서는 다수의 동일한 Controller를 동시에 구동하는 것이 좋다. 다수의 동일한 Controller를 구동하는 경우 하나의 Controller만 실제로 역할을 수행하고 나머지 Controller는 대기 상태를 유지하는 **Active-standby** 형태로 동작한다. 다수의 동일한 Controller 중에서 Active 상태로 만들 Controller를 선정하는 알고리즘은 Leader-for-life과 Leader-with-lease가 있다. 두 알고리즘 모두 Operator SDK를 이용하여 쉽게 구현이 가능하다.

* Leader-for-life : Active 상태의 Controller가 완전히 죽고나서야 Standby 상태의 Controller를 Active 상태로 만든다. 동시에 하나의 Controller만 동작하는 것이 보장되기 때문에 Split Brain 현상을 방지할 수 있지만, Standby 상태의 Controller가 Active 상태가 되기 전까지의 지연 시간이 길다는 단점을 갖고 있다. Operator SDK가 기본적으로 설정하는 선정 알고리즘이다.

* Leader-with-lease : Active 상태의 Controller가 임차권 (Lease)을 갱신하지 않으면 죽은것으로 간주하고 Standby 상태의 Controller를 Active 상태로 변경한다. Active 상태의 Controller가 완전히 죽지 않아도 Standby 상태의 Controller가 Active 상태로 변경될 수 있기 때문에 변경 지연 시간은 짧지만, 임차권이 갱신이 안된다고 Active 상태의 Controller가 동작을 완전히 멈추었다는걸 보장하는 것은 아니기 때문에 동시에 여러개의 Controller가 동작하여 Split Brain이 발생할 수 있다.

### 2. Memcached Golang Operator

Memcached Golang Operator 예제에서는 Memcached CR을 정의하고, 정의한 Memcached CR을 관리하는 Controller인 Memcached Controller를 개발한다. Memcached Golang Operator 전체 Code는 아래의 링크에서 확인할 수 있다.

* [https://github.com/operator-framework/operator-sdk-samples/tree/master/memcached-operator](https://github.com/operator-framework/operator-sdk-samples/tree/master/memcached-operator)
* [https://github.com/ssup2/example-k8s-operator-golang](https://github.com/ssup2/example-k8s-operator-golang)

#### 2.1. 개발 환경

개발 환경은 다음과 같다.
* Ubuntu 18.04 LTS, root user
* Kubernetes 1.12
* golang 1.12.2

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
# mkdir -p $GOPATH/src/github.com/ssup2 
# cd $GOPATH/src/github.com/ssup2
# export GO111MODULE=on
# operator-sdk new example-k8s-operator-golang
# cd example-k8s-operator-golang && ls
build  cmd  deploy  go.mod  go.sum  pkg  tools.go  vendor  version
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Project 생성</figcaption>
</figure>

**operator-sdk new** 명령어를 통해서 Standard Golang Project Layout을 준수하는 Memcached Operator Project를 생성한다. [Shell 2]에서 조회되는 bulid, cmd, pkg, vendor Directory는 Memcached Operator Project를 위한 Standard Go Project Layout의 일부분이다. deploy Directory에는 Kubernetes에 Memcached Operator 구동을 위한 Kubernetes YAML 파일이 생성된다.

#### 2.4. Memcached CR 정의

{% highlight console %}
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

Memcached CR 관련 Golang Struct는 pkg/apis/cache/v1alpha1 Directory 아래의 memcached_types.go에 정의된다. [Code 1]처럼 memcached_types.go의 MemcachedSpec Struct와 MemcachedStatus Struct에 Memcached CR 관련 정보를 직접 추가해야 한다. Spec의 Size는 동작해야하는 Memcached Pod의 개수를 나타내고. Status의 Nodes는 Memcached가 동작하는 Pod의 이름을 나타낸다.

#### 2.5. Memcached Controller 생성

{% highlight console %}
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

[Code 2]는 Memcached Controller의 핵심 부분을 나타내고 있다. 2번째 줄의 add() 함수는 Memcached Controller를 초기화하는 함수이다. 8~11번째 줄은 Runtime Controller Package를 이용하여 Memcached CR을 Watch하는 부분이다. 13~19번째 줄은 Runtime Controller Package를 이용하여 Deployment Resource를 Watch하는 부분이다. Memcached CR 또는 Memcached CR이 소유하는 Deployment Resource가 변경되는 경우, Runtime Controller Package는 해당 Memcached CR의 Name/Namespace 정보를 Reconcile Loop 역할을 수행하는 Reconcile() 함수에게 전달한다.

Reconcile() 함수의 일부분인 29~41번째 줄은 Runtime Controller Package로부터 받은 Memcached CR의 Name/Namespace 정보를 바탕으로 Manager Client를 이용하여 Memcached CR을 얻는 부분이다. 44~60번째 줄은 Runtime Controller Package로부터 받은 Memcached CR의 Name/Namespace 정보를 바탕으로 현재 상태의 Deployment Resource를 얻는 부분이다. 62~71번째 줄은 Memcached CR의 Replica (Size)와 현재 상태의 Deployment Resource의 Replica가 다르다면 Deployment Resource의 Replica 개수를 Memcached CR의 Replica에 맞추는 동작을 수행하는 부분이다. 74~94번째 줄은 Memcached CR의 Status 정보를 Update하는 부분이다. 이처럼 Reconcile() 함수는 변경된 Memcached CR을 얻고, 얻은 Memcached CR을 바탕으로 Deployment Resource를 제어하는 동작을 반복한다.

Reconcile() 함수 곳곳에서 Manager Client를 통해서 Resource를 변경한뒤 Requeue Option과 함께 return하는 부분을 찾을 수 있다. Resource 변경이 완료되었어도 실제 반영에는 시간이 걸리기 때문에, Requeue Option을 이용하여 일정 시간이 지난후에 다시 Reconcile() 함수가 실행되도록 만들고 있다.

#### 2.6. Memcached CRD 생성

{% highlight console %}
# kubectl create -f deploy/crds/cache_v1alpha1_memcached_crd.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Memcached CRD 생성</figcaption>
</figure>

정의된 Memcached CR을 Kubernetes에서 생성하기 위해서는 Memcached CR을 정의하는 Memcached CRD (Custom Resource Definition)을 Kubernetes에 생성해야 한다. [Shell 3]에서 생성된 cache_v1alpha1_memcached_crd.yaml을 이용하여 Memcached CRD를 Kubernetes에 적용한다.

#### 2.7. Memcached Operator 구동

{% highlight console %}
# export GO111MODULE=on
# go mod vendor
# operator-sdk build supsup5642/memcached-operator:v0.0.1
# docker push supsup5642/memcached-operator:v0.0.1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] Memcached Operator Image 생성 및 Push</figcaption>
</figure>

**operator-sdk build** 명령어를 이용하여 및 개발한 Memcached Operator를 기반으로 하는 Container Image로 생성한 다음 Docker Registry에 Push한다. Container Image의 이름은 개인 Repository에 맞도록 변경한다.

{% highlight console %}
# sed -i 's|REPLACE_IMAGE|supsup5642/memcached-operator:v0.0.1|g' deploy/operator.yaml
# kubectl create -f deploy/service_account.yaml
# kubectl create -f deploy/role.yaml
# kubectl create -f deploy/role_binding.yaml
# kubectl create -f deploy/operator.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 7] Memcached Operator 구동</figcaption>
</figure>

[Shell 2]에서 생성된 Memcached Operator 관련 Kubernetes YAML 파일을 이용하여 Kubernetes에 Memcached Operator를 구동한다.

#### 2.8. Memcached CR 생성을 통한 Memcached 구동

{% highlight console %}
# kubectl apply -f deploy/crds/cache_v1alpha1_memcached_cr.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 8] Memcached 구동</figcaption>
</figure>

[Shell 3]에서 생성된 cache_v1alpha1_memcached_cr.yaml을 이용하여 Kubernetes에 Memcached CR을 생성한다. Memcached Operator는 생성된 Memcached CR의 내용을 바탕으로 Memcached를 구동한다.

{% highlight console %}
# kubectl get pod
NAME                                              READY   STATUS    RESTARTS   AGE
example-k8s-operator-golang-867bd5754d-pc2m9      1/1     Running   3          2m31s
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
* [https://github.com/operator-framework/operator-sdk/blob/master/doc/user/client.md](https://github.com/operator-framework/operator-sdk/blob/master/doc/user/client.md)
* [https://itnext.io/analyzing-value-of-operator-framework-for-kubernetes-community-5a65abc259ec](https://itnext.io/analyzing-value-of-operator-framework-for-kubernetes-community-5a65abc259ec)
* [https://weekly-geekly.github.io/articles/446648/index.html](https://weekly-geekly.github.io/articles/446648/index.html)
* [https://medium.com/@cloudark/kubernetes-custom-controllers-b6c7d0668fdf](https://medium.com/@cloudark/kubernetes-custom-controllers-b6c7d0668fdf)
* [https://www.slideshare.net/CloudOps2005/operator-sdk-for-k8s-using-go](https://www.slideshare.net/CloudOps2005/operator-sdk-for-k8s-using-go)
* [https://medium.com/@shubhomoybiswas/writing-kubernetes-operator-using-operator-sdk-c2e7f845163a](https://medium.com/@shubhomoybiswas/writing-kubernetes-operator-using-operator-sdk-c2e7f845163a)
* [https://itnext.io/how-to-create-a-kubernetes-custom-controller-using-client-go-f36a7a7536cc](https://itnext.io/how-to-create-a-kubernetes-custom-controller-using-client-go-f36a7a7536cc)
* [https://github.com/golang-standards/project-layout](https://github.com/golang-standards/project-layout)
