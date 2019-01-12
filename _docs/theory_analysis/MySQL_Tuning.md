---
title: MySQL Tuning
category: Theory, Analysis
date: 2019-01-14T12:00:00Z
lastmod: 2019-01-14T12:00:00Z
comment: true
adsense: true
---

MySQL Tuning 기법을 정리한다.

### 1. Configuration

#### 1.1. innodb_buffer_pool_size

InnoDB가 Table과 Index Data Caching을 위해 이용하는 Memory 공간인 **Buffer Pool**의 크기를 나타낸다. 기본값은 128MB이다. 일반적으로 Buffer Pool Size가 클 수록 Disk에 접근하는 횟수가 줄어들기 때문에 DB의 성능이 좋아진다. 하지만 Server Memory 용량에 맞지 않게 너무 큰 값을 설정하면 잦은 Page Swap으로 인하여 오히려 성능이 저하된다. 따라서 적절한 값으로 설정해야 한다. Server에 MySQL만 구동되는 상태라면 Server Memory 크기의 80%를 설정하는 것을 추천한다.

#### 1.2. innodb_log_file_size

**Redo Log File**의 크기를 나타낸다. InnoDB는 Client으로부터 Data 변경 요청을 받으면 Disk 접근으로 발생하는 Overhead를 줄이기 위해 Data 변경 내용을 Buffer Pool 및 Redo Log File에만 기록하고 실제 Disk에 바로 기록하지 않는다. InnoDB는 주기적으로 또는 Redo Log File이 가득찰 경우 Buffer Pool에 기록된 Data 변경 내용을 실제 Disk에 반영한다. 이러한 동작을 **Check Point**라고 한다.

Buffer Pool의 크기가 아무리 크더라도 Redo Log File의 크기가 작다면 자주 Check Point가 발생하기 때문에 Buffer Pool를 제대로 이용 할 수 없게 된다. 따라서 Buffer Pool 크기 변경시 Redo Log File의 크기도 같이 변경해야 한다. 일반적으로 Buffer Pool Size (innodb_buffer_pool_size)값의 반으로 설정한다.

#### 1.3. innodb_log_buffer_size

innodb_log_file_size 설명에서 InnoDB는 Client으로부터 Data 변경 요청을 받으면 Data 변경 내용을 Redo Log File에 기록한다고 설명하였는데, 실제로는 Disk 접근으로 발생하는 Overhead를 줄이기 위해서 Redo Log File에 직접 기록하지 않고 **Redo Log Buffer**라고 불리는 Memory 공간에만 기록하였다가 한번에 Redo Log File에 기록한다. innodb_log_buffer_size은 Redo Log Buffer Memory의 크기를 나타낸다. 한번의 Transaction내에서 많은 Data 변경이 발생하는 경우 Redo Log Buffer Memory의 크기를 늘려주는편이 좋다. 일반적으로 1MB ~ 8MB 사이의 크기로 설정한다.

#### 1.4. innodb_flush_log_at_trx_commit

Redo Log Buffer의 내용을 Redo Log File에 반영하는 정책을 결정한다. 현재 MySQL에서는 0,1,2 3개의 Option만을 제공한다. Default 값은 1로 설정되어 있다.

* 0 Option - Redo Log File에 Write 동작 및 OS가 관리하는 Disk Buffer의 Flush 동작을 1초 주기로 수행한다. Commit 명령으로 Transaction이 끝나도 Data 변경 내용은 최대 1초동안 Redo Log Buffer에만 반영 되어 있고, Redo Log File에 반영되지 않을 수 있다. 따라서 0 Option 이용시 MySQL의 장애나 MySQL이 동작하는 Node의 장애가 발생 할 경우, 장애 발생전 1초 동안의 Data 변경 내용이 유실 될 수 있다.

* 1 Option - Redo Log File에 Write 동작 및 Disk Buffer의 Flush 동작을 Commit 명령이 수행될 때마다 같이 수행한다. 잦은 Write 및 Flush 동작으로 Disk 접근 횟수가 많아 성능이 느려지지만, Transaction이 완료된 Data 변경 내용은 장애가 발생하여도 유실되지 않는다.

* 2 Option - Redo Log File에 Write 동작은 Commit 명령이 수행될 때마다 같이 수행하지만 Disk Buffer의 Flush 동작은 1초마다 수행한다. 0 Option과 1 Option의 중간 형태의 동작을 수행한다.

### 2. 참조

* Configuration - [https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html)
* Redo Log - [http://majesty76.tistory.com/62](http://majesty76.tistory.com/62)
* Redo Log - [http://intomysql.blogspot.com/2010/12/redo-log.html](http://intomysql.blogspot.com/2010/12/redo-log.html)
