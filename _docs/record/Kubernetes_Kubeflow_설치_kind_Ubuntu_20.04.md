---
title: Kubernetes Kubeflow 설치 / kind 이용 / Ubuntu 20.04 환경
category: Record
date: 2022-08-06T12:00:00Z
lastmod: 2022-08-06T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* Kubeflow 1.4.0
* kind v0.14.0
* Kubernetes 1.24.14
* Kustomize 3.2.0

### 2. kind 설치

~~~console
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
# chmod +x ./kind
# sudo mv ./kind /usr/local/bin/kind
~~~

Kubernetes Cluster 생성을 위해서 kind를 설치한다.

### 3. Kustomize 설치

~~~console
# wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64 -O /usr/bin/kustomize
~~~

Kubeflow 설치를 위해서 Kustomize를 설치한다.

### 4. Kubernetes Cluster 생성

~~~console
# kind create cluster
...

# kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   76s   v1.24.0
~~~

kind를 이용하여 Control-plane 1대로 구성되어 있는 Master Node Cluster 한대를 구성한다.

### 5. Kubeflow 설치

~~~console
# git clone https://github.com/kubeflow/manifests
# cd manifests
# git checkout v1.6.0-rc.1
# while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
...

# kubectl get pod -A
NAMESPACE                   NAME                                                     READY   STATUS    RESTARTS        AGE
auth                        dex-8579644bbb-8rbl7                                     1/1     Running   2 (5m35s ago)   23m
cert-manager                cert-manager-7857bf84dd-hbssk                            1/1     Running   1 (6m10s ago)   23m
cert-manager                cert-manager-cainjector-5497868477-ntzbp                 1/1     Running   5 (4m52s ago)   23m
cert-manager                cert-manager-webhook-768cbc94b8-t9xnt                    1/1     Running   1 (6m10s ago)   23m
istio-system                authservice-0                                            1/1     Running   1 (6m10s ago)   23m
istio-system                cluster-local-gateway-667767766c-cx9qp                   1/1     Running   1 (6m9s ago)    23m
istio-system                istio-ingressgateway-67d6475549-f726s                    1/1     Running   1 (6m9s ago)    23m
istio-system                istiod-c8965d9c5-mr6jj                                   1/1     Running   2 (4m47s ago)   23m
knative-eventing            eventing-controller-c68576ff-tnhgw                       1/1     Running   1 (6m9s ago)    23m
knative-eventing            eventing-webhook-784df9bbb6-5xggh                        1/1     Running   3 (4m51s ago)   23m
knative-serving             activator-6f97444fcd-2xrwg                               2/2     Running   4 (3m27s ago)   22m
knative-serving             autoscaler-564f8ffbfb-2bfdq                              2/2     Running   4 (3m47s ago)   22m
knative-serving             controller-5ffdc46df9-r4cqj                              2/2     Running   6 (3m40s ago)   22m
knative-serving             domain-mapping-66b97d97b6-85s48                          2/2     Running   6 (2m52s ago)   22m
knative-serving             domainmapping-webhook-5b9c78f46c-6l6q7                   2/2     Running   6 (3m40s ago)   22m
knative-serving             net-istio-controller-589c985689-ntfq8                    2/2     Running   6 (3m20s ago)   22m
knative-serving             net-istio-webhook-7b89f945c9-cxr9n                       2/2     Running   6 (3m25s ago)   22m
knative-serving             webhook-75d5cc85d8-x5w8f                                 2/2     Running   6 (3m40s ago)   22m
kube-system                 coredns-6d4b75cb6d-59s7s                                 1/1     Running   1 (6m9s ago)    24m
kube-system                 coredns-6d4b75cb6d-nzqbt                                 1/1     Running   1 (6m10s ago)   24m
kube-system                 etcd-kind-control-plane                                  1/1     Running   1 (6m9s ago)    24m
kube-system                 kindnet-qln6n                                            1/1     Running   1 (6m9s ago)    24m
kube-system                 kube-apiserver-kind-control-plane                        1/1     Running   1 (6m10s ago)   24m
kube-system                 kube-controller-manager-kind-control-plane               1/1     Running   6 (4m ago)      24m
kube-system                 kube-proxy-24tj2                                         1/1     Running   1 (6m10s ago)   24m
kube-system                 kube-scheduler-kind-control-plane                        1/1     Running   6 (4m ago)      24m
kubeflow-user-example-com   ml-pipeline-ui-artifact-7565454755-hs9t6                 2/2     Running   0               117s
kubeflow-user-example-com   ml-pipeline-visualizationserver-665bb6b8fc-rfv9z         2/2     Running   0               117s
kubeflow                    admission-webhook-deployment-598859f878-q9vcr            1/1     Running   1 (6m9s ago)    22m
kubeflow                    cache-server-bcd48f574-4xl7g                             2/2     Running   2 (6m9s ago)    22m
kubeflow                    centraldashboard-5487b6489b-wq5kw                        2/2     Running   2 (6m9s ago)    22m
kubeflow                    jupyter-web-app-deployment-5b7df555bf-nvsfp              1/1     Running   1 (6m9s ago)    22m
kubeflow                    katib-controller-578b6b9f67-hjd7c                        1/1     Running   2 (4m54s ago)   22m
kubeflow                    katib-db-manager-55fd9bdcb7-dbnxn                        1/1     Running   6 (4m30s ago)   22m
kubeflow                    katib-mysql-5bc98798b4-2pwfb                             1/1     Running   1 (6m9s ago)    22m
kubeflow                    katib-ui-6655964d9-ppvgj                                 1/1     Running   2 (5m22s ago)   22m
kubeflow                    kserve-controller-manager-0                              2/2     Running   2 (5m13s ago)   21m
kubeflow                    kserve-models-web-app-5c46784448-k6fpl                   2/2     Running   2 (6m10s ago)   22m
kubeflow                    kubeflow-pipelines-profile-controller-5d77dffc97-b2sgx   1/1     Running   1 (6m10s ago)   22m
kubeflow                    metacontroller-0                                         1/1     Running   2 (4m53s ago)   21m
kubeflow                    metadata-envoy-deployment-7654b98955-pt5cw               1/1     Running   1 (6m10s ago)   22m
kubeflow                    metadata-grpc-deployment-5c8599b99c-p5ftw                2/2     Running   8 (3m4s ago)    22m
kubeflow                    metadata-writer-75749894bd-xj9df                         2/2     Running   4 (93s ago)     22m
kubeflow                    minio-6d6d45469f-v8hxm                                   2/2     Running   2 (6m9s ago)    22m
kubeflow                    ml-pipeline-68cbb5f66f-sqjm2                             2/2     Running   5 (2m44s ago)   22m
kubeflow                    ml-pipeline-persistenceagent-656646f586-df4n4            2/2     Running   3 (2m58s ago)   22m
kubeflow                    ml-pipeline-scheduledworkflow-5fbdc8fdb9-769kx           2/2     Running   2 (6m9s ago)    22m
kubeflow                    ml-pipeline-ui-866dd8c85b-tbmx2                          2/2     Running   2 (6m9s ago)    22m
kubeflow                    ml-pipeline-viewer-crd-b9bf4686d-2bppl                   2/2     Running   3 (3m12s ago)   22m
kubeflow                    ml-pipeline-visualizationserver-7594c49bbf-x45w4         2/2     Running   0               22m
kubeflow                    mysql-55778745b6-rfdm6                                   2/2     Running   2 (6m9s ago)    22m
kubeflow                    notebook-controller-deployment-7644864cb7-4dsxt          2/2     Running   4 (2m53s ago)   22m
kubeflow                    profiles-deployment-849d679569-ggghz                     3/3     Running   4 (2m39s ago)   22m
kubeflow                    tensorboard-controller-deployment-59f654f945-qhb8b       3/3     Running   3 (3m15s ago)   21m
kubeflow                    tensorboards-web-app-deployment-6dd998cb85-9ctwc         1/1     Running   1 (6m9s ago)    22m
kubeflow                    training-operator-748d5cdc48-lgnks                       1/1     Running   2 (4m47s ago)   21m
kubeflow                    volumes-web-app-deployment-759df896c6-dqgtx              1/1     Running   1 (6m9s ago)    21m
kubeflow                    workflow-controller-78c979dc75-96d64                     2/2     Running   8 (3m45s ago)   21m
local-path-storage          local-path-provisioner-9cd9bd544-8mhgp                   1/1     Running   2 (5m14s ago)   24m
~~~

kustomize를 이용하여 Kubeflow를 설치한다.

### 6. Kubeflow Dashboard 접근

~~~console
# kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
~~~

kubectl port-forward를 실행하고 아래의 경로에 접근한다.

* http://127.0.0.1:8080
* ID : user@example.com
* Password : 12341234

### 7. 참고

* kind : [https://kind.sigs.k8s.io/docs/user/quick-start/](https://kind.sigs.k8s.io/docs/user/quick-start/)
* Kubeflow : [https://github.com/kubeflow/manifests#installation](https://github.com/kubeflow/manifests#installation)
