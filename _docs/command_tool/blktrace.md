---
title: blktrace
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

Block Device Operation을 추적하는 blktrace 사용법을 정리한다.

### 1. blktrace

* `blktrace -d [Device] -o - | blkparse -i - -o [Result]` : [Device]의 Block Operation을 [Result] 파일에 기록한다.