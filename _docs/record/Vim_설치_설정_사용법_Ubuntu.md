---
title: Vim 설치, 설정, 사용법 - Ubuntu
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

* Ubuntu 14.04 / Ubuntu 16.04
* Vim 8

### 2. 설정 Plugin 목록

* vundle : Vim Plugin Manager역활을 수행하는 Plugin
* nerdtree : Vim용 파일 탐색기
* tagbar : Code의 Tag 목록을 보여주는 Plugin
* YouCompleteMe : Code 자동완성 Plugin
* vim-gutentags : Ctag 파일을 관리하는 Plugin
* vim-airline : Vim의 Status Line을 Update하는 Plugin
* vim-clang-format : clang-format을 이용하여 Code Align을 수행하는 Plugin
* vim-go : golang을 위한 Plugin

### 3. Vim 기본 설치, 설정

#### 3.1. Ubuntu Package 설치

* Vim 설치

~~~
# add-apt-repository ppa:jonathonf/vim
# apt-get update
# apt-get install vim-gnome
~~~

* ctags, cscope 설치

~~~
# apt-get install ctags
# apt-get install cscope
~~~

* ClangFormat 설치

~~~
# apt-get install clang-format
~~~

#### 3.2. Bash Shell 설정

* ~/.bashrc 파일에 다음의 내용 추가

~~~
export TERM=xterm-256color
~~~

#### 3.3. Vim Color Theme 다운로드

* git을 이용하여 seoul256 Theme 설치

~~~
# mkdir -p ~/.vim/colors
# git clone https://github.com/junegunn/seoul256.vim.git
# cp seoul256.vim/colors/seoul256.vim ~/.vim/colors/seoul256.vim
# rm -r seoul256.vim
~~~

#### 3.4. Vundle Plugin 설치

* git을 이용하여 Vundle 설치

~~~
# git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
~~~

#### 3.4. .vimrc 파일 설정

* ~/.vimrc 파일을 다음과 같이 수정

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
Plugin 'rhysd/vim-clang-format'
Plugin 'bling/vim-airline'

" All of your Plugins must be added before the following line
call vundle#end()               " required
filetype plugin indent on       " required

"" Vim Setting
set encoding=utf-8              " Encoding Type utf-8
set nu                          " Line Number
set ai                          " Auto Indent
set ts=4                        " Tab Size
set sw=4                        " Shift Width
set hlsearch                    " highlight all search matches
syntax on
colorscheme seoul256

"" cscope Setting
set csprg=/usr/bin/cscope         " cscope Which
set csto=1                        " tags Search First
set cst                           " 'Ctrl + ]' use ':cstag' instead of the default ':tag' behavior
set nocsverb                      " verbose Off
if filereadable("./cscope.out")   " add cscope.out
    cs add cscope.out
endif
set csverb                        " verbose On

"" NERD Tree Setting
nmap <F7> :NERDTreeToggle<CR>     " F7 Key = NERD Tree Toggling
let NERDTreeWinPos = "left"

"" Tag Bar Setting
nmap <F8> :TagbarToggle<CR>       " F8 Key = Tagbar Toggling

filetype on
let g:tagbar_width = 35

"" vim-gutentags
let g:gutentags_project_root=['.tag_root']

"" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_completion = 1
nnoremap <C-p> :YcmCompleter GoTo<CR>

"" vim-clang-format
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
nmap <Leader>C :ClangFormatAutoToggle<CR>
let g:clang_format#auto_format=1
{% endhighlight %}

#### 3.5. Vundle을 이용하여 Vim Plugin 설치

* Vim 명령어 모드에서 다음 명령어 수행

~~~
: PluginInstall
~~~

#### 3.6. YouCompleteMe 설치

* YouComplete Compile 및 설치

~~~
# apt-get install build-essential cmake
# apt-get install python-dev python3-dev
# cd ~/.vim/bundle/YouCompleteMe
# ./install.py --clang-completer
~~~

* .ycm_extra_conf.py 파일 Download 및 ~/.vim/.ycm_extra_conf.py에 복사

~~~
# wget https://raw.githubusercontent.com/Valloric/ycmd/3ad0300e94edc13799e8bf7b831de8b57153c5aa/cpp/ycm/.ycm_extra_conf.py -O ~/.vim/.ycm_extra_conf.py
~~~

### 4. golang 환경 설치, 설정

#### 4.1. Ubuntu Package 설치

* golang 설치

~~~
# add-apt-repository ppa:longsleep/golang-backports
# apt-get update
# apt-get install golang-go
~~~

#### 4.2. Bash Shell 설정

* ~/.bashrc 파일에 다음의 내용 추가

~~~
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
~~~

#### 4.3. .vimrc 파일 설정

* ~/.vimrc 파일에 다음의 내용 추가

~~~
Plugin 'fatih/vim-go'
~~~

#### 4.4. YouCompleteMe 재설치

* YouCompleteMe Compile 및 설치

~~~
# cd ~/.vim/bundle/YouCompleteMe
# ./install.py --clang-completer --gocode-completer
~~~

#### 4.5. golang Binary 설치

* Vim 명령어 모드에서 다음 명령어 수행

~~~
: GoInstallBinaries
~~~

### 5. 사용법

#### 5.1. YouCompleteMe

* C, Cpp Project의 경우 Project 최상단 폴더에 ~/.vim/.ycm_extra_conf.py 파일 복사

| 단축키 | 동작 |
|-------|------|
| ctrl + p | YouCompleteMe Tag Jump |
| ctrl + o | 이전 Jump Point로 이동 (VIM 단축키) |
| ctrl + i | 다음 Jump Point로 이동 (VIM 단축키) |

#### 5.2. vim-clang-format

* c, cpp 저장 시 자동으로 clang-format 적용

| 단축키 | 동작 |
|-------|------|
| \cf | clang-format 적용 |
| \C | Auto clang-format 적용 Toggle |

### 6. 참조

* Vundle - [https://github.com/gmarik/Vundle.vim](https://github.com/gmarik/Vundle.vim)
* Colorscheme - [https://github.com/junegunn/seoul256.vim](https://github.com/junegunn/seoul256.vim)
* YouCompleteMe Install - [http://neverapple88.tistory.com/26](http://neverapple88.tistory.com/26)
