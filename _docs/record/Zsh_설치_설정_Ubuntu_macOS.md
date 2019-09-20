---
title: Zsh 설치, 설정 / Ubuntu, macOS 환경
category: Record
date: 2019-09-20T12:00:00Z
lastmod: 2019-09-20T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치

#### 1.1. Ubuntu

~~~console
# apt install zsh
# curl -L http://install.ohmyz.sh | sh
# chsh -s `which zsh`
~~~

zsh, oh-my-zsh을 설치하고 기본 Shell을 Zsh로 설정한다.

#### 1.2. macOS

~~~console
# brew install zsh zsh-completions
# curl -L http://install.ohmyz.sh | sh
# which zsh >> /etc/shells
# chsh -s `which zsh`
~~~

zsh, zsh-completions, oh-my-zsh을 설치하고 기본 Shell을 Zsh로 설정한다.

### 2. 설정

~~~console
# git clone https://github.com/dracula/zsh.git
# cp zsh/dracula.zsh-theme ~/.oh-my-zsh/themes/
# cp -R zsh/lib ~/.oh-my-zsh/themes/
# rm -rf zsh/lib
~~~

{% highlight viml %}
...
ZSH_THEME="dracula"
plugins=(git)
source $ZSH/oh-my-zsh.sh
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.zshrc</figcaption>
</figure>

~/.zshrc 파일을 수정하여 Zsh을 설정한다.
