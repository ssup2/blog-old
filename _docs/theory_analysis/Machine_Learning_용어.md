---
title: Machine Learning Term
category: Theory, Analysis
date: 2022-10-15T12:00:00Z
lastmod: 2022-10-15T12:00:00Z
comment: true
adsense: true
---

Machine Learning 관련 용어들을 간략하게 정리한다.

### 1. Machine Learning Term

* Model : Training(학습)을 통해서 예측을 수행하는 함수를 의미한다.
* Feature : Data를 기반으로 추출한 Model의 입력값을 의미한다.
* Feature Engineering : Model의 가장 적합한 Input Variable 집합을 찾는 과정이다. 기존의 Feature들을 기반으로 새로운 Feature를 추출하고, 추가하는 과정도 Feature Engineering의 과정에 포함된다.
* Parameter : Model Training을 통해서 설정되는 Model 내부의 값들을 의미한다.
* Hyperparameter : Data에 기반하지 않고 Model 개발자가 별도로 설정하는 Model의 입력값을 의미한다.
* Data Acquisition : Training을 위한 Data 수집 과정을 의미한다.
* Target Variables : Model을 이용하여 예측하려는 실제값을 의미한다.
* Error Function : Model을 이용하여 얻은 예측값과 실제값의 차이를 반환하는 함수를 의미한다.
* Training Data : Training을 위한 Data를 의미한다. 일반적으로 전체 Data의 60% 정도를 Training Data로 분류하고 이용한다.
* Validation Data : Training이 완료된 Model을 검증을 위한 Data를 의미힌다. 검증의 의미는 Model의 정확도 및 성능을 평가하는 단계를 의미한다. 일반적으로 전체 Data의 20% 정도를 Validation Data로 분류하고 이용한다.
* Test Data : 검증이 완료된 Model의 성능 및 정확도 Test를 위한 Data를 의미한다. 일반적으로 전체 Data의 20% 정도를 Test Data로 분류하고 이용한다.
* Linear Regression : 연속적인 값중에서 하나의 값을 예측하는 과정을 의미한다. 
* Logistic Regression : Linear Regression을 통해 얻은 예측값을 Sigmoid 함수를 통해서 0~1의 사이값으로 변환하는 기법을 의미한다.
* Neural Network : 사람의 뇌 구조를 모방하여 만든 Network를 의미한다. 일반적으로 Input Layer, Output Layer 그리고 Input Layer, Output Layer 사이에 존재하는 Hidden Layer로 구성되어 있으며, 각 Layer의 Node들은 Neural을 의미한다.
* Deep Learning : Neural Network를 활용한 Machine Learning 기법을 의미한다.
* Decision Tree : Node는 조건을 의미하며 Leaf는 의사 결정으로 구성되는 Tree. 일반적으로 지도학습의 분류, 회귀용도로 이용되며, Training을 통해서 Decision Tree를 구성한다.

### 2. 참고

* Feature Engineering, Hyperparameter Tuning : [https://stats.stackexchange.com/questions/448757/difference-between-feature-engineering-and-hyperparameter-optimizations](https://stats.stackexchange.com/questions/448757/difference-between-feature-engineering-and-hyperparameter-optimizations)
* Model Validation, Model Testing : [https://stats.stackexchange.com/questions/19048/what-is-the-difference-between-test-set-and-validation-set](https://stats.stackexchange.com/questions/19048/what-is-the-difference-between-test-set-and-validation-set)
