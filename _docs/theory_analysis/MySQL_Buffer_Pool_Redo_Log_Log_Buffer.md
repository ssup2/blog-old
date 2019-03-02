---
title: MySQL Buffer Pool, Redo Log, Log Buffer
category: Theory, Analysis
date: 2019-01-14T12:00:00Z
lastmod: 2019-01-14T12:00:00Z
comment: true
adsense: true
---

MySQL의 Buffer Pool, Redo Log 및 Log Buffer를 분석한다.

### 1. Buffer Pool, Redo Log, Log Buffer

![]({{site.baseurl}}/images/theory_analysis/MySQL_Buffer_Pool_Redo_Log_Log_Buffer/Buffer_Pool_Redo_Log_Log_Buffer.PNG){: width="500px"}

위의 그림은 Transaction을 처리하는 Buffer Pool, Redo Log, Log Buffer을 나타내고 있다. **Buffer Pool**은 MySQL의 DB Engine인 InnoDB가 Table Caching 및 Index Data Caching을 위해 이용하는 Memory 공간이다. Buffer Pool 크기가 클수록 상대적으로 Disk에 접근하는 횟수가 줄어들기 때문에 DB의 성능이 향상된다. Buffer Pool은 Memory 공간이기 때문에 MySQL에 장애가 발생하면 Buffer Pool 내용은 사라지고 Transaction의 유실로 이어질 수 있다. 이러한 유실을 방지하기 위해서 사용되는 File이 **Redo Log**이다. Redo Log는 Transaction 내용을 기록하고 있다가 MySQL 장애발생시 Redo Log에 기록된 Transaction 내용을 바탕으로 MySQL을 장애가 발생하기 이전 시점으로 **Recovery**한다.

InnoDB는 Transaction 내용은 계속 Buffer Pool과 Redo Log에 쌓지 않고, 주기적으로 또는 Redo Log가 가득차면 Buffer Pool에 기록된 Transaction 내용을 실제 Disk에 반영한다. 이러한 동작을 **Checkpoint**라고 한다. Redo Log는 2개의 파일을 번갈아가며 이용한다. Redo Log가 가득차면 가득찬 Redo Log는 놔두고 이용하지 않고 있던 Redo Log에 Transaction 내용을 기록한다. 가득찬 Redo Log는 Checkpoint 동작을 수행하고 비워진다.

Redo Log도 File이기 때문에 Transaction을 처리할때 마다 바로 Redo Log에 직접 Transaction 내용을 쓴다면 잦은 Disk 접근으로 인한 성능저하가 발생할 수 있다. InnoDB는 이러한 문제는 해결하기 위해서 Redo Log의 Cache 역활을 수행하는 **Log Buffer**에 Transaction 내용을 기록하고 한꺼번에 Redo Log에 기록한다. Log Buffer에 있는 Transaction 내용은 InnoDB의 Write 동작으로 인해서 OS의 Disk Cache로 전달되고 Inno DB의 Flush 동작으로 인해서 Redo Log 파일에 저장된다. InnoDB의 Write 및 Flush 동작은 InnoDB의 설정에 따라 수행되는 시점이 달라진다.

### 2. Configuration

MySQL의 Buffer Pool 및 Log Buffer과 연관된 Configuration을 분석한다.

#### 2.1. innodb_buffer_pool_size

innodb_buffer_pool_size는 Buffer Pool의 크기를 설정한다. 기본값은 128MB이다. 일반적으로 Buffer Pool Size가 클 수록 Disk에 접근하는 횟수가 줄어들기 때문에 DB의 성능이 좋아진다. 하지만 Server Memory 용량에 맞지 않게 너무 큰 값을 설정하면 잦은 Page Swap으로 인하여 오히려 성능이 저하된다. 따라서 적절한 값으로 설정해야 한다. Server에 MySQL만 구동되는 상태라면 Server Memory 크기의 80%를 설정하는 것을 추천한다.

#### 2.2. innodb_log_file_size

innodb_log_file_size는 Redo Log의 크기를 설정한다. 위에서 설명한 것처럼 InnoDB는 주기적으로 또는 Redo Log이 가득찰 경우 Buffer Pool에 기록된 Data 변경 내용을 실제 Disk에 반영하는 Checkpoint 동작을 수행한다. Buffer Pool의 크기가 아무리 크더라도 Redo Log의 크기가 작다면 자주 Check Point가 발생하기 때문에 Buffer Pool를 제대로 이용 할 수 없게 된다. 따라서 Buffer Pool 크기 변경시 Redo Log의 크기도 같이 변경해야 한다. 일반적으로 Buffer Pool Size (innodb_buffer_pool_size)값의 반으로 설정한다.

#### 2.3. innodb_log_buffer_size

innodb_log_buffer_size는 Log Buffer의 크기를 설정한다. innodb_log_buffer_size은 Redo Log Buffer Memory의 크기를 나타낸다. 한번의 Transaction내에서 많은 Data 변경이 발생하는 경우 Redo Log Buffer Memory의 크기를 늘려 Redo Log가 가득차지 않도록 만드는 것이 좋다. 일반적으로 1MB ~ 8MB 사이의 크기로 설정한다.

#### 2.4. innodb_flush_log_at_trx_commit

![]({{site.baseurl}}/images/theory_analysis/MySQL_Buffer_Pool_Redo_Log_Log_Buffer/Flush_Log_Buffer.PNG)

InnoDB가 Log Buffer의 내용을 Redo Log에 Write 및 Flush 동작을 언제 수행할지 설정한다. 현재 MySQL에서는 0,1,2 3개의 Option만을 제공한다. Default 값은 1로 설정되어 있다. 위의 그림은 Option에 따른 Write, Flush 동작이 언제 수행되는지를 나타내고 있다.

* Option 0 - InnoDB는 Redo Log에 Write 및 Flush 동작을 Commit과 관계없이 1초 간격으로 수행한다. Commit 명령으로 Transaction이 끝나도 Data 변경 내용은 최대 1초동안 Redo Log Buffer에만 반영 되어 있고, Redo Log에 반영되지 않을 수 있다. 따라서 0 Option 이용시 MySQL에 장애 및 MySQL이 동작하는 Node에 장애가 발생 할 경우, 장애 발생전 1초 동안의 Transaction 내용은 유실된다.

* Option 1 - InnoDB는 Redo Log에 Write 및 Flush 동작을 Commit 명령이 수행될 때마다 같이 수행한다. 잦은 Write 및 Flush 동작으로 Disk 접근 횟수가 많아 성능이 느려지지만, 완료된 Transaction은 어떠한 장애가 발생하여도 유실되지 않는다.

* Option 2 - InnoDB는 Redo Log에 Write 동작은 Commit 명령이 수행될 때마다 같이 수행하지만, Flush 동작은 1초 간격으로 수행한다. Option 0과 Option 1의 중간 형태의 동작을 수행한다. 단순히 MySQL에만 장애가 발생하였다면 OS Cache에 저장된 Transaction 내용은 Redo Log에 반영될 확률이 높다. 하지만 MySQL이 동작하는 Node에 장애가 발생하였을 경우, Node 장애 발생전 1초 동안의 Transaction 내용은 유실된다.

### 3. 참조

* Buffer Pool - [http://actimem.com/mysql/innodb/attachment/innodb-2/](http://actimem.com/mysql/innodb/attachment/innodb-2/)
* Redo Log - [http://majesty76.tistory.com/62](http://majesty76.tistory.com/62)
* Redo Log - [http://intomysql.blogspot.com/2010/12/redo-log.html](http://intomysql.blogspot.com/2010/12/redo-log.html)
* Configuration - [https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html)
