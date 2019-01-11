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

* innodb_buffer_pool_size - InnoDB가 Table과 Index Data Caching을 위해 이용하는 Memory의 크기를 나타낸다. 기본값은 128MB이다. 일반적으로 Pool Size가 클 수록 Disk에 접근하는 횟수가 줄어들기 때문에 DB의 성능이 좋아진다. 하지만 Server Memory 용량에 맞지 않게 너무 큰 값을 설정하면 잦은 Page Swap으로 인하여 오히려 성능이 저하된다. 따라서 적절한 값으로 설정해야 한다. Server에 MySQL만 구동되는 상태라면 Server Memory 크기의 80%를 설정하는 것을 추천한다.

* innodb_log_file_size - 

* innodb_log_buffer_size - 

* innodb_autoinc_lock_mode - 

* innodb_flush_log_at_trx_commit - 

* max_connections - 

### 2. 참조

* [https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html)
