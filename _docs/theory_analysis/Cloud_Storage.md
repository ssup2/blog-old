---
title: Cloud Storage
category: Theory, Analysis
date: 2017-01-24T12:00:00Z
lastmod: 2017-01-24T12:00:00Z
comment: true
adsense: true
---

Cloud 환경에서 이용하는 Storage를 Block Storage, Object Storage, File Storage로 분류하고 분석한다.

### 1. Block Storage

![]({{site.baseurl}}/images/theory_analysis/Cloud_Storage/Block_Storage.PNG){: width="350px"}

Block Storage는 Hard Disk 같은 **Block Device**를 제공하는 Storage이다. Block Storage의 Block들은 모두 **동일한 크기**를 가지고 있고, 각 Block들은 **Block Address**를 할당받는다. Block Storage는 Block Address를 기반으로 Block Read/Write 동작을 지원한다. Block Storage는 전체 Block 개수 같은 Block 관련 Meta 정보만 가지고 있다. Block Storage는 Block 관련 간단한 기능만 수행하기 때문에 가장 빠른 I/O 성능을 보여준다.

Kernel은 Block Storage를 Hard Disk같은 일반 Block Device로 인식한다. Linux에서는 /dev 폴더 아래 할당 받은 Block Storage를 볼 수 있다. DB같이 Block을 직접 관리하는 App은 Block Storage를 직접 이용 할 수 있다. 또한 Block Storage를 EXT4같은 Filesystem으로 Format 및 Mount하여 일반 App도 이용 할 수 있다.

### 2. Object Storage

![]({{site.baseurl}}/images/theory_analysis/Cloud_Storage/Object_Storage.PNG){: width="600px"}

Object Storage는 Object라는 단위로 정보를 관리한다. Object는 Object를 대표하는 고유의 **ID**, Object의 정보를 나타내는 **Meta**, 실제 정보가 저장되어 있는 **Data** 3가지로 구성되어 있다.

Object의 특징 중 하나는 **자유로운 Meta** 형태에 있다. 사용자는 Object Meta에 다양한 Meta 정보를 저장할 수 있다. Object Storage는 저장된 Object Meta를 바탕으로 다양한 동작(Object 검색, 정렬)을 수행 할 수 있다. 또한 Object Storage는 Object 사이의 계층을 두지 않고 Object ID를 Key로 이용한 **Key-Value 기반의 수평된** 저장 형태만을 제공한다. 이러한 형태는 Object Storage의 확장 및 Replication을 쉽게 만든다.

일반적으로 Object Storage는 REST API 형태로 조작한다. REST API를 통해 Key인 Object ID를 넘겨 주면 해당 Object의 정보를 얻어오고, 조작한다. Object Storage의 유연성과 REST API로 인한 접근성 때문에 일반적으로 Web App이나 Data Backup용으로 많이 이용된다.

### 3. File Storage

![]({{site.baseurl}}/images/theory_analysis/Cloud_Storage/File_Storage.PNG){: width="500px"}

File Storage는 **File System을 이용한 계층**기반 Storage이다. Directory를 통해 자유롭게 계층을 생성하고 File을 특정 Directory에 위치시키는 형태로 File들을 관리한다. File Storage는 각 File을 위해서 생성시간, 소유권 같은 File System에서 정의한 Meta 정보만을 저장한다.

File Storage는 mount 명령을 통해 연결 할 수 있다. 한번 연결되면 Local File 처럼 다양한 App들을 이용하여 복사, 변경이 가능하다. 이러한 특징 때문에 VM, Container 사이에서 File 공유시 이용되고 있다.

### 4. 참조

* [https://www.storagecraft.com/blog/storage-wars-file-block-object-storage](https://www.storagecraft.com/blog/storage-wars-file-block-object-storage/)
