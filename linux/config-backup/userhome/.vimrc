"tab缩进
set tabstop=2
"格式化时制表符占用空格数
set shiftwidth=2
"将制表符扩展为空格
set expandtab
"智能tab
set smarttab

"自动缩进
set autoindent
"智能缩进
set smartindent
"C语言自动缩进
set cindent
"根据类型格式缩进
filetype indent on

"语法高亮 syntax highlight
syntax on
"代码折叠 code folding
set foldenable
"折叠方式 folding style
"根据语法syntax|手动manual|根据表达式epxr|根据未更改内容diff|根据标志marker|根据缩进indent
set foldmethod=syntax
"启动 vim 时关闭折叠 folding when vim launch
"set nofoldenable
"设置键盘映射，通过空格设置折叠 folding keymap
"nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

"浅色显示当前行
autocmd InsertLeave * se nocul
"用浅色高亮当前行
autocmd InsertEnter * se cul

"文件类型识别
filetype on
"根据文件类型开启相关插件
filetype plugin on

"括号匹配
set showmatch
"显示行号
set number

"历史条目数量
set history=999
"没有保存或文件只读时弹出确认
set confirm
set backspace=2

"自动读取(自动检测外部更改)
set autoread
"自动写入(自动保存)
"禁止生成临时文件
set nobackup
"允许鼠标操作
set mouse=a

"魔术 (设置元字符要加反斜杠进行转义)
"magic(\m模式)除了 $ . * ^ 之外其他元字符都要加反斜杠
"nomagic(\M模式) 除了 $ ^ 之外其他元字符都要加反斜杠
"\v （即 very magic 之意）：任何元字符都不用加反斜杠
"\V （即 very nomagic 之意）：任何元字符都必须加反斜杠
set magic

"启动显示状态行
set laststatus=2
"状态栏信息
set statusline=[FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]
"显示输入的命令
set showcmd
"显示标尺 在右下角显示光标位置
set ruler
"光标移动到buffer的顶部和底部时保持n行距离
set scrolloff=3

"输入搜索内容时就显示搜索结果
set incsearch
"高亮查找的匹配结果
set hlsearch
"搜索时忽略大小写 但在有一个或以上大写字母时仍保持对大小写敏感
set ignorecase smartcase
set gdefault

"配色主题
"colorscheme molokai
"背景色
"set background=dark
"颜色 256色
set t_Co=256

"去除vi的一致性
set nocompatible

"新建文件的编码格式
set fileencoding=utf-8
"打开文件后可识别的编码格式
set fileencodings=utf-8,gb18030,gb2312,gbk,big5

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"=====vim plugins====="
"主题
"Plugin 'tomasr/molokai'

"模糊搜索
Plugin 'ctrlpvim/ctrlp.vim'

"目录树
Plugin 'scrooloose/nerdtree'

"语法高亮
Plugin 'vim-syntastic/syntastic'

"自动补全
Plugin 'Shougo/neocomplete.vim'

call vundle#end() " required
filetype plugin indent on " required

"=====molokai theme"
let g:molokai_original = 1
let g:rehash256 = 1

"=====ctrlp"
set runtimepath^=~/.vim/bundle/ctrlp.vim
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll|jpg|png|jpeg)$',
  \ }

"=====nerdtree"
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeQuitOnOpen=1
let NERDTreeShowBookmarks=1

"=====syntastic"
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

"=====neocomplete"
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
