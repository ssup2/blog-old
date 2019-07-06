---
title: Jekyll 설치, Build / Ubuntu 18.04 환경
category: Record
date: 2019-04-01T12:00:00Z
lastmod: 2019-04-01T12:00:00Z
comment: true
adsense: true
---

### 1. Build 환경

Build 환경은 다음과 같다.
* Ubuntu 18.04 LTS 64bit, root user

### 2. Ubuntu Package 설치

~~~
# apt install ruby-full build-essential zlib1g-dev
~~~

Jeykll 구동에 필요한 Ubuntu Package를 설치한다.

### 3. Ruby Gem, Jekyll 설치

~~~
# gem install bundler -v '1.16.1'
# bundle install
# gem install jeykll
~~~

Jekyll 구동에 필요한 Ruby Gem 및 Jekyll을 설치한다.

### 4. Jekyll Servce

~~~
# jekyll serve
~~~

Jekyll Blog의 Root 폴더에서 jekyll serve 명령어를 이용하여 Local에서 Jekyll Blog를 구동하고, 동작을 확인한다.
*  http://192.168.0.150:4000

### 5. 참조

* https://jekyllrb.com/docs/installation/ubuntu/