---
title: Ubuntu Vim 설정
category: Record
date: 2017-01-20T16:41:00Z
lastmod: 2017-01-22T16:41:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설정 환경

* Date : 2016.12.13
* Ubuntu 14.04 / Ubuntu 16.04
* Vim 8

### 2. 설정 Plugin 목록

* vundle : Vim Plugin Manager역활을 수행하는 Plugin.
* nerdtree : Vim용 파일 탐색기.
* tagbar : Code의 Tag 목록을 보여주는 Plugin.
* SrcExpl : Vim의 커서가 위치한 변수의 선언 위치나 함수의 정의 부분을 보여주는 Plugin.
* YouCompleteMe : Code 자동완성 Plugin.
* vim-gutentags : Ctag 파일을 관리하는 Plugin.
* vim-airline : Vim의 Status Line을 Update하는 Plugin.
* vim-go : golang을 위한 Plugin.

### 3. Ubuntu Package 설치

* Vim 설치

> \# add-apt-repository ppa:jonathonf/vim <br>
> \# apt-get update <br>
> \# apt-get install vim-gnome

* ctags, cscope 설치

> \# apt-get install ctags <br>
> \# apt-get install cscope

### 4. Bash Shell 설정

* ~/.bashrc 파일 설정

> \# vi ~/.bashrc

~~~
export TERM=xterm-256color
export GOPATH=$HOME/Desktop/golang
export PATH=$PATH:$GOPATH/bin
~~~

### 5. Vim Color Theme 다운로드

> \# mkdir -p ~/.vim/colors  <br>
> \# git clone https://github.com/junegunn/seoul256.vim.git <br>
> \# cp seoul256.vim/colors/seoul256.vim ~/.vim/colors/seoul256.vim <br>
> \# rm -r seoul256.vim

### 6. Vundle Plugin 설치

> \# git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

### 7. Vim 설정

* ~/.vimrc 파일 설정

{% highlight VimL %}
"
" supsup's .vimrc
"
" Version 1.20 for Ubuntu
"

"" vundle Setting
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Plugins
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'Valloric/YouCompleteMe'
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'bling/vim-airline'
Plugin 'fatih/vim-go'

" All of your Plugins must be added before the following line
call vundle#end()               " required
filetype plugin indent on				" required

"" Vim Setting
set encoding=utf-8						  " Encoding Type utf-8
set nu						              " Line Number
set ai						              " Auto Indent
set ts=4			                  " Tab Size
set sw=4						            " Shift Width
set hlsearch							      " highlight all search matches
syntax on
colorscheme seoul256

"" cscope Setting
set csprg=/usr/bin/cscope				  " cscope Which
set csto=1								        " tags Search First
set cst									          " 'Ctrl + ]' use ':cstag' instead of the default ':tag' behavior
set nocsverb							        " verbose Off
if filereadable("./cscope.out")	  " add cscope.out
    cs add cscope.out
endif
set csverb								        " verbose On

"" NERD Tree Setting
nmap <F7> :NERDTreeToggle<CR>			" F7 Key = NERD Tree Toggling
let NERDTreeWinPos = "left"

"" Tag Bar Setting
nmap <F8> :TagbarToggle<CR>				" F9 Key = Tagbar Toggling

filetype on
let g:tagbar_width = 35

"" vim-gutentags
let g:gutentags_project_root=['.tag_root']

"" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
{% endhighlight %}

* Vim 명령어 모드에서 다음 명령어 수행

> \: PluginInstall <br>
> \: GoInstallBinaries

### 8. YouCompleteMe 설치

* YouComplete Compile 및 설치

> \# apt-get install build-essential cmake <br>
> \# apt-get install python-dev python3-dev <br>
> \# cd ~/.vim/bundle/YouCompleteMe <br>
> \# ./install.py --clang-completer --gocode-completer

* .ycm_extra_conf.py 파일 Download 및 ~/.vim/.ycm_extra_conf.py에 복사
  * https://github.com/Valloric/ycmd/blob/master/cpp/ycm/.ycm_extra_conf.py

### 9. 참조
* Vundle - [https://github.com/gmarik/Vundle.vim](https://github.com/gmarik/Vundle.vim)
* Colorscheme - [https://github.com/junegunn/seoul256.vim](https://github.com/junegunn/seoul256.vim)
* YouCompleteMe Install - [http://neverapple88.tistory.com/26](http://neverapple88.tistory.com/26)
