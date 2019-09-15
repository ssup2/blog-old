---
title: journalctl
category: Command, Tool
date: 2019-07-22T12:00:00Z
lastmod: 2019-07-22T12:00:00Z
comment: true
adsense: true
---

systemd-journald를 제어하는 journalctl의 사용법을 정리한다.

### 1. journalctl

* `journalctl -xu [Service]` : [Service] Log의 첫번째 부분을 출력한다. 진입이후 vim 명령어로 Log를 이동한다.
* `journalctl -xeu [Service]` : [Service] Log의 마지막 부분을 출력한다. 진입이후 vim 명령어로 Log를 이동한다.
* `journalctl -fu [Service]` : [Service] Log의 마지막 부분을 출력하고 추가되는 Log를 계속 출력한다.
