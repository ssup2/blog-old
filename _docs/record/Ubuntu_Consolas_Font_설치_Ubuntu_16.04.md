---
title: Ubuntu Consolas Font 설치 - Ubuntu 16.04
category: Record
date: 2017-02-14T15:27:00Z
lastmod: 2017-02-14T15:27:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설치 환경은 다음과 같다.
* Ubuntu 16.04 LTS 64bit, root user

### 2. Ubuntu Package 설치

~~~
# apt-get install font-manager
# apt-get install cabextract
~~~

font-manager를 설치한다.

### 3. Consolas Download Script 생성 및 설치

~~~
# vim consolas.sh
~~~

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
<figure>
<figcaption class="caption">[파일 1] consolas.sh</figcaption>
</figure>

[파일 1]의 내용을 복사하여 consolas.sh 파일을 생성한다.

~~~
# chmod +x consolas.sh
# ./consolas.sh
~~~

consolas.sh을 실행한다.

### 4. Consolas Font 설치

~~~
# font-manager
~~~

font-manager 실행한다.

![[그림 1] Font 파일 선택]({{site.baseurl}}/images/record/Ubuntu_Consolas_Install_Ubuntu_16.04/Ubuntu_Font_Manager.PNG)

Install Fonts를 눌러 temp 폴더 안에 있는 Font 파일들을 선택한다.

### 5. 파일 삭제

~~~
# rm -r temp
# rm consolas.sh
~~~

Font 파일들과 consolas.sh 파일을 지운다.

### 6. 참조
* [http://www.rushis.com/2013/03/consolas-font-on-ubuntu/](http://www.rushis.com/2013/03/consolas-font-on-ubuntu/)
* [http://askubuntu.com/questions/191778/how-to-install-fonts-fast-and-easy](http://askubuntu.com/questions/191778/how-to-install-fonts-fast-and-easy)
