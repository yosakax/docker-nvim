# docker-nvim

init.luaをまっさらな状態から作り直す際にするコンテナ。

## how to use

Dcokerfile上で，nodejsとpythonがインストール済みです。pythonはubuntuのシステムのものを使っているのに対して，nodeはバージョンを指定して入れているので，適宜変更してください。

neovimも`https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz`をダウンロードしてきているので，任意のバージョンを入れる際はURLを変更してください。

### コンテナの起動方法

```bash
docker compose up -d
```
