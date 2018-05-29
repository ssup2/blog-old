---
title: Two-Phase Commit
category: Theory, Analysis
date: 2017-04-03T12:00:00Z
lastmod: 2017-04-03T12:00:00Z
comment: true
adsense: true
---

Two-Phase Commit (2PC)를 분석한다.

### 1. Two-Phase Commit (2PC)

![]({{site.baseurl}}/images/theory_analysis/Two-Phase_Commit/Two-Phase_Commit.PNG){: width="400px"}

Two-Phase Commit은 분산 시스템 환경에서 여러 Node에서 수행해야하는 일을 하나의 Transaction으로 묶기 위해 사용하는 기법이다. 위의 그림은 Two-Phase Commit 과정을 나타내고 있다. 일반 Commit 과정에 비해 **Prepare Phase**가 추가적으로 존재하기 때문에 Two-Phase라는 이름이 붙었다.

Transaction Coordinatior는 Transaction을 수행해야 하는 모든 Node()들에게 Prepare 명령을 전달한다. 여기서 Prepare의 의미는 Commit 요청이 오면 Commit을 수행할 수 있는 상태를 의미한다. Transaction Coordinator는 모든 Node에게 Prepared Ack를 받으면 다시 모든 Node에게 Commit 요청을 보내어 각 Node에서 Commit 동작을 수행하도록 한다. Transaction Coordinator는 모든 Node로 부터 Done Ack를 받으면 Transaction을 종료한다.

만약 Prepare Phase에서 Transaction Coordinator가 특정 Node로부터 Prepared Ack를 받지 못하면, Transaction Coordinator는 모든 Node에게 Abort 명령을 전달한다. Abort 명령을 전달받은 Node들은 Prepared 상태에서 벗어나 원래의 상태로 Rollback된다.

만약 Commit Phase에서 Transaction Coordinator가 특정 Node로부터 Done Ack를 받지 못하면, Transaction Coordinator는 Done Ack를 받은 Node는 그대로 놔두고 Done Ack를 받지 못한 Node에게는 여러번 Commit 명령을 전달한다. 여러번의 Commit 명령을 전달한 후에도 Done Ack를 받지 못하면 Transaction은 종료되지 않은채로 남아있게 된다. DB 관리자가 해당 Node에서 직접 Commit을 수행하고 Transaction을 종료하여 정상화 시켜야 한다. 이처럼 Two-Phase Commit 기법은 완전한 Transaction을 보장하지 못한다.

### 2. 참조

* [http://swdev.tistory.com/2](http://swdev.tistory.com/2)
* [https://stackoverflow.com/questions/7389382/two-phase-commit](https://stackoverflow.com/questions/7389382/two-phase-commit)
