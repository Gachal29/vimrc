# vimrc

vimの設定ファイル (Vim9script)

## プラグイン

**vim-plug** を使用してプラグインを管理する

### vim-plug インストール

- Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$HOME/vimfiles/autoload/plug.vim" -Force
```

- Mac

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### プラグイン一覧

| プラグイン | 用途 |
|---|---|
| vim-jp/vimdoc-ja | Vimドキュメントの日本語版 |
| preservim/nerdtree | ファイルツリーをサイドパネルで表示 |
| jistr/vim-nerdtree-tabs | NERDTreeをタブ間で共有 |
| Xuyuanp/nerdtree-git-plugin | NERDTreeにGitステータスを表示 |
| tpope/vim-fugitive | Git操作をVim内から実行 |

### プラグインのインストール

vim-plug インストール後、Vim を起動して以下を実行する

```
:PlugInstall
```

## キーマップ

| キー | 説明 |
|---|---|
| `<Leader>e` | NERDTreeの開閉 |
| `<Leader>cc` / `<C-\>` | Claude Codeターミナルの開閉 |
| `<Leader>gl` | Gitコミットログビューアの開閉 |
| `<Leader>cs` | 選択範囲をClaude Codeに送信 (ビジュアルモード) |
| `<C-[>` | ターミナルモードからノーマルモードへ切り替え |
| `<Esc><Esc>` | 検索ハイライトのオフ |

## 機能

- **Claude Code連携**: `:ToggleClaude()` で右端にClaudeのターミナルを開閉。通常ウィンドウをClaudeペインに誤って開かないよう自動リダイレクト付き
- **Gitログビューア**: `:ToggleGitLog()` で `git log` をバッファに表示。`q` で閉じる
- **ファイル別インデント**: Pythonはタブ幅4、それ以外は2

## シンボリックリンク作成

- Windows

```powershell
New-Item -ItemType SymbolicLink `
    -Path "$HOME\_vimrc" `
    -Target "$HOME\path\to\vimrc\vimrc"
```

- Mac

```bash
ln -s ~/path/to/vimrc/vimrc ~/.vimrc
```
