---
title: AWS EKS Storage
category: Theory, Analysis
date: 2021-04-23T12:00:00Z
lastmod: 2021-04-23T12:00:00Z
comment: true
adsense: true
---

AWS EKS Storage를 분석한다.

### 1. AWS EKS Storage

AWS EKS에서는 EBS (Elastic Block Storage), EFS (Elastic File Storage), FSx 기반의 다양한 Storage Class를 제공한다.

#### 1.1. Default Storage Class

{% highlight console %}
# kubectl get sc
NAME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2 (default)   kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  3d1h
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] AWS EKS Storage Class</figcaption>
</figure>

EKS로 Kubernetes Cluster를 구성하면 Default Storage Class로 EBS의 gp2가 설정되어 있다. [Console 1]은 gp2가 설정된 Storage Class를 나타내고 있다.

{% highlight console %}
# ps -ef | grep kubelet
root      3801     1  1 Apr06 ?        06:09:14 /usr/bin/kubelet --node-ip=192.168.75.136 --node-labels=alpha.eksctl.io/cluster-name=ssup2-eks-cluster,alpha.eksctl.io/nodegroup-name=nodegroup-1,node-lifecycle=on-demand,alpha.eksctl.io/instance-id=i-0b923780d29147e03 --max-pods=17 --register-node=true --register-with-taints= --cloud-provider=aws --container-runtime=docker --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-conf-dir=/etc/cni/net.d --pod-infra-container-image=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/eks/pause:3.3-eksbuild.1 --kubeconfig=/etc/eksctl/kubeconfig.yaml --config=/etc/eksctl/kubelet.yaml
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] AWS EKS kubelet</figcaption>
</figure>

EKS Node에 SSH로 접근하여 kubelet의 Parameter를 확인하면 cloud-provider Option이 설정되어 있는것을 확인할 수 있다. [Console 2]는 kubelet의 Parameter를 나타내고 있다. "aws"로 Cloud Provider가 설정되어 있는것을 확인할 수 있다.

{% highlight console %}
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:32.183634    3801 topology_manager.go:233] [topologymanager] Topology Admit Handler
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:32.336844    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:32.336896    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "default-token-7m864" (UniqueName: "kubernetes.io/secret/6681c826-f599-4549-b2e1-707c69c26837-default-token-7m864") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: E0409 15:55:32.337007    3801 nestedpendingoperations.go:301] Operation for "{volumeName:kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89 podName: nodeName:}" failed. No retries permitted until 2021-04-09 15:55:32.836974851 +0000 UTC m=+263922.787528156 (durationBeforeRetry 500ms). Error: "Volume has not been added to the list of VolumesInUse in the node's volume status for volume \"pvc-1b5dd043-40fc-4924-b1af-03bfa9630751\" (UniqueName: \"kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89\") pod \"web-1\" (UID: \"6681c826-f599-4549-b2e1-707c69c26837\") "
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:32.841678    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: E0409 15:55:32.841780    3801 nestedpendingoperations.go:301] Operation for "{volumeName:kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89 podName: nodeName:}" failed. No retries permitted until 2021-04-09 15:55:33.841752915 +0000 UTC m=+263923.792306216 (durationBeforeRetry 1s). Error: "Volume has not been added to the list of VolumesInUse in the node's volume status for volume \"pvc-1b5dd043-40fc-4924-b1af-03bfa9630751\" (UniqueName: \"kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89\") pod \"web-1\" (UID: \"6681c826-f599-4549-b2e1-707c69c26837\") "
Apr 09 15:55:33 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:33.844677    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:33 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: E0409 15:55:33.850478    3801 nestedpendingoperations.go:301] Operation for "{volumeName:kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89 podName: nodeName:}" failed. No retries permitted until 2021-04-09 15:55:35.850450415 +0000 UTC m=+263925.801003754 (durationBeforeRetry 2s). Error: "Volume not attached according to node status for volume \"pvc-1b5dd043-40fc-4924-b1af-03bfa9630751\" (UniqueName: \"kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89\") pod \"web-1\" (UID: \"6681c826-f599-4549-b2e1-707c69c26837\") "
Apr 09 15:55:34 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: {"level":"info","ts":"2021-04-09T15:55:34.244Z","caller":"/usr/local/go/src/runtime/proc.go:203","msg":"CNI Plugin version: v1.7.5 ..."}
Apr 09 15:55:35 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:35.949997    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:35 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:35.955735    3801 operation_generator.go:1332] Controller attach succeeded for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837") device path: "/dev/xvdbw"
Apr 09 15:55:36 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:36.050389    3801 operation_generator.go:558] MountVolume.WaitForAttach entering for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837") DevicePath "/dev/xvdbw"
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.050635    3801 attacher.go:189] Successfully found attached AWS Volume "aws://ap-northeast-2a/vol-0c6206285b4820d89" at path "/dev/xvdbw".
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.050689    3801 operation_generator.go:567] MountVolume.WaitForAttach succeeded for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837") DevicePath "/dev/xvdbw"
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.068352    3801 mount_linux.go:366] Disk "/dev/xvdbw" appears to be unformatted, attempting to format as type: "ext4" with options: [-F -m0 /dev/xvdbw]
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.286426    3801 mount_linux.go:376] Disk successfully formatted (mkfs): ext4 - /dev/xvdbw /var/lib/kubelet/plugins/kubernetes.io/aws-ebs/mounts/aws/ap-northeast-2a/vol-0c6206285b4820d89
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.447140    3801 operation_generator.go:596] MountVolume.MountDevice succeeded for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837") device mount path "/var/lib/kubelet/plugins/kubernetes.io/aws-ebs/mounts/aws/ap-northeast-2a/vol-0c6206285b4820d89"
Apr 09 15:55:38 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: W0409 15:55:38.128905    3801 pod_container_deletor.go:77] Container "d9165d9862d7d713871f40be45cf4f11224597a85edf68e893a6b3df36e313f9" not found in pod's containers
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] AWS EKS kubelet Volume Mount Log</figcaption>
</figure>

Default Storage Class를 이용할 경우 kubelet에서 Volume Format 및 Mount를 수행하게 된다. [Console 3]는 VM에 붙은 EBS gp2 Volume을 감지하고, ext4로 Format하고, Mount하는 과정의 kubelet Log를 나타낸다.

{% highlight console %}
# ls -l /dev/ | grep xvda
lrwxrwxrwx 1 root root           7 Apr  6 14:36 xvda -> nvme0n1
lrwxrwxrwx 1 root root           9 Apr  6 14:36 xvda1 -> nvme0n1p1
lrwxrwxrwx 1 root root          11 Apr  6 14:36 xvda128 -> nvme0n1p128
lrwxrwxrwx 1 root root           7 Apr  9 15:55 xvdbw -> nvme1n1
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 4] EBS Mount</figcaption>
</figure>

[Console 4]는 Node안에서 Node에 Attach된 EBS Volume이 어떻게 보이는지는 나타낸다. xvd[*]는 EBS Block Storage를 나타낸다.

#### 1.2. CSI (Container Storage Interface) Storage Class

최근 Kubernetes에서는 Volume 제어를 위해서 kube-controller-manager, kubelet 내부에 존재하는 Volume Controller가 아닌, 별도의 Volume Controller 역활을 수행하는 CSI Controller를 이용하는 것을 권장하고 있다. CSI Controller는 Kubernetes Component (kube-controller-manager, kubelet)와는 독립된 Controller이기 때문에, CSI Controller를 이용하면 Kubernetes Component Upgrade를 수행하더라도 기존과 동일한 Volume Controller를 이용할 수 있는 장점을 얻을 수 있다.

이에 맞추어 AWS EKS에서도 CSI Controller를 제공하고 있다. EBS CSI Storage Class를 제공하고 있으며 EFS, FSx를 이용하기 위해서는 반드시 CSI Controller를 이용해야 한다. Kubernetes 관점에서 EBS, EFS, FSx Stoage의 특징은 다음과 같다.

* EBS : EBS는 **ReadWriteOnce** Mode로 동작한다. EBS는 Pod가 동작하는 EC2 Instance에 Attach되며, Attach된 EBS는 CSI Controller에 의해서 Format 및 EC2 Instance 내부로 Mount된다. Mount된 EBS는 Pod에게 Bind Mount를 통해서 노출시킨다.
* EFS : EFS는 **ReadWriteMany** Mode로 동작한다. EFS는 NFSv4 Protocol을 통해서 EC2 Instance에 Mount되며, Mount된 EFS는 Pod에게 Bind Mount를 통해서 노출시킨다.
* EFx : EFx는 **ReadWriteMany** Mode로 동작한다. EFx는 EFS에 비해서 높은 성능이 특징이다.

### 2. 참조

* [https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html)
* [https://docs.aws.amazon.com/eks/latest/userguide/storage.html](https://docs.aws.amazon.com/eks/latest/userguide/storage.html)