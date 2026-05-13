" Vim設定ファイル

" 表示
set number        " 行番号を表示する
set showmatch     " 対応する括弧をハイライト
set wrap          " 長い行を折り返し表示
syntax on
set listchars=tab:^\ ,trail:~ " 行末のスペースを可視化
set display=lastline  " 最後の行を省略しない
set cmdheight=2 " メッセージ表示欄を2行確保

" ステータスバー
set laststatus=2  " 常に表示
set statusline=%f         " ファイル名
set statusline+=%m        " 変更フラグ（未保存で[+]表示）
set statusline+=%r        " 読み取り専用フラグ
set statusline+=%=        " 左右の区切り
set statusline+=%{GetFileFormat()}   " 改行コード
set statusline+=\ %{&fileencoding}  " 文字コード
set statusline+=\ %l/%L   " 現在行/総行数

" インデント
set expandtab     " タブをスペースに変換
set tabstop=2     " タブ幅
set shiftwidth=2  " インデント幅
set autoindent    " 自動インデント
set smartindent   " 構文に応じたインデント

" 検索
set ignorecase  " 大文字小文字を区別しない
set smartcase   " 大文字が含まれる場合は区別する
set hlsearch    " 検索結果をハイライト
set incsearch   " インクリメンタルサーチ

" 操作
set clipboard=unnamed   " OSのクリップボードと共有
set guioptions+=a       " yでコピーしたときクリップボードに入る
set virtualedit=block   " vimの短形選択で文字がなくても右へ進める
set noerrorbells        " エラー時にビープを鳴らさない

" 文字コード
set encoding=utf-8
set fileencodings=utf-8,sjis,cp932

" 改行コード
set fileformats=unix,dos,mac

" バックアップを作ることを無効化
set nowritebackup
set nobackup

" スワップファイルを作成しない
set noswapfile

" 前回編集時のカーソルの位置を復元
augroup restore_cursor
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END


" 言語固有設定
" Python
autocmd FileType python set local tabstop=4 shiftwidth=4


" プラグイン
if has('win32') || has('win64')
  " Windows
  call plug#begin('~/vimfiles/plugged')
else
  " Mac/Linux
  call plug#begin('~/.vim/plugged')
endif

" NERDTree
Plug 'preservim/nerdtree' 

call plug#end()


" キーマップ
let mapleader = "\<Space>"

" NERDTreeをeで開く
nnoremap <Leader>e :NERDTreeToggle<CR>


" その他ツールごとの設定
if has('win32') || has('win64')
  if has('gui_running')
    " Windows gVim
    set guifont=Consolas:h12
  else
    " Windows Vim
    set termguicolors " ターミナルのフルカラー対応
  endif
endif


" Utilities

" ファイルフォーマット(unix,dos,mac)を改行コード(LF,CRLF,CR)に変換する
function! GetFileFormat()
  let ff = &fileformat
  if ff == 'unix'
    return 'LF'
  elseif ff == 'dos'
    return 'CRLF'
  elseif ff == 'mac'
    return 'CR'
  endif
endfunction

