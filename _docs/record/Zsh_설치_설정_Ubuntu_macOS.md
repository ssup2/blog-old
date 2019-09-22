---
title: Zsh 설치, 설정 / Ubuntu, macOS 환경
category: Record
date: 2019-09-22T12:00:00Z
lastmod: 2019-09-22T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. Zsh 설치

#### 1.1. Ubuntu

~~~console
# apt install zsh
# curl -L http://install.ohmyz.sh | sh
# chsh -s `which zsh`
# zsh
~~~

zsh, oh-my-zsh을 설치하고 기본 Shell을 Zsh로 설정한다. 이후 진행은 **Zsh**에서 진행한다. 

#### 1.2. macOS

~~~console
# brew install zsh zsh-completions
# curl -L http://install.ohmyz.sh | sh
# which zsh >> /etc/shells
# chsh -s `which zsh`
# zsh
~~~

zsh, zsh-completions, oh-my-zsh을 설치하고 기본 Shell을 Zsh로 설정한다. 이후 진행은 **Zsh**에서 진행한다. 

### 2. Zsh Plugin 설치

~~~console
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
~~~

zsh-syntax-highlighting, zsh-autosuggestions을 설치한다.

### 3. Zsh 설정

#### 2.1. Zsh Pure Theme 설치

{% highlight viml %}
...
ZSH_THEME="clean"
...
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.zshrc</figcaption>
</figure>

~/.zshrc 파일을 수정하여 Zsh을 설정한다.

### 4. 참조

* [https://gist.github.com/ganapativs/e571d9287cb74121d41bfe75a0c864d7](https://gist.github.com/ganapativs/e571d9287cb74121d41bfe75a0c864d7)
