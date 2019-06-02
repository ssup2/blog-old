---
title: Vim 설치, 설정, 사용 - Ubuntu
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

* vundle : Vim Plugin Manager 역활을 수행한다. .vimrc에 설치할 Vim Plugin을 넣어두면 vundle을 통해서 손쉽게 Vim Plugin을 설치할 수 있다.
* nerdtree : 파일 탐색기 역활을 수행한다.
* tagbar : Code의 Tag 목록을 보여준다.
* YouCompleteMe : Code 자동완성 기능 (Code Autocomplete)을 수행한다.
* vim-gutentags : Ctag 파일을 자동으로 관리한다.
* vim-airline : Vim의 Status Line의 가독성을 높여준다.
* vim-clang-format : clang-format을 이용하여 Code Align을 수행한다.
* vim-go : golang을 위한 환경을 구성한다.

### 3. Vim 기본 설치, 설정

#### 3.1. Ubuntu Package 설치

* Vim을 설치한다.

~~~
# add-apt-repository ppa:jonathonf/vim
# apt-get update
# apt-get install vim-gnome
~~~

* ctags와 cscope를 설치한다.

~~~
# apt-get install ctags
# apt-get install cscope
~~~

* ClangFormat을 설치한다.

~~~
# apt-get install clang-format
~~~

#### 3.2. Bash Shell 설정

* Vim의 gruvbox Theme를 위해서 ~/.bashrc 파일에 다음의 내용 추가한다.

~~~
source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"
~~~

#### 3.3. Vundle Plugin 설치

* git을 이용하여 Vundle 설치한다.

~~~
# git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
~~~

#### 3.4. .vimrc 파일 설정

* ~/.vimrc 파일을 다음과 같이 수정하여, Plugin 설치 및 설정 정보를 저장한다.

{% highlight viml %}
"
" supsup's .vimrc
"
" Version 1.21 for Ubuntu
"

"" vundle Setting
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Plugins
Plugin 'morhetz/gruvbox'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'Valloric/YouCompleteMe'
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'bling/vim-airline'
Plugin 'rhysd/vim-clang-format'

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
colorscheme gruvbox
syntax on

"" gruvbox
set background=dark

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
let g:gutentags_project_root = ['.tag_root']
let g:gutentags_project_info = []
call add(g:gutentags_project_info, {"type": "go", "glob": "*.go"})
let g:gutentags_ctags_executable_go = 'gotags'

"" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_completion = 1
nnoremap <C-p> :YcmCompleter GoTo<CR>

"" vim-clang-format
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
nmap <Leader>C :ClangFormatAutoToggle<CR>
let g:clang_format#auto_format = 0
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.vimrc</figcaption>
</figure>

#### 3.5. Vundle을 이용하여 Vim Plugin 설치

* ~/.vimrc에 저장되어 있는 Vim Plugin을 설치한다.
  * Vim의 명령어 Mode에서 실행한다.

~~~
: PluginInstall
~~~

#### 3.6. YouCompleteMe 설치

* YouCompleteMe를 Compile 및 설치한다.

~~~
# apt-get install build-essential cmake
# apt-get install python-dev python3-dev
# cd ~/.vim/bundle/YouCompleteMe
# ./install.py --clang-completer
~~~

* .ycm_extra_conf.py 파일 Download 및 ~/.vim/.ycm_extra_conf.py에 복사하여 YouCompleteMe의 Default 설정 값으로 이용한다.

~~~
# wget https://raw.githubusercontent.com/Valloric/ycmd/3ad0300e94edc13799e8bf7b831de8b57153c5aa/cpp/ycm/.ycm_extra_conf.py -O ~/.vim/.ycm_extra_conf.py
~~~

### 4. golang 환경 설치, 설정

#### 4.1. vim-go Vim Plugin 설치

* ~/.vimrc 파일의 Vundle Plugins에 다음의 내용 추가하여 Vundle이 vim-go를 설치하도록 만든다.

~~~
Plugin 'fatih/vim-go'
~~~

* vim-go Vim Plugin을 설치한다.
  * Vim의 명령어 Mode에서 실행한다.

~~~
: PluginInstall
~~~

#### 4.2. golang Binary 설치

* golang 개발시 필요한 Tool들을 설치한다.
  * Vim의 명령어 Mode에서 실행한다.

~~~
: GoInstallBinaries
~~~

#### 4.3. YouCompleteMe 재설치

* YouCompleteMe에 golang Option을 추가하여 Compile 및 설치를 수행한다.

~~~
# cd ~/.vim/bundle/YouCompleteMe
# ./install.py --clang-completer --gocode-completer
~~~

### 5. 사용법

#### 5.1. YouCompleteMe

* C, Cpp Project의 경우 Project 최상단 폴더에 ~/.vim/.ycm_extra_conf.py 파일 복사한다.

| 단축키 | 동작 |
|-------|------|
| ctrl + p | YouCompleteMe Tag Jump |
| ctrl + o | 이전 Jump Point로 이동 (VIM 단축키) |
| ctrl + i | 다음 Jump Point로 이동 (VIM 단축키) |

#### 5.2. vim-clang-format

* c, cpp 저장 시 자동으로 clang-format 적용한다.

| 단축키 | 동작 |
|-------|------|
| \cf | clang-format 적용 |
| \C | Auto clang-format 적용 Toggle |

### 6. 참조

* Vundle : [https://github.com/gmarik/Vundle.vim](https://github.com/gmarik/Vundle.vim)
* Colorscheme : [https://github.com/junegunn/seoul256.vim](https://github.com/junegunn/seoul256.vim)
* YouCompleteMe Install : [http://neverapple88.tistory.com/26](http://neverapple88.tistory.com/26)
