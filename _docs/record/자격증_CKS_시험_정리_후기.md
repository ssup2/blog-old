---
title: 자격증 CKS 시험 정리/후기
category: Record
date: 2022-04-26T12:00:00Z
lastmod: 2022-04-26T12:00:00Z
comment: true
adsense: true
---

### 1. 시험 정보

* 시간
  * 2시간 16문제

* 참고 가능한 Site
  * Kubernetes
    * https://kubernetes.io/docs/home/
    * https://github.com/kubernetes/
    * https://kubernetes.io/blog/
  * Trivy
    * https://aquasecurity.github.io/trivy/
  * Falco
    * https://falco.org/docs/
  * AppArmor
    * https://gitlab.com/apparmor/apparmor/-/wikis/Documentation
  * 나머지 Site 참고 불가능
  * CKA, CKAD와 다르게 Kubernetes외의 별도의 Tool도 이용하기 때문에 위의 Site들을 Bookmark에 미리 등록하는것이 좋음

* 시험 환경
  * Kuberntes v1.21

### 2. 시험 준비

* 시험 준비물
  * Chrome Browser
  * Chrome Plugin
    * https://chrome.google.com/webstore/detail/innovative-exams-screensh
  * Webcam
  * Microphone
  * 여권

* 시험 환경 Check
  * https://www.examslocal.com/ScheduleExam/Home/CompatibilityCheck

### 3. 시험전 확인

* kubectl bash autocompletion 동작 확인
  * https://kubernetes.io/docs/reference/kubectl/cheatsheet/
* tmux 동작 확인
  * https://linuxize.com/post/getting-started-with-tmux/

### 4. 시험중 알아야할 명렁어

* root 권한 획득
  * sudo -i
* Windows Copy
  * ctrl + insert
* Windows Paste
  * shift + insert

### 5. 시험 후기

* Kode Cloud에서 개념 이해와 함께 실습 2~3회 반복하면 합격 가능
  * https://kodekloud.com/courses/certified-kubernetes-security-specialist-cks/

### 6. 참고

* [https://docs.linuxfoundation.org/tc-docs/certification/important-instructions-cks](https://docs.linuxfoundation.org/tc-docs/certification/important-instructions-cks)
* [https://velog.io/@jay-side-project/Kubernetes-CKS-%EC%A4%80%EB%B9%84%EA%B3%BC%EC%A0%95-0-CKS-%EC%A4%80%EB%B9%84%EA%B3%BC%EC%A0%95%EC%9D%84-%EC%A4%80%EB%B9%84%ED%95%98%EA%B8%B0](https://velog.io/@jay-side-project/Kubernetes-CKS-%EC%A4%80%EB%B9%84%EA%B3%BC%EC%A0%95-0-CKS-%EC%A4%80%EB%B9%84%EA%B3%BC%EC%A0%95%EC%9D%84-%EC%A4%80%EB%B9%84%ED%95%98%EA%B8%B0))
* [https://lifeoncloud.kr/k8s/killersh/](https://lifeoncloud.kr/k8s/killersh/)
