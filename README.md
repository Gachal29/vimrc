# vimrc

vimの設定ファイル

## プラグイン

- NERDTree: 作業ディレクトリ以下のファイルツリーを表示する

起動時に必ず `:PlugInstall` を実行する


### NERDTree インストール

- Windows

```bash
# vim用
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force

# gvim用
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$HOME/vimfiles/autoload/plug.vim" -Force
```

- Mac

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

## シンボリックリンク作成

- Windows

```
New-Item -ItemType SymbolicLink `
    -Path "$HOME\_vimrc" `
    -Target "$HOME\path\to\vimrc\vimrc"
```

- Mac
```
ln -s ~/path/to/vimrc/vimrc ~/.vimrc
```

