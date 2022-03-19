---
title: Kubernetes Kubebuilder를 이용한 Operator 개발
category: Programming
date: 2019-11-03T12:00:00Z
lastmod: 2022-03-15T12:00:00Z
comment: true
adsense: true
---

Memcached 예제를 통해서 Kubebuilder와 Controller를 분석한다.

### 1. Kubebuilder

Kubebuilder는 Kubernetes Controller 개발을 도와주는 SDK이다. 사용자가 원하는 **Kubernetes CR (Custom Resource)**을 정의하고, 정의한 Kubernetes CR을 관리하는 **Controller** 개발을 쉽게 할 수 있도록 도와준다. Kubebuilder는 Kubernetes CR과 관련된 대부분의 파일을 자동으로 생성해준다. 개발자는 생성된 Kubernetes CR 관련 파일을 수정만 하면 되기 때문에 쉽게 Kubernetes CR을 정의하고 이용할 수 있다. 

또한 Kubebuilder는 Standard Golang Project Layout을 준수하는 Controller Manager Project를 생성해준다. 여기서 Controller Manager는 다수의 Controller를 관리하는 역할을 수행하는 구성요소를 의미한다. 즉 개발자는 Kubebuilder를 이용하여 다수의 Controller를 포함하는 Controller Manaager를 쉽게 개발할 수 있게된다. Kubernetes CR을 관리하는 Controller뿐만 아니라 Kubernetes에서 Default로 제공하는 Resource (Object)를 제어하는 Controller도 개발할 수 있다.

#### 1.1. Controller Manager Archiecture

![[그림 1] Controller Manager Architecture]({{site.baseurl}}/images/programming/Kubernetes_Kubebuilder/Controller_Manager_Architecture.PNG){: width="700px"}

[그림 1]은 Kubebuilder로 구현한 Controller Manager의 Architecture를 나타내고 있다. Controller Manager는 Kubernetes Cache, Kubernetes Client, WorkQueue, Controller로 구성되어 있다. **Kubernetes Cache**는 Kubernetes API Server의 부하를 줄이기 위해 Kubernetes API Server로부터 가져온 정보를 Caching하는 역할을 수행한다. Kubernetes Cache 내부에는 Informer가 존재한다. **Informer**는 Controller가 관리해야하는 Object (Resource)를 Watch하여 Object의 생성/삭제/변경 Event를 전달받는 역할을 수행한다. Informer가 수신한 Object Evnet 정보는 Object의 Name 및 Object가 위치한 Namespace 정보만 추출되어 Work Queue에 Enqueue된다.

**Kubernetes Client**는 Controller에서 Kubernetes API와 통신하기 위한 Client 역할을 수행한다. 기본적으로 Manager에는 하나의 Kubernetes Client Instance가 존재하며 다수의 Controller가 하나의 Kubernetes Client Instance를 공유하여 이용한다. 기본적으로 Kubernetes Client의 Object (Resource) Write 요청은 Kubernetes API Server에게 바로 전달되지만, Kubernetes Client의 Object Read 요청은 Kubernetes API Server가 아니라 Kubernetes Cache에게 전달된다. 하지만 개발자의 설정에 의해서 Kubernetes Client가 Kubernetes Client를 이용하지 않도록 설정할 수도 있다.

**Work Queue**는 Informer가 넣어준 Event가 발생한 Object의 Name/Namespace 정보가 저장된다. 각 Controller를 위한 전용 Work Queue가 존재한다. Controller의 **Reconciler**는 Work Queue에 저장된 Event가 발생한 Object의 Name/Namespace 정보를 Dequeue하여 가져온 다음, Kubernetes Client를 이용하여 Object를 제어하는 역할을 수행한다. 여기서 Reconciler가 Object를 제어한다는 의미는 Object의 Spec과 Status를 일치시키는 작업을 의미한다.

Reconciler는 제어에 성공한 Object의 경우에는 해당 Object 정보를 폐기한다. 하지만 Reconciler가 제어에 실패한 Object의 경우 해당 Object의 Name/Namespace 정보는 다시 Work Queue로 Requeue되어 저장된다. 이후 특정시간이 지난 다음 Reconciler는 다시 Work Queue로부터 제어에 실패한 Object를 Dequeue하여 다시 제어를 시도 한다. Object 제어에 또 실패한다면 다시 Work Queue로 Requeue 되어, 제어가 성공될때까지 반복하게 된다. Object가 Work Queue에서 대기하는 시간은 Object가 Work Queue에 Requeue되어 저장된 회수에 따라서 Exponentially하게 증가한다.

Kubernetes Client가 이용하는 Kubernetes Cache로 인해서 Reconciler가 Kubernetes Client를 통하여 변경 및 저장한 Object를 다시 Kubernetes Client를 통해서 읽어올 경우, 변경전의 Object를 다시 얻을 수 있다. 이러한 특징으로 인한 문제를 방지하기 위해서는 Reconciler가 수행하는 Object 제어 Logic은 여러번 수행되어도 동일한 결과를 얻을수 있는 **멱등성**을 만족시켜야 한다. 즉 Reconciler는 State를 갖지 않는 Stateless한 특징을 갖고 있어야 한다.

#### 1.2. Controller Manager HA

Controller Manager도 Kubernetes 위에서 동작하는 Pod(App)이기 때문에, Controller Manager의 HA를 위해서는 다수의 동일한 Controller Manager를 동시에 구동하는 것이 좋다. 다수의 동일한 Controller Manager를 구동하는 경우 하나의 Controller Manager만 실제로 동작하고 나머지 Controller Manager는 대기 상태를 유지하는 **Active-standby** 형태로 동작한다. Controller Manage 실행시 'enable-leader-election' 옵션을 설정하면 Controller Manager HA 기능을 이용할 수 있다.

#### 1.3. Controller Metric, kube-rback-proxy

Controller는 자기 자신의 Metric 정보인 Controller Metric 정보를 제공한다. Controller Metric 정보의 접근 권한은 Controller Pod안에서 같이 동작하는 Proxy Server인 kube-rbac-proxy에 의해서 결정된다. [그림 1]에서 Controller Metric 정보가 kube-rback-proxy를 통해서 전송되는 과정을 나타내고 있다.

### 2. Memcached Controller

Kubebuilder를 이용하여 Memcached CR을 정의하고, Memcached CR을 제어하는 Memcached Controller를 개발한다. Controller Manager 및 Controller Manager에 포함된 Memcached Controller 전체 Code는 아래의 링크에서 확인할 수 있다.

* [https://github.com/ssup2/example-k8s-kubebuilder](https://github.com/ssup2/example-k8s-kubebuilder)

#### 2.1. 개발 환경

개발 환경은 다음과 같다.
* Ubuntu 18.04 LTS, root user
* Kubernetes 1.23.4
* golang 1.17.6
* kubebuilder 3.3.0

#### 2.2. Kubebuilder 설치

{% highlight console %}
# curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
# chmod +x kubebuilder && mv kubebuilder /usr/local/bin/
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Kubebuilder 설치</figcaption>
</figure>

Kubebuilder SDK CLI를 설치한다.

#### 2.2. Project 생성

{% highlight console %}
# mkdir -p $GOPATH/src/github.com/ssup2/example-k8s-kubebuilder
# cd $GOPATH/src/github.com/ssup2/example-k8s-kubebuilder
# export GO111MODULE=on
# kubebuilder init --domain cache.example.com --repo github.com/ssup2/example-k8s-kubebuilder
# ls
Dockerfile  Makefile  PROJECT  config  go.mod  go.sum  hack  main.go
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Project 생성</figcaption>
</figure>

**kubebuilder init** 명령어를 통해서 Memcached Oprator Project를 생성한다.  repo는 Git Repo를 의미한다. [Shell 2]는 Kubebuilder를 이용하여 Project를 생성하는 과정을 나타내고 있다. init과 함께 Option으로 들어가는 domain은 API Group을 위한 Domain을 나타낸다. **Makefile**은 make를 통해서 Controller Compile, Install, Image Build등의 동작을 쉽게 수행할 수 있도록 도와준다. Dockerfile은 Controller Docker Image를 생성할 때 이용되며, config Directory는 **kustomize**를 이용하여 Kubernetes에 Operator 구동을 위한 Kubernetes YAML을 생성하는 역할을 수행한다.

#### 2.3. Memcached CR, Controller 파일 생성

{% highlight console %}
# kubebuilder create api --group memcached --version v1 --kind Memcached
# Create Resource [y/n]
# y
# Create Controller [y/n]
# y
...
# ls
Dockerfile  Makefile  PROJECT  api  config  controllers  go.mod  go.sum  hack  main.go
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Project 생성</figcaption>
</figure>

**kubebuilder create api**를 이용하여 API를 생성한다. [Shell 3]은 Kuberbuilder를 이용하여 API를 생성하는 과정을 나타내고 있다. API의 Group, Version, 종류를 지정할 수 있다. Kubernetes에서 API를 생성한다는 의미는 CR(Object)을 생성하고, 생성한 CR을 관리하는 Controller를 생성한다는 의미와 동일하다. api Directory에는 생성한 CR을 Struct로 정의하는 Golang Code가 존재하며, controllers Directory에는 Controller Golang Code가 존재한다.

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

[Shell 3]의 API 생성 과정을 통해서 Memcached CR은 Struct로 api/v1/memcached_types.go에 정의된다. [Code 1]처럼 memcached_types.go의 MemcachedSpec Struct와 MemcachedStatus Struct에 Memcached CR 관련 정보를 직접 추가해야 한다. Spec의 Size는 동작해야하는 Memcached Pod의 개수를 나타내고. Status의 Nodes는 Memcached가 동작하는 Pod의 이름을 나타낸다. 

Memcached struct위의 subresource:status 주석은 반드시 추가해야한다. Kubebuilder는 subresource:status 주석을 보고 config Directory의 Memcached CR YAML 파일에 Status 정보를 추가하기 때문이다. Memcached CR Struct를 변경한 다음 **make manifests** 명령어를 통해서 변경된 Memcached CR Struct를 Project 전체에 적용시켜야 한다.

#### 2.5. Memcached Controller 개발

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
<figcaption class="caption">[Code 2] main.go</figcaption>
</figure>

[Code 2]는 Controller의 main() 함수의 일부분을 나타내고 있다. 3번째 줄은 Controller Manager에 의해서 Cache 설정이 완료된 Kubernetes Client를 Controller의 Reconciler에게 넘기는 부분이다. Reconciler에서는 Controller Manager로부터 받은 Kubernetes Client를 이용하여 Kubernetes API Server와 통신한다.

{% highlight golang linenos %}
...
// MemcachedReconciler reconciles a Memcached object
type MemcachedReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// +kubebuilder:rbac:groups=memcached.cache.example.com,resources=memcacheds,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=memcached.cache.example.com,resources=memcacheds/status,verbs=get;update;patch

func (r *MemcachedReconciler) Reconcile(req ctrl.Request) (ctrl.Result, error) {
	reqLogger := log.FromContext(ctx).WithValues("req.Namespace", req.Namespace, "req.Name", req.Name)
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

func (r *MemcachedReconciler) SetupWithManager(mgr ctrl.Manager) error {
    return ctrl.NewControllerManagedBy(mgr).
        For(&memcachedv1.Memcached{}).
		Owns(&appsv1.Deployment{}).
        Complete(r)
}  

// deploymentForMemcached returns a memcached Deployment object
func (r *MemcachedReconciler) deploymentForMemcached(m *memcachedv1.Memcached) *appsv1.Deployment {
    ls := labelsForMemcached(m.Name)
    replicas := m.Spec.Size

    dep := &appsv1.Deployment{
        ObjectMeta: v1.ObjectMeta{
            Name:      m.Name,
            Namespace: m.Namespace,
        },
        Spec: appsv1.DeploymentSpec{
            Replicas: &replicas,
            Selector: &v1.LabelSelector{
                MatchLabels: ls,
            },
            Template: corev1.PodTemplateSpec{
                ObjectMeta: v1.ObjectMeta{
                    Labels: ls,
                },
                Spec: corev1.PodSpec{
                    Containers: []corev1.Container{ {
                        Image:   "memcached:1.4.36-alpine",
                        Name:    "memcached",
                        Command: []string{"memcached", "-m=64", "-o", "modern", "-v"},
                        Ports: []corev1.ContainerPort{ {
                            ContainerPort: 11211,
                            Name:          "memcached",
                        } },
                    } },
                },
            },
        },
    }

    // Set Memcached instance as the owner of the Deployment.
    ctrl.SetControllerReference(m, dep, r.Scheme) //todo check how to get the schema

    return dep
}

// serviceForMemcached function takes in a Memcached object and returns a Service for that object.
func (r *MemcachedReconciler) serviceForMemcached(m *memcachedv1.Memcached) *corev1.Service {
    ls := labelsForMemcached(m.Name)
    ser := &corev1.Service{
        ObjectMeta: v1.ObjectMeta{
            Name:      m.Name,
            Namespace: m.Namespace,
        },
        Spec: corev1.ServiceSpec{
            Selector: ls,
            Ports: []corev1.ServicePort{
                {
                    Port: 11211,
                    Name: m.Name,
                },
            },
        },
    }

    // Set Memcached instance as the owner of the Service.
    ctrl.SetControllerReference(m, ser, r.Scheme) //todo check how to get the schema
    return ser
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] controllers/memcached_controller.go</figcaption>
</figure>

[Code 3]는 Memcached Controller의 핵심 부분을 나타내고 있다. 9,10번째 줄은 Kubebuilder Annotation이며 Memcached Controller에 적용되는 Memcached CR에 대한 Role을 나타내고 있다. Kubebuilder는 해당 Annotation 정보를 통해서 Memcached Controller에 적용되는 Role YAML 파일을 생성한다.

109~113번째 줄은 Memcached CR 또는 Memcached CR이 소유(이용)하고 있는 Deployment Object의 변경을 Watch하는 부분이다. Memcached CR 또는 Memcached CR이 소유하는 Deployment Resource가 변경되는 경우, 변경된 Memcached CR 또는 Deployment Resource의 정보가 Reconcile() 함수에게 전달된다. Memcached CR이 소유하고 있는 Deployment Object의 Meta 정보에는 "ownerReferences" 항목에 해당 Deployment Object를 소유하는 Memcached CR 정보가 저장되어 있다.

151번째 줄은 Deployment Object에 해당 Deployment Object를 소유하고 있는 Memcached CR 정보를 저장하는 함수를 나타내고 있으며, 176번째 줄은 Service Object에 해당 Service Object를 소유하고 있는 Memcached CR 정보를 저장하는 함수를 나타내고 있다. 이러한 소유설정은 Kubernetes에서 공식적으로 지원하는 기능이며 Object GC(Garbage Collection)를 위해서 필요하다.

Reconcile() 함수에 소속된 16~29번째 줄은 Work Queue로부터 가져온 Memcached CR의 Name/Namespace 정보를 바탕으로 Kubernetes Client를 이용하여 Memcached CR을 얻는 부분이다. 여기서 주목 해야하는 부분은 19~24번째 줄이다. Memcached CR 정보를 얻으려고 했지만 존재하지 않을 경우에는 해당 Memcached CR이 제거되었다는 의미를 나타낸다. 따라서 Memcached CR이 소유하고 있는 Deployment Resource와 Service Object를 제거하는 Logic이 있어야 하지만, Memcached Controller에서는 해당 Logic이 존재하지 않는다. Deployment/Service Object의 소유자가 제거된 Memached CR인걸 알고 Kubernetes에서 Object GC 과정을 통해서 자동으로 제거해주기 때문이다.

32~50번째 줄은 Work Queue로부터 가져온 Memcached CR의 Name/Namespace 정보를 바탕으로 현재 상태의 Deployment Object를 얻는 부분이다. 53~61번째 줄은 Memcached CR의 Replica (Size)와 현재 상태의 Deployment Object의 Replica가 다르다면 Deployment Object의 Replica 개수를 Memcached CR의 Replica에 맞추는 동작을 수행하는 부분이다. 65~79 부분은 Memcached CR을 위한 Kubernetes Service를 생성하는 부분이고, 83~104번째 줄은 Memcached CR의 Status 정보를 Update하는 부분이다.

이처럼 Reconcile() 함수는 변경된 Memcached CR을 얻고, 얻은 Memcached CR을 바탕으로 Deployment Object를 제어하는 동작을 반복한다. Reconcile() 함수 곳곳에서 Manager Client를 통해서 Resource를 변경한뒤 Requeue Option과 함께 return하는 부분을 찾을 수 있다. Resource 변경이 완료되었어도 실제 반영에는 시간이 걸리기 때문에, Requeue Option을 이용하여 일정 시간이 지난후에 다시 Reconcile() 함수가 실행되도록 만들고 있다.

#### 2.6. Controller Manager Image 생성 및 Push

{% highlight golang linenos %}
...
# Image URL to use all building/pushing image targets
IMG ?= supsup5642/memcached-controller:latest
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] Makefile</figcaption>
</figure>

{% highlight console %}
# docker login
# make docker-build
# make docker-push
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Controller Manager Image 생성 및 Push</figcaption>
</figure>

[Code 4]의 내용처럼 Makefile에 IMG 이름을 지정하고 [Shell 4]의 명령어들을 통해서 Controller Manager Image를 생성하고, 생성한 Image를 Docker Hub에 Push한다.

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
<figcaption class="caption">[Code 5] config/rbac/role.yaml</figcaption>
</figure>

{% highlight console %}
# cd config/manager && kustomize edit set image controller=supsup5642/memcached-controller:latest && cd -
# kustomize build config/default | kubectl apply -f -
# kubectl -n example-k8s-kubebuilder-system get pod
NAME                                                         READY   STATUS    RESTARTS   AGE
example-k8s-kubebuilder-controller-manager-c6f85fb5d-zjjx7   2/2     Running   0          3d
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Controller Manager Deploy</figcaption>
</figure>

[Code 5]의 내용처럼 Controller Manager에 적용할 Role을 수정하고, [Shell 5]의 내용처럼 kustomize를 이용하여 Memcached CRD를 생성하고 Controller Manager를 구동한다.

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

[Code 5]의 내용처럼 Memecached CR을 생성하여 Memcached를 구동한다.

### 3. 참조

* [https://github.com/dev4devs-com/memcached-kubebuilder](https://github.com/dev4devs-com/memcached-kubebuilder)
* [https://github.com/operator-framework/operator-sdk/issues/1124](https://github.com/operator-framework/operator-sdk/issues/1124)
* [https://book.kubebuilder.io/quick-start.html](https://book.kubebuilder.io/quick-start.html)
* [https://book.kubebuilder.io/cronjob-tutorial/cronjob-tutorial.html](https://book.kubebuilder.io/cronjob-tutorial/cronjob-tutorial.html)
* [https://pkg.go.dev/sigs.k8s.io/controller-runtime](https://pkg.go.dev/sigs.k8s.io/controller-runtime)
* [https://getoutsidedoor.com/2020/05/09/kubernetes-controller-%EA%B5%AC%ED%98%84%ED%95%B4%EB%B3%B4%EA%B8%B0/](https://getoutsidedoor.com/2020/05/09/kubernetes-controller-%EA%B5%AC%ED%98%84%ED%95%B4%EB%B3%B4%EA%B8%B0/)
* [https://stuartleeks.com/posts/kubebuilder-event-filters-part-2-update/](https://stuartleeks.com/posts/kubebuilder-event-filters-part-2-update/)
