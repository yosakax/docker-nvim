FROM ubuntu:24.04
LABEL maintainer="Yasuhiro OSAKA(fallingfluit.gmail.com)"

SHELL ["/bin/bash", "-c"]
ARG UNAME=ubuntu
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y \
  python3-dev \
  python3-tk \
  python3-pip \
  python3-venv \
  language-pack-ja-base \
  language-pack-ja \
  locales \
  screen \
  htop \
  sudo \
  bash-completion
ENV TZ=Asia/Tokyo
RUN locale-gen ja_JP.UTF-8

## install dependencies for pyenv and neovim
RUN apt-get install -y \
  curl \
  git  \
  unzip \
  # lua5.1  \
  luarocks \
  build-essential 
# libffi-dev \
# libssl-dev \
# zlib1g-dev \
# liblzma-dev \
# libbz2-dev \
# libreadline-dev \
# libsqlite3-dev \
# git \
# nodejs \
# npm

## set locale
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
  LANGUAGE="ja_JP:ja" \
  LC_ALL="ja_JP.UTF-8" \
  TZ="Asia/Tokyo"


## create user
RUN echo "ubuntu:ubuntu" | chpasswd
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R ubuntu:ubuntu /home/ubuntu
RUN usermod -aG sudo ubuntu
RUN chsh -s /bin/bash ubuntu
ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN apt-get autoclean

USER ${UNAME}
WORKDIR /home/${UNAME}
ENV LANG=ja_JP.UTF-8
ENV SHELL=/bin/bash
ENV HOME=/home/${UNAME}

# miseのインストール
RUN curl https://mise.run | bash

# bashrcにmiseを読み込ませる
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
RUN echo 'eval "$(~/.local/bin/mise activate bash)"' >> $HOME/.bashrc 

# miseからneovimの最新版をインストール
RUN ~/.local/bin/mise use -g neovim@latest
RUN echo 'export vim="nvim"' >> $HOME/.bashrc

# miseからnodejsのltsをインストール
RUN ~/.local/bin/mise use -g node@lts
RUN  eval "$($HOME/.local/bin/mise activate bash)" && npm install -g neovim 

# denoのインストール
RUN curl -fsSL https://deno.land/install.sh | sh
RUN echo 'export PATH="$HOME/.deno/bin:$PATH"' >> $HOME/.bashrc

# git clone https://github.com/yosakax/dotfiles.git する
RUN git clone https://github.com/yosakax/dotfiles.git $HOME/dotfiles

# init.luaとpythonの環境を作成
RUN mkdir -p $HOME/.config/nvim && \
  ln -s  ${HOME}/dotfiles/init.lua ${HOME}/.config/nvim/init.lua && \
  python3 -m venv $HOME/.config/nvim/python-nvim
RUN ${HOME}/.config/nvim/python-nvim/bin/pip install pynvim



RUN echo "PS1='\[\e[37;45m\] \u \[\e[35;47m\]\[\e[30;47m\] \W \[\e[37;46m\]\[\e[30m\] $(__git_ps1 "(%s)") \[\e[36;49m\]\[\e[0m\]\n $ '" >> $HOME/.bashrc
