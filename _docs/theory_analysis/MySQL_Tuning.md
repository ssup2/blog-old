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

Redo Log File의 크기를 정한다. InnoDB는 성능을 위해 Data의 변경 내용을 Buffer Pool 및 Redo Log에만 기록하고 실제 Disk에 바로 기록하지 않는다. 그 후 InnoDB는 주기적으로 또는 Redo Log File이 가득찰 경우 가득 찬 Redo Log 파일을 새로운 Redo Log 파일로 교체하고, Buffer Pool에 기록된 Data 변경 내용을 실제 Disk에 반영한다. 이러한 동작을 **Check Point**라고 한다. Buffer Pool의 크기가 아무리 크더라도 Redo Log File의 크기가 작다면 자주 Check Point가 발생하기 때문에 Buffer Pool를 제대로 이용 할 수 없게 된다. 따라서 Buffer Pool 크기 변경시 Redo Log File의 크기도 같이 변경해야 한다. 일반적으로 Buffer Pool Size (innodb_buffer_pool_size)값의 반으로 설정한다.

#### 1.3. innodb_log_buffer_size

#### 1.4. innodb_autoinc_lock_mode

#### 1.5. innodb_flush_log_at_trx_commit

#### 1.6. max_connections

### 2. 참조

* Configuration - [https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html)
* Redo Log - [http://majesty76.tistory.com/62](http://majesty76.tistory.com/62)
