---
title: Jekyll 설치, Build - Ubuntu 18.04
category: Record
date: 2019-04-01T12:00:00Z
lastmod: 2019-04-01T12:00:00Z
comment: true
adsense: true
---

### 1. Build 환경

* Ubuntu 18.04 LTS 64bit, root user

### 2. Ubuntu Package 설치

* Jeykll 구동에 필요한 Ubuntu Package를 설치한다.

~~~
# apt install ruby-full build-essential zlib1g-dev
~~~

### 3. Ruby Gem, Jekyll 설치

* Jekyll 구동에 필요한 Ruby Gem 및 Jekyll을 설치한다.

~~~
# gem install bundler -v '1.16.1'
# bundle install
# gem install jeykll
~~~

### 4. Jekyll Build & Serve

* Jekyll Build & Serve를 통해서 Local에서 Jekyll Blog를 확인한다.
  * Jekyll Blog의 Root 폴더에서 아래의 명령어를 실행한다.
  * 명령어 실행 후 **127.0.0.1:4000**으로 접속하여 Jekyll Blog를 확인한다.

~~~
# jekyll serve
~~~

### 5. 참조

* https://jekyllrb.com/docs/installation/ubuntu/