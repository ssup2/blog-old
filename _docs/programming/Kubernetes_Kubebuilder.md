---
title: Kubernetes Kubebuilder를 이용한 Operator 개발
category: Programming
date: 2019-11-03T12:00:00Z
lastmod: 2019-11-03T12:00:00Z
comment: true
adsense: true
---

Memcached 예제를 통해서 Kubebuilder와 Operator를 분석한다.

### 1. Kubebuilder

Kubebuilder는 Kubernetes Operator 개발을 도와주는 SDK이다. **Kubernetes CR (Custom Resource)**을 정의하고, 정의한 Kubernetes CR을 관리하는 **Kubernetes Controller** 개발을 쉽게 할 수 있도록 도와준다. 

### 2. Memcached Operator

Kubebuilder를 이용하여 Memcached CR을 정의하고, Memcached CR을 제어하는 Memcached Controller를 개발한다. Memcached Operator 전체 Code는 아래의 링크에서 확인할 수 있다.
* [https://github.com/ssup2/example-k8s-kubebuilder](https://github.com/ssup2/example-k8s-kubebuilder)

#### 2.1. 개발 환경

개발 환경은 다음과 같다.
* Ubuntu 18.04 LTS, root user
* Kubernetes 1.15
* golang 1.12.2

#### 2.2. Kubebuilder 설치

{% highlight console %}
# os=$(go env GOOS)
# arch=$(go env GOARCH)
# curl -sL https://go.kubebuilder.io/dl/2.1.0/${os}/${arch} | tar -xz -C /tmp/
# sudo mv /tmp/kubebuilder_2.1.0_${os}_${arch} /usr/local/kubebuilder
# export PATH=$PATH:/usr/local/kubebuilder/bin
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Kubebuilder 설치</figcaption>
</figure>

Kubernetes Operator SDK CLI를 설치한다.

#### 2.2. Project 생성

{% highlight console %}
# mkdir -p $GOPATH/src/github.com/ssup2/example-k8s-kubebuilder
# cd $GOPATH/src/github.com/ssup2/example-k8s-kubebuilder
# export GO111MODULE=on
# kubebuilder init --domain cache.example.com
# ls
Dockerfile  Makefile  PROJECT  bin  config  go.mod  go.sum  hack  main.go
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Project 생성</figcaption>
</figure>

**kubebuilder init** 명령어를 통해서 Memcached Oprator Project를 생성한다. [Shell 2]는 Kubebuilder를 이용하여 Project를 생성하는 과정을 나타내고 있다. init과 함께 Option으로 들어가는 domain은 API Group을 위한 Domain을 나타낸다. **Makefile**은 make를 통해서 Controller Compile, Install, Image Build등의 동작을 쉽게 수행할 수 있도록 도와준다. Dockerfile은 Controller Docker Image를 생성할 때 이용되며, config Directory는 **kustomize**를 이용하여 Kubernetes에 Operator 구동을 위한 Kubernetes YAML을 생성하는 역활을 수행한다.

#### 2.3. Memcached CR, Controller 파일 생성

{% highlight console %}
# kubebuilder create api --group memcached --version v1 --kind Memcached
# ls
Dockerfile  Makefile  PROJECT  api  bin  config  controllers  go.mod  go.sum  hack  main.go
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Project 생성</figcaption>
</figure>

**kubebuilder create api**를 이용하여 API를 생성한다. [Shell 3]은 Kuberbuilder를 이용하여 API를 생성하는 과정을 나타내고 있다. API의 Group, Version, 종류를 지정할 수 있다. Kubernetes에서 API를 생성한다는 의미는 CR을 생성하고, 생성한 CR을 관리하는 Controller를 생성한다는 의미와 동일하다. api Directory에는 생성한 CR을 Struct로 정의하는 Golang Code가 존재하며, controllers Directory에는 Controller Golang Code가 존재한다.

#### 2.4. Memcached CR 정의

{% highlight golang linenos %}
...
// MemcachedSpec defines the desired state of Memcached
type MemcachedSpec struct {
    // INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
    // Important: Run "make" to regenerate code after modifying this file

    // Memcached pod count
    Size int32 `json:"size"`
}

// MemcachedStatus defines the observed state of Memcached
type MemcachedStatus struct {
    // INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
    // Important: Run "make" to regenerate code after modifying this file

    // Memcached pod status
    Nodes []string `json:"nodes"`
}
...
// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
// Memcached is the Schema for the memcacheds API
type Memcached struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec   MemcachedSpec   `json:"spec,omitempty"`
    Status MemcachedStatus `json:"status,omitempty"`
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] api/v1/memcached_types.go</figcaption>
</figure>

[Shell 3]의 API 생성 과정을 통해서 Memcached CR은 Struct로 api/v1/memcached_types.go에 정의된다. [Code 1]처럼 memcached_types.go의 MemcachedSpec Struct와 MemcachedStatus Struct에 Memcached CR 관련 정보를 직접 추가해야 한다. Spec의 Size는 동작해야하는 Memcached Pod의 개수를 나타내고. Status의 Nodes는 Memcached가 동작하는 Pod의 이름을 나타낸다. Memcached struct위의 subresource:status 주석은 반드시 추가해야한다. Kubebuilder는 subresource:status 주석을 보고 config Directory의 Memcached CR YAML 파일에 Status 정보를 추가하기 때문이다. Memcached CR Struct를 변경한 다음 **make manifests** 명령어를 통해서 변경된 Memcached CR Struct를 Project 전체에 적용시켜야 한다.

#### 2.5. Memcached Controller 생성

{% highlight golang linenos %}
...
// MemcachedReconciler reconciles a Memcached object
type MemcachedReconciler struct {
    client.Client
    Log logr.Logger
    *runtime.Scheme
}
...
func (r *MemcachedReconciler) Reconcile(req ctrl.Request) (ctrl.Result, error) {
	_ = context.Background()
	reqLogger := r.Log.WithValues("req.Namespace", req.Namespace, "req.Name", req.Name)
	reqLogger.Info("Reconciling Memcached.")

	// Fetch the Memcached instance
	memcached := &memcachedv1.Memcached{}
	err := r.Client.Get(context.TODO(), req.NamespacedName, memcached)
	if err != nil {
		if errors.IsNotFound(err) {
			// Request object not found, could have been deleted after reconcile req.
			// Owned objects are automatically garbage collected. For additional cleanup logic use finalizers.
			// Return and don't requeue
			reqLogger.Info("Memcached resource not found. Ignoring since object must be deleted.")
			return ctrl.Result{}, nil
		}
		// Error reading the object - requeue the req.
		reqLogger.Error(err, "Failed to get Memcached.")
		return ctrl.Result{}, err
	}

	// Check if the Deployment already exists, if not create a new one
	deployment := &appsv1.Deployment{}
	err = r.Client.Get(context.TODO(), types.NamespacedName{Name: memcached.Name, Namespace: memcached.Namespace}, deployment)
	if err != nil && errors.IsNotFound(err) {
		// Define a new Deployment
		dep := r.deploymentForMemcached(memcached)
		reqLogger.Info("Creating a new Deployment.", "Deployment.Namespace", dep.Namespace, "Deployment.Name", dep.Name)
		err = r.Client.Create(context.TODO(), dep)
		if err != nil {
			reqLogger.Error(err, "Failed to create new Deployment.", "Deployment.Namespace", dep.Namespace, "Deployment.Name", dep.Name)
			return ctrl.Result{}, err
		}
		// Deployment created successfully - return and requeue
		// NOTE: that the requeue is made with the purpose to provide the deployment object for the next step to ensure the deployment size is the same as the spec.
		// Also, you could GET the deployment object again instead of requeue if you wish. See more over it here: https://godoc.org/sigs.k8s.io/controller-runtime/pkg/reconcile#Reconciler
		return reconcile.Result{Requeue: true}, nil
	} else if err != nil {
		reqLogger.Error(err, "Failed to get Deployment.")
		return ctrl.Result{}, err
	}

	// Ensure the deployment size is the same as the spec
	size := memcached.Spec.Size
	if *deployment.Spec.Replicas != size {
		deployment.Spec.Replicas = &size
		err = r.Client.Update(context.TODO(), deployment)
		if err != nil {
			reqLogger.Error(err, "Failed to update Deployment.", "Deployment.Namespace", deployment.Namespace, "Deployment.Name", deployment.Name)
			return ctrl.Result{}, err
		}
	}

	// Check if the Service already exists, if not create a new one
	// NOTE: The Service is used to expose the Deployment. However, the Service is not required at all for the memcached example to work. The purpose is to add more examples of what you can do in your operator project.
	service := &corev1.Service{}
	err = r.Client.Get(context.TODO(), types.NamespacedName{Name: memcached.Name, Namespace: memcached.Namespace}, service)
	if err != nil && errors.IsNotFound(err) {
		// Define a new Service object
		ser := r.serviceForMemcached(memcached)
		reqLogger.Info("Creating a new Service.", "Service.Namespace", ser.Namespace, "Service.Name", ser.Name)
		err = r.Client.Create(context.TODO(), ser)
		if err != nil {
			reqLogger.Error(err, "Failed to create new Service.", "Service.Namespace", ser.Namespace, "Service.Name", ser.Name)
			return ctrl.Result{}, err
		}
	} else if err != nil {
		reqLogger.Error(err, "Failed to get Service.")
		return ctrl.Result{}, err
	}

	// Update the Memcached status with the pod names
	// List the pods for this memcached's deployment
	podList := &corev1.PodList{}
	ls := labelsForMemcached(memcached.Name)
	listOps := []client.ListOption{
		client.InNamespace(req.NamespacedName.Namespace),
		client.MatchingLabels(ls),
	}
	err = r.Client.List(context.TODO(), podList, listOps...)
	if err != nil {
		reqLogger.Error(err, "Failed to list pods.", "Memcached.Namespace", memcached.Namespace, "Memcached.Name", memcached.Name)
		return ctrl.Result{}, err
	}
	podNames := getPodNames(podList.Items)

	// Update status.Nodes if needed
	if !reflect.DeepEqual(podNames, memcached.Status.Nodes) {
		memcached.Status.Nodes = podNames
		err := r.Client.Status().Update(context.TODO(), memcached)
		if err != nil {
			reqLogger.Error(err, "Failed to update Memcached status.")
			return ctrl.Result{}, err
		}
	}

	return ctrl.Result{}, nil
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] controllers/memcached_controller.go</figcaption>
</figure>

{% highlight golang linenos %}
...
    if err = (&controllers.MemcachedReconciler{
        Client: mgr.GetClient(),
        Log:    ctrl.Log.WithName("controllers").WithName("Memcached"),
        Scheme: mgr.GetScheme(),
    }).SetupWithManager(mgr); err != nil {
        setupLog.Error(err, "unable to create controller", "controller", "Memcached")
        os.Exit(1)
    }
    // +kubebuilder:scaffold:builder
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] main.go</figcaption>
</figure>

{% highlight golang linenos %}
...
# Image URL to use all building/pushing image targets
IMG ?= supsup5642/memcached-controller:latest
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] Makefile</figcaption>
</figure>

#### 2.6. Memcached Controller Image 생성 및 Push

{% highlight console %}
# docker login
# make docker-build
# make docker-push
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Memcached CRD 생성</figcaption>
</figure>

#### 2.7. Memcached CRD 생성 및 Memcached Controller Deploy

{% highlight yaml linenos %}
...
- apiGroups:
  - ""
  resources:
  - services
  - pods
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - "*"
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] config/rbac/role.yaml</figcaption>
</figure>

{% highlight console %}
# cd config/manager && kustomize edit set image controller=supsup5642/memcached-controller:latest && cd -
# kustomize build config/default | kubectl apply -f -
# kubectl -n example-k8s-kubebuilder-system get pod
NAME                                                         READY   STATUS    RESTARTS   AGE
example-k8s-kubebuilder-controller-manager-c6f85fb5d-zjjx7   2/2     Running   0          3d
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Memcached Controller Deploy</figcaption>
</figure>

#### 2.8. Memcached CR 생성을 통한 Memcached 구동

{% highlight yaml linenos %}
apiVersion: memcached.cache.example.com/v1
kind: Memcached
metadata:
  name: memcached-sample
spec:
  size: 3
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] config/samples/memcached_v1_memcached.yaml</figcaption>
</figure>

{% highlight console %}
# kubectl apply -f config/samples/memcached_v1_memcached.yaml
# kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
memcached-sample-79ccbbbbcb-8w2l7   1/1     Running   0          3m15s
memcached-sample-79ccbbbbcb-vrkmk   1/1     Running   0          3m15s
memcached-sample-79ccbbbbcb-wpgzz   1/1     Running   0          3m15s
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] Memcached Controller Deploy</figcaption>
</figure>

### 3. 참조

* [https://github.com/dev4devs-com/memcached-kubebuilder](https://github.com/dev4devs-com/memcached-kubebuilder)
* [https://github.com/operator-framework/operator-sdk/issues/1124](https://github.com/operator-framework/operator-sdk/issues/1124)
* [https://book.kubebuilder.io/quick-start.html](https://book.kubebuilder.io/quick-start.html)
* [https://book.kubebuilder.io/cronjob-tutorial/cronjob-tutorial.html](https://book.kubebuilder.io/cronjob-tutorial/cronjob-tutorial.html)
