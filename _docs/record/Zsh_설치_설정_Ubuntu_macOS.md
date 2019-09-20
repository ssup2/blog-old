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

#### 1.2. macOS

~~~console
# brew install zsh zsh-completions
# curl -L http://install.ohmyz.sh | sh
# which zsh >> /etc/shells
# chsh -s `which zsh`
~~~

zsh, zsh-completions, oh-my-zsh을 설치하고 기본 Shell을 Zsh로 설정한다.

### 2. 설정

{% highlight viml %}
...
ZSH_THEME="wezm"
plugins=(git)
source $ZSH/oh-my-zsh.sh
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.zshrc</figcaption>
</figure>

~/.zshrc 파일을 수정하여 Zsh을 설정한다.
