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

Kubebuilder를 이용하여 Memcached CR을 정의하고, Memcached CR을 제어하는 Memcached Controller를 개발한다.

#### 2.1. Project 생성

{% highlight console %}
# mkdir -p $GOPATH/src/github.com/ssup2/example-k8s-kubebuilder
# cd $GOPATH/src/github.com/ssup2/example-k8s-kubebuilder
# export GO111MODULE=on
# kubebuilder init --domain cache.example.com
# ls
Dockerfile  Makefile  PROJECT  bin  config  go.mod  go.sum  hack  main.go
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Project 생성</figcaption>
</figure>

#### 2.2. Memcached CR, Memcached Controller 및 관련 파일 생성

{% highlight console %}
# kubebuilder create api --group memcached --version v1 --kind Memcached
# ls
Dockerfile  Makefile  PROJECT  api  bin  config  controllers  go.mod  go.sum  hack  main.go
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Project 생성</figcaption>
</figure>

#### 2.3. Memcached CR 정의

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
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] api/v1/memcached_types.go</figcaption>
</figure>

주석에 나와있는 것처럼 Project Root Directory에서 make 명령어를 수행하여 Memcached CR을 Update한다.

#### 2.4. Memcached Controller 생성

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
		client.MatchingFields(ls),
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
# Image URL to use all building/pushing image targets
IMG ?= supsup5642/memcached-controller:latest
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] Makefile</figcaption>
</figure>

#### 2.5. Memcached Controller Image 생성 및 Push

{% highlight console %}
# make docker-build
# docker login supsup5642
# make docker-push
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Memcached CRD 생성</figcaption>
</figure>

#### 2.6. Memcached CRD 생성

{% highlight console %}
# make install
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Memcached CRD 생성</figcaption>
</figure>

#### 2.6. 

### 3. 참조

* [https://github.com/dev4devs-com/memcached-kubebuilder](https://github.com/dev4devs-com/memcached-kubebuilder)
* [https://book.kubebuilder.io/quick-start.html](https://book.kubebuilder.io/quick-start.html)
* [https://book.kubebuilder.io/cronjob-tutorial/cronjob-tutorial.html](https://book.kubebuilder.io/cronjob-tutorial/cronjob-tutorial.html)
