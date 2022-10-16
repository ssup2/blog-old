---
title: Machine Learning Workflow
category: Theory, Analysis
date: 2022-10-14T12:00:00Z
lastmod: 2022-10-14T12:00:00Z
comment: true
adsense: true
---

Machine Learning Workflow을 정리한다.

### 1. Machine Learning Workflow

![[그림 1] Machine Learning Workflow]({{site.baseurl}}/images/theory_analysis/Machine_Learning_Workflow/Machine_Learning_Workflow.PNG){: width="650px"}

#### 1.1. Data Preparation

Data Preparation 과정은 Model 학습 및 검증을 위한 Data를 준비하는 과정을 나타낸다.

* Data Tranforamtion : Data를 가공하기 편리한 형태로 변형하고, 변형한 Data를 다시 적재하는 과정을 의미한다.
* Data Cleaning : 학습, 검증, Test에 불필요한 Data를 제거한다.
* Data Normalization : 일부 Data의 편차가 너무 큰 경우에 편차를 0~1 사이의 값으로 변환하여, 특정 Data로 인해서 다른 Data의 특성이 학습에 제대로 반영되지 않도록 도와주는 과정을 의미한다.
* Data Featurization : Data로부터 Model에 이용할 Feature를 추출하는 작업을 의미한다. 특정 Data를 Feature로 그대로 이용하는 경우가 많고, Data에 존재하지 않지만 Data를 기반으로 새로운 Feature를 생성하는 과정도 포함한다.
* Data Validation : Data 이용전 최종 검증 단계를 의미한다.
* Data Split : 검증된 Data를 학습, 검증, Test를 위해서 분류하는 단계를 의미한다. 일반적으로 학습 Data는 60%, 검증 Data는 20%, Test Data는 20%로 분류한다.

#### 1.2. Model Training

Model Training 과정은 준비된 Data를 가지고 Model을 생성, 학습, 검증하는 과정을 의미한다.

* Algorithm Selection : 어떠한 Machine Learning Algorithm을 이용할지 선택하는 과정을 의미한다.
* Model Hyperparameter Tuning : 선택한 Algorithm을 바탕으로 Model을 구성하고, 구성한 Model의 Hyperparameter를 어떻게 설정할지 결정한다.
* Model Training : 구성한 Model을 학습하여 Model의 Parameter를 결정한다. 학습은 Data Split 과정을 통해서 분류한 학습 Data를 이용한다.
* Model Validation : 학습된 Model을 검증한다. 검증을 통해서 Model의 정확도, 성능등의 Model 지표를 검토하고 요구 조건에 충족되는지 판단한다. 검증은 Data Split 과정을 통해서 분류한 검증 Data를 이용한다.
* Model Testing : 학습, 검증에 이용되지 않은 Data를 활용하여 검증된 Model이 실제 어떻게 동작할지를 Test를 수행하는 과정을 의미한다. Data Split 과정을 통해서 분류된 Test Data를 이용한다.

#### 1.3. Model Deployment

Test가 완료된 Model을 배포하고 모니터링하는 과정을 의미한다.

* Model Deployment : Test가 완료된 Model을 실제로 배포하는 과정을 의미한다.
* Model Monitoring : 배포된 Model의 정확도, 성능 등의 Model 지표를 Monitoring 하는 과정을 의미한다.
* Model Retraining : Monitoring을 통해서 얻은 Model 지표를 바탕으로 필요에 따라서 다시 학습하는 과정을 의미한다.

### 2. 참고

* [https://github.com/solliancenet/Azure-Machine-Learning-Dev-Guide/blob/master/creating-machine-learning-pipelines/machine-learning-pipelines.md](https://github.com/solliancenet/Azure-Machine-Learning-Dev-Guide/blob/master/creating-machine-learning-pipelines/machine-learning-pipelines.md)
* [https://web2.qatar.cmu.edu/~gdicaro/15488/lectures/488-S20-1-Introduction.pdf](https://web2.qatar.cmu.edu/~gdicaro/15488/lectures/488-S20-1-Introduction.pdf)
* [https://lsjsj92.tistory.com/579](https://lsjsj92.tistory.com/579)
* [https://www.kdnuggets.com/2020/07/tour-end-to-end-machine-learning-platforms.html](https://www.kdnuggets.com/2020/07/tour-end-to-end-machine-learning-platforms.html)
* [https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning)
* [https://towardsdatascience.com/machine-learning-pipelines-with-kubeflow-4c59ad05522](https://towardsdatascience.com/machine-learning-pipelines-with-kubeflow-4c59ad05522)
* [http://blog.skby.net/%EB%A8%B8%EC%8B%A0%EB%9F%AC%EB%8B%9D-%ED%8C%8C%EC%9D%B4%ED%94%84%EB%9D%BC%EC%9D%B8-machine-learning-pipeline/](http://blog.skby.net/%EB%A8%B8%EC%8B%A0%EB%9F%AC%EB%8B%9D-%ED%8C%8C%EC%9D%B4%ED%94%84%EB%9D%BC%EC%9D%B8-machine-learning-pipeline/)
* [https://towardsdatascience.com/industrializing-ai-machine-learning-applications-with-kubeflow-5687bf56153f](https://towardsdatascience.com/industrializing-ai-machine-learning-applications-with-kubeflow-5687bf56153f)
* Data Valdiation, Data Cleaning : [https://stackoverflow.com/questions/71044465/what-is-the-difference-between-data-validation-and-data-cleaning-and-what-areth](https://stackoverflow.com/questions/71044465/what-is-the-difference-between-data-validation-and-data-cleaning-and-what-areth)
* Data Feature Engineering : [http://www.incodom.kr/%EA%B8%B0%EA%B3%84%ED%95%99%EC%8A%B5/feature_engineering](http://www.incodom.kr/%EA%B8%B0%EA%B3%84%ED%95%99%EC%8A%B5/feature_engineering)
* Machine Learning Algorithm, Model : [https://www.linkedin.com/pulse/difference-between-algorithm-model-machine-learning-yahya-abi-haidar/](https://www.linkedin.com/pulse/difference-between-algorithm-model-machine-learning-yahya-abi-haidar/)
* Model Validation, Model Testing : [https://stats.stackexchange.com/questions/19048/what-is-the-difference-between-test-set-and-validation-set](https://stats.stackexchange.com/questions/19048/what-is-the-difference-between-test-set-and-validation-set)
* Model Hyper-parameter : [https://medium.com/@f2005636/evaluating-machine-learning-models-hyper-parameter-tuning-2d7076349a6c](https://medium.com/@f2005636/evaluating-machine-learning-models-hyper-parameter-tuning-2d7076349a6c)
* Model Parameter, Model Hyper-parameter : [https://machinelearningmastery.com/difference-between-a-parameter-and-a-hyperparameter/](https://machinelearningmastery.com/difference-between-a-parameter-and-a-hyperparameter/)
