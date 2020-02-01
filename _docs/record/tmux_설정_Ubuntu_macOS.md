---
title: tmux 설정 / Ubuntu, macOS 환경
category: Record
date: 2020-01-09T12:00:00Z
lastmod: 2020-01-09T12:00:00Z
comment: true
adsense: true
---

### 1. tmux 설치

#### 1.1. Ubuntu

~~~console
# apt install tmux
~~~

apt을 이용하여 tmux를 설치한다.

#### 1.2. macOS

~~~console
# brew install tmux
~~~

brew를 이용하여 tmux를 설치한다.

### 2. tmux 설정

{% highlight text %}
# Set mouse
setw -g mouse on

# Set screen color
set -g default-terminal "screen-256color"

# Vim-like pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Initialize TMUX plugin manager
run -b '~/.tmux/plugins/tpm/tpm'
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.tmux.conf</figcaption>
</figure>

~/.tmux.conf 파일을 [파일 1]의 내용으로 생성/변경 한다.

### 3. Bash Shell, Terminal 설정

#### 3.1. Ubuntu

{% highlight shell %}
...
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] ~/.bashrc</figcaption>
</figure>

~/.bashrc 파일의 마지막에 [파일 2]의 내용을 추가하여 Shell 실행시 tmux가 실행되도록 설정한다.

#### 3.2. macOS

![[그림 1] tmux autorun setting with iTerm2]({{site.baseurl}}/images/record/tmux_Install_Ubuntu_macOS/tmux_autorun_iTerm2.PNG){: width="600px"}

> Preferences... -> Profiles -> General -> Sends text at start:

> tmux ls && read tmux_session && tmux attach -t ${tmux_session:-default} \|\| tmux new -s ${tmux_session:-default}

[그림 1]의 내용처럼 iTerm2 설정에 "Sends text at start"에 tmux 설정을 추가하여 iTerm2 실행시 tmux가 실행되도록 설정한다.

![[그림 2] tmux clipboard setting with iTerm2]({{site.baseurl}}/images/record/tmux_Install_Ubuntu_macOS/tmux_clipboard_iTerm2.PNG){: width="600px"}

> Preferences... -> General -> Applications in terminal may access clipboard

[그림 2]의 내용처럼 iTerm2를 설정하여 tmux에서 선택한 Text가 Clipboard로 복사되도록 설정한다.

### 4. TPM (Tmux Plugin Manager) 설치, 실행

~~~console
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~~~

TPM을 설치한다.

~~~console
# tmux
ctrl + b, I
~~~

tmux를 실행하고, tmux 안에서 단축키를 눌러 Plugin을 설치한다.

### 5. 참조

* [https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)
