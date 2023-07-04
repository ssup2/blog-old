---
title: Hadoop AWS S3 Filesystem
category: Theory, Analysis
date: 2023-06-23T12:00:00Z
lastmod: 2023-06-23T12:00:00Z
comment: true
adsense: true
---

Hadoop에서 이용 가능한 AWS S3 Filesystem을 정리한다.

### 1. Hadoop AWS S3 Filesystem

Hadoop에서는 이용시 Data 저장소로 HDFS 뿐만 아니라 AWS S3를 Data 저장소로 이용 가능하다. Data 저장 및 전송 방식에 따라서 S3, S3A, S3N 3가지 Type으로 구분된다.

#### 1.1. S3 (S3 Block Filesystem)

Hadoop에서 접근하는 File을 S3에 **Block 형태로 저장**하는 Filesystem이다. Hadoop App에서 "s3://"으로 시작하는 URL 이용시 S3 Type을 이용한다. S3의 Object를 Block Disk의 Block으로 Mapping하여 이용한다. 따라서 S3에 저장되는 Object는 다수의 File로 구성된 Block을 의미하며 File과 Object은 N:1 관계를 갖는다. Object는 다수의 File로 구성된 Block이기 때문에 File은 AWS Management Console이나 aws CLI를 통해서 접근할 수 없다.

#### 1.2. S3N (S3 Native Filesystem)

이름에서 추측할 수 있는것 처럼 Hadoop에서 접근하는 File을 S3의 하나의 Object로 저장하는 Filesystem이다. Hadoop App에서 "s3n://"으로 시작하는 URL 이용시 S3N Type을 이용한다. File과 Object는 1:1 관계를 갖는다. 따라서 AWS Management Console이나 aws CLI를 통해서도 File에 직접 접근할 수 있다. 하나의 File의 크기가 5GB 이상을 넘지 못하는 단점을 갖는다.

#### 1.3. S3A (S3 Advanced Filesystem)

S3N을 발전시킨 Filesystem이다. Hadoop App에서 "s3a://"으로 시작하는 URL 이용시 S3A Type을 이용한다. File과 Object는 S3N과 동일하게 1:1 관계를 갖지만, S3의 Multi-part Upload/Download 기능을 활용하기 때문에 하나의 File의 크기는 최대 5TB까지 지원하며 더 빠른 성능을 보여준다. Multi-part Upload/Download를 이용하기 위해서는 관련 기능을 수행하는 AWS Library가 Node에 포함되어야 한다.

S3A는 S3N과의 하위 호환성을 지원한다. 따라서 S3N을 이용하는 Hadoop Application은 S3A로 변경을 통해서 S3A로 손쉽게 이전할 수 있다. Hadoop 2.7 Version 이후부터는 S3N 대신 S3A 이용이 권장되며, Hadoop 3.0 Version 이후에는 S3A만 이용이 가능하다. 내부적으로 "S3A Commiter"를 이용한다.

### 2. EMRFS on EMR Cluster

AWS의 EMR Cluster에서는 EMRFS을 통해서 S3를 저장소로 이용 가능하다. EMR Cluster 내부의 App에서 "s3://", "s3a://" URL로 시작하는 File 접근시 EMRFS을 이용한다. 따라서 "s3://", "s3a://" 동일한 URL을 이용하여도 일반적인 Hadoop Cluster 또는 EMR Cluster인지에 따라서 내부 동작이 다르다. EMRFS의 경우에는 "s3a://" 보다 "s3://" 이용을 권장하고 있으며, "s3a://"을 지원하지 않는다. 내부적으로 "EMR S3-optimized Comitter"를 이용한다.

### 3. 참고

* S3, S3N, S3A 비교 : [https://www.quora.com/In-AWS-what-is-the-difference-between-S3N-S3A-and-S3](https://www.quora.com/In-AWS-what-is-the-difference-between-S3N-S3A-and-S3)
* S3, S3N, S3A 비교 : [https://stackoverflow.com/questions/33356041/technically-what-is-the-difference-between-s3n-s3a-and-s3](https://stackoverflow.com/questions/33356041/technically-what-is-the-difference-between-s3n-s3a-and-s3)
* S3, S3N, S3A 비교 : [https://vivani.net/2017/04/18/s3-vs-s3n-vs-s3a-vs-emrfs/](https://vivani.net/2017/04/18/s3-vs-s3n-vs-s3a-vs-emrfs/)
* S3, S3N, S3A 비교 : [https://spidyweb.tistory.com/475](https://spidyweb.tistory.com/475)
* S3A Contribution : [https://aws.amazon.com/ko/blogs/opensource/community-collaboration-the-s3a-story/](https://aws.amazon.com/ko/blogs/opensource/community-collaboration-the-s3a-story/)
* S3N Bucket File Write 예제 : [https://blog.voidmainvoid.net/229](https://blog.voidmainvoid.net/229)
* S3A Committer : [https://hadoop.apache.org/docs/r3.1.1/hadoop-aws/tools/hadoop-aws/committers.html](https://hadoop.apache.org/docs/r3.1.1/hadoop-aws/tools/hadoop-aws/committers.html)
* EMFFS S3-optimized Committer : [https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-spark-s3-optimized-committer.html](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-spark-s3-optimized-committer.html)