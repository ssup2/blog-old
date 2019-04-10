---
title: MapReduce
category: Theory, Analysis
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

### 1. MapReduce

![[그림 1] MapReduce]({{site.baseurl}}/images/theory_analysis/MapReduce/MapReduce.PNG){: width="700px"}

MapReduce는 대용량의 Data를 분산 처리하는 기법이다. [그림 1]는 MapReduce 과정을 나타내고 있다. Hadoop에서 가장 먼져 지원하기 시작했으며 현재는 CouchDB, MongoDB 같은 Document Type의 NoSQL DB에서도 지원하고 있다. MapReduce는 크게 Splitting, Mapping, Shuffling, Reducing 4가지 과정으로 진행된다.

* Spliiting - Splitting은 Input File을 분리한 뒤 분리된 Input File을 각 Node에게 전달하는 과정이다. Splitting 과정을 통해 Input File은 K1, V1 Key-Value 관계로 분리된다. [그림 1]에서 Key는 File의 Line이고 Value은 Line의 String이 된다. MapReduce Framework에서 Input File 분리를 담당하는 Class가 InputFormat Class이다. 개발자는 기본 InputFormat Class인 TextInputFormat, KeyValueInputFormat Class를 이용하거나 직접 InputFormat Class를 개발하여 Input File을 어떻게 분리할지 결정 할 수 있다.

* Mapping - Mapping은 분리된 Input File을 필요에 따라 List(K2, V2) Key-Value로 Mapping하는 과정이다. MapReduce Framework는 분리된 Input File의 개수만큼 YARN의 Container를 생성하고, 각 Container안에서 Mapping 작업을 병렬적으로 수행한다. 따라서 YARN Cluster를 구성하는 Node가 많아 질 수록 대용량 Data를 빠르게 처리 할 수 있다. MapReduce Framework는 Mapping을 담당하는 Mapper Class를 개발자에게 제공하여 개발자가 쉽게 Mapping을 수행 할 수 있도록 도와준다.

* Shuffling - Shuffling은 Mapping 결과물을 Reducing 수행하는 Node에게 전달하는 과정이다. Shuffling 과정을 통해 Mapping 과정에서 이용했던 Key(K2)를 기준으로 Value들이 특정 Node로 모이게 된다.

* Reducing - Reducing은 Mapping 결과물들을 합치는 과정이다. MapReduce Framework는 Reducing을 담당하는 Reducer Class를 개발자에게 제공하여 개발자가 쉽게 Reducing을 수행 할 수 있도록 한다.

### 2. 참조

* [https://data-flair.training/blogs/hadoop-inputformat/](https://data-flair.training/blogs/hadoop-inputformat/)
* [http://icecello.tistory.com/35](http://icecello.tistory.com/35)
