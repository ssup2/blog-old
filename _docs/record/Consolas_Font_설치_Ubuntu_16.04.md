---
title: Ubuntu Consolas Font 설치 - Ubuntu 16.04
category: Record
date: 2017-02-14T15:27:00Z
lastmod: 2017-02-14T15:27:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Ubuntu 16.04 LTS 64bit, root user

### 2. Ubuntu Package 설치

* font-manager 설치

~~~
# apt-get install font-manager
# apt-get install cabextract
~~~

### 3. Consolas Download Script 생성 및 설치

* consolas.sh 파일 생성 및 편집

~~~
# vim consolas.sh
~~~

* 아래의 내용을 vim consolas.sh에 복사
{% highlight shell %}
#!/bin/sh
set -e
set -x
mkdir temp
cd temp
wget http://download.microsoft.com/download/E/6/7/E675FFFC-2A6D-4AB0-B3EB-27C9F8C8F696/PowerPointViewer.exe
cabextract -L -F ppviewer.cab PowerPointViewer.exe
cabextract ppviewer.cab
{% endhighlight %}

* consolas.sh 실행

~~~
# chmod +x consolas.sh
# ./consolas.sh
~~~

### 4. Consolas Font 설치

* font-manager 실행

~~~
# font-manager
~~~

* Install Fonts를 눌러 temp 폴더 안에 있는 Font 파일들을 선택한다.

![]({{site.baseurl}}/images/record/Ubuntu_Consolas/Ubuntu_Font_Manager.PNG)

### 5. 파일 삭제

* Font 파일들과 consolas.sh 파일을 지운다.

~~~
# rm -r temp
# rm consolas.sh
~~~

### 6. 참조
* [http://www.rushis.com/2013/03/consolas-font-on-ubuntu/](http://www.rushis.com/2013/03/consolas-font-on-ubuntu/)
* [http://askubuntu.com/questions/191778/how-to-install-fonts-fast-and-easy](http://askubuntu.com/questions/191778/how-to-install-fonts-fast-and-easy)
