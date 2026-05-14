vim9script

# --------------------------------------------------------------------------------
# Vim Settings
# --------------------------------------------------------------------------------

# Display
set number        # 行番号
set showtabline=2 # タブライン
set wrap          # 長い行を折り返す
set cmdheight=2   # メッセージ表示欄を2行確保
set display=lastline  # 最後の行を省略しない
set lines=999 columns=999
winpos 0 0

# Status Bar Styles
set laststatus=2
set statusline=[%{exists('*FugitiveHead')?FugitiveHead():''}]
set statusline+=\ %f
set statusline+=%m
set statusline+=%r
set statusline+=%=
set statusline+=%{%GetFileFormat()%}  # 改行コード (Vim9式評価)
set statusline+=\ %{&fileencoding}    # 文字コード
set statusline+=\ %l/%L               # 現在行/総行数

# Color Styles
syntax enable
set showmatch     # 対応する括弧をハイライト
colorscheme desert

# Edit
set expandtab     # タブをスペースに変換
set tabstop=2     # タブ幅
set shiftwidth=2  # インデント幅
set autoindent    # 自動インデント
set smartindent   # 構文に応じたインデント
set virtualedit   # 矩形選択時に仮想編集を有効化

# Search
set ignorecase  # 大文字小文字を区別しない
set smartcase   # 大文字が含まれる場合は区別する
set hlsearch    # 検索結果をハイライト
set incsearch   # インクリメンタルサーチ

# Files
set nowritebackup # バックアップを作ることを無効化
set nobackup
set noswapfile    # スワップファイルを作成しない
set noundofile    # undoファイルを作成しない
set autoread      # 外部での変更を自動リロー

augroup auto_read
  autocmd!
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * checktime
  autocmd FileChangedShell * v:fcs_choice = 'reload'
augroup END

# Other
set clipboard=unnamed   # OSのクリップボードと共有
set guioptions+=a       # yでコピーしたときクリップボードに入る
set virtualedit=block   # vimの短形選択で文字がなくても右へ進める
set noerrorbells        # エラー時にビープを鳴らさない
set encoding=utf-8      # Vim内の文字コードをUTF-8にする
set fileencodings=utf-8,sjis,cp932
set fileformats=unix,dos,mac


# --------------------------------------------------------------------------------
# Languages
# --------------------------------------------------------------------------------

augroup python_settings
  autocmd!
  autocmd FileType python setlocal tabstop=4 shiftwidth=4
augroup END


# --------------------------------------------------------------------------------
# Plugins
# --------------------------------------------------------------------------------

if has('win32') || has('win64')
  plug#begin('~/vimfiles/plugged')
else
  plug#begin('~/.vim/plugged')
endif

Plug 'vim-jp/vimdoc-ja'
Plug 'preservim/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'

plug#end()

# NERDTree
g:NERDTreeShowHidden = 1  # 隠しファイルを表示
g:NERDTreeWinSize = 30    # NERDTreeの横幅を固定

augroup nerdtree_refresh
  autocmd!
  autocmd BufWritePost,BufAdd * silent! NERDTreeRefreshRoot
  autocmd FocusGained * silent! NERDTreeRefreshRoot
augroup END

# Fugitive
augroup fugitive_statusline
  autocmd!
  autocmd User FugitiveChanged redrawstatus!
  autocmd User FugitiveChanged silent! NERDTreeRefreshRoot
augroup END


# --------------------------------------------------------------------------------
# Claude Code
# --------------------------------------------------------------------------------

var claude_term_buf: number = -1
var claude_term_win: number = -1

def! g:ToggleClaude()
  if claude_term_win > 0 && win_id2win(claude_term_win) > 0 && winbufnr(win_id2win(claude_term_win)) == claude_term_buf
    win_gotoid(claude_term_win)
    hide
  elseif bufexists(claude_term_buf)
    botright vsplit
    execute $'buffer {claude_term_buf}'
    vertical resize 120
    claude_term_win = win_getid()
    startinsert
  else
    botright vertical terminal claude
    vertical resize 120
    claude_term_buf = bufnr('%')
    claude_term_win = win_getid()
  endif
enddef

def! g:SendSelectionToClaude()
  var selection: string = join(getline("'<", "'>"), "\n")
  win_gotoid(claude_term_win)
  term_sendkeys(claude_term_buf, selection .. "\n")
enddef

def RedirectFromClaudeWindow()
  if claude_term_buf < 0 || claude_term_win < 0
    return
  endif
  if win_id2win(claude_term_win) == 0
    return
  endif
  if &buftype != '' || &filetype ==# 'nerdtree' || &filetype ==# 'gitlog'
    return
  endif
  var cur_win = win_getid()
  var claude_col = win_screenpos(claude_term_win)[1]
  if win_screenpos(cur_win)[1] != claude_col
    return
  endif
  var filebuf = bufnr('%')
  if cur_win == claude_term_win
    execute 'buffer ' .. claude_term_buf
  else
    close
  endif
  var target = -1
  for w in range(1, winnr('$'))
    var wid = win_getid(w)
    if getwinvar(w, '&filetype') ==# 'nerdtree' || getwinvar(w, '&buftype') != ''
      continue
    endif
    if win_screenpos(wid)[1] < claude_col
      target = wid
      break
    endif
  endfor
  if target > 0
    win_gotoid(target)
    execute 'buffer ' .. filebuf
  else
    win_gotoid(claude_term_win)
    leftabove vsplit
    execute 'buffer ' .. filebuf
  endif
enddef

augroup claude_window_guard
  autocmd!
  autocmd BufWinEnter * RedirectFromClaudeWindow()
augroup END


# --------------------------------------------------------------------------------
# Git Log (コミットログビューア)
# --------------------------------------------------------------------------------

def! g:ToggleGitLog()
  for info in getwininfo()
    if getbufvar(info.bufnr, '&ft') ==# 'gitlog'
      win_gotoid(info.winid)
      quit
      return
    endif
  endfor

  var log_output = systemlist('git log --no-color 2>&1')
  if v:shell_error != 0
    echomsg join(log_output, ' ')
    return
  endif

  if claude_term_win > 0 && win_id2win(claude_term_win) > 0 && winbufnr(win_id2win(claude_term_win)) == claude_term_buf
    win_gotoid(claude_term_win)
    rightbelow vsplit
  else
    botright vsplit
  endif

  enew
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  setlocal modifiable
  setline(1, log_output)
  setlocal nomodifiable
  setlocal filetype=gitlog
  vertical resize 80
enddef

augroup gitlog_syntax
  autocmd!
  autocmd FileType gitlog syntax match gitlogCommit /^commit \x\+/
  autocmd FileType gitlog syntax match gitlogMeta   /^\(Author\|Date\):/he=e-1
  autocmd FileType gitlog highlight link gitlogCommit Keyword
  autocmd FileType gitlog highlight link gitlogMeta   Comment
  autocmd FileType gitlog nnoremap <buffer> q <Cmd>quit<CR>
augroup END


# --------------------------------------------------------------------------------
# Key Maps
# --------------------------------------------------------------------------------

# 文字列検索のハイライトオフ (ESCを2回連打)
nmap <silent> <Esc><Esc> :<C-u>nohlsearch<CR><Esc>

g:mapleader = "\<Space>"

# NERDTreeを Space -> e で開く
nnoremap <Leader>e :NERDTreeTabsToggle<CR><C-w>=

# Claude Code
nnoremap <Leader>c  <Nop>
nnoremap <Leader>cc <Cmd>call g:ToggleClaude()<CR>
nnoremap <C-\> <Cmd>call g:ToggleClaude()<CR>

# Git Log
nnoremap <Leader>g  <Nop>
nnoremap <Leader>gl <Cmd>call g:ToggleGitLog()<CR>
vnoremap <Leader>cs <Cmd>call g:SendSelectionToClaude()<CR>

# C-[ でターミナルモードからノーマルモードへ切り替え
tnoremap <C-[> <C-W>N


# --------------------------------------------------------------------------------
# Tools
# --------------------------------------------------------------------------------

if has('gui_running')
  # gVim | mVim
  set guioptions=r  # 右スクロールバー非表示
  set guioptions=l  # 左スクロールバー非表示
  # ノーマル: 点滅ブロック / 挿入: 非点滅縦棒 / 置換: 非点滅下線
  set guicursor=n:block-blinkwait700-blinkon400-blinkoff250,i:ver25-blinkon0-blinkoff0,r:hor20
  # カーソル色: desert のコメント色 (#6dceeb) より少し深い青
  highlight Cursor guifg=#333333 guibg=#5aadde
else
  # ターミナルVim (DECSCUSR エスケープシーケンス)
  &t_EI = "\e[1 q"  # ノーマルモード: 点滅ブロック
  &t_SI = "\e[6 q"  # 挿入モード: 非点滅縦棒
  &t_SR = "\e[4 q"  # 置換モード: 非点滅下線
endif

if has('win32') || has('win64')
  if has('gui_running')
    # gVim
    set guifont=Consolas:h12
  else
    # Windows Vim
    set termguicolors
  endif
else
  if has('gui_running')
    # mVim
    set guifont=Menlo-Regular:h13
  else
    # Mac Vim
    set termguicolors
  endif
endif


# --------------------------------------------------------------------------------
# Utilities
# --------------------------------------------------------------------------------

# ファイルフォーマット(unix,dos,mac)を改行コード(LF,CRLF,CR)に変換する
def! g:GetFileFormat(): string
  var ff: string = &fileformat
  if ff == 'unix'
    return 'LF'
  elseif ff == 'dos'
    return 'CRLF'
  elseif ff == 'mac'
    return 'CR'
  endif
  return ''
enddef

# 前回編集時のカーソルの位置を復元
def RestoreCursor()
  if line("'\"") > 1 && line("'\"") <= line("$")
    execute "normal! g'\""
  endif
enddef

augroup restore_cursor
  autocmd!
  autocmd BufReadPost * RestoreCursor()
augroup END

# 他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる
def CloseIfOnlyNerdTreeLeft()
  if winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()
    q
  endif
enddef

augroup nerdtree_close
  autocmd!
  autocmd BufEnter * CloseIfOnlyNerdTreeLeft()
augroup END

