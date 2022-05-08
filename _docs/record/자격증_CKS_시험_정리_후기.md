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
  * CKA, CKAD와 다르게 Kubernetes외의 별도의 Tool도 이용하기 때문에 위의 Site들을 Bookmark에 미리 등록하는것이 좋음
  * 나머지 Site 참고 불가능

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

* Windows Copy
  * ctrl + insert
* Windows Paste
  * shift + insert
* kubectl
  * Resoruce API Version 확인 : kubectl api-resources
  * Resource Spec/Status 확인 : kubectl explain --recursive {resource}
* AppArmor
  * Profile 적용 : apparmor_parser {profile_path}
  * Profile 확인 : aa-status | grep {profile_name}
* kubesec
  * Resource 검사 : kubesec scan {resource}
* Trivy
  * Image 검사 : trivy image --severity {UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL} {image_name}
  * Tar Image 검사 : trivy image --severity {UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL} --input {image_tar}
* Falco
  * Falco 시작 : systemctl start falco
  * Falco Config 설정 변경 : vim /etc/falco/falco.yaml
  * Falco Config 설정 변경 적용 : systemctl restart falco
  * Falco Rule 추가/변경 : vim /etc/falco/falco_rules.local.yaml

### 5. 시험 후기

* Kode Cloud에서 개념 이해와 함께 실습 2~3회 반복 필수
  * https://kodekloud.com/courses/certified-kubernetes-security-specialist-cks/
* CKS 시험 신청시 제공되는 Killer CKS 문제 반복 필수
  * https://killer.sh/
* CKA, CKAD에 비해서 난이도가 높으며 실습을 충분히 수행할 것을 권장

### 6. 참고

* [https://docs.linuxfoundation.org/tc-docs/certification/important-instructions-cks](https://docs.linuxfoundation.org/tc-docs/certification/important-instructions-cks)
* [https://velog.io/@jay-side-project/Kubernetes-CKS-%EC%A4%80%EB%B9%84%EA%B3%BC%EC%A0%95-0-CKS-%EC%A4%80%EB%B9%84%EA%B3%BC%EC%A0%95%EC%9D%84-%EC%A4%80%EB%B9%84%ED%95%98%EA%B8%B0](https://velog.io/@jay-side-project/Kubernetes-CKS-%EC%A4%80%EB%B9%84%EA%B3%BC%EC%A0%95-0-CKS-%EC%A4%80%EB%B9%84%EA%B3%BC%EC%A0%95%EC%9D%84-%EC%A4%80%EB%B9%84%ED%95%98%EA%B8%B0))
* [https://lifeoncloud.kr/k8s/killersh/](https://lifeoncloud.kr/k8s/killersh/)
