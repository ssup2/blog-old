---
title: tmux 설정 / Ubuntu, macOS 환경
category: Record
date: 2020-01-09T12:00:00Z
lastmod: 2020-01-09T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. tmux 설정

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
set -g @plugin 'egel/tmux-gruvbox'

# Initialize TMUX plugin manager
run -b '~/.tmux/plugins/tpm/tpm'
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.tmux.conf</figcaption>
</figure>

~/.tmux.conf 파일을 [파일 1]의 내용으로 생성/변경 한다.

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

### 2. TPM (Tmux Plugin Manager) 설치, 실행

~~~console
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~~~

TPM을 설치한다.

~~~console
# tmux
ctrl + b, I
~~~

tmux를 실행하고, tmux 안에서 단축키를 눌러 Plugin을 설치한다.

### 3. 참조

* [https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)
