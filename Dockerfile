FROM ubuntu:20.04
LABEL maintainer="Yasuhiro OSAKA(fallingfluit.gmail.com)"

SHELL ["/bin/bash", "-c"]
ARG UNAME=ubuntu
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND "noninteractive"
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    python3-dev \
    python3-tk \
    python3-pip \
    language-pack-ja-base \
    language-pack-ja \
    locales \
    screen \
    htop \
    sudo
RUN locale-gen ja_JP.UTF-8

## install dependencies for pyenv and neovim
RUN apt-get install -y \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    liblzma-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    git \
    nodejs \
    npm

## install neovim
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:neovim-ppa/stable
RUN apt-get update && apt-get install -y neovim

## install n(virtual node environment)
RUN npm install -g n
RUN n latest

## create user
RUN groupadd -g $GID $UNAME && \
    useradd -m -s /bin/bash -u $UID -g $GID $UNAME && \
    echo $UNAME:$UNAME | chpasswd && \
    echo "$UNAME ALL=(ALL) NOPASSED:ALL" >> /etc/sudoers

USER $UNAME
WORKDIR /home/$UNAME
ENV HOME /home/$UNAME
RUN ls -a
## install pyenv
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin/:$PATH
RUN git clone https://github.com/pyenv/pyenv.git /home/$UNAME/.pyenv && \
    echo 'eval "$(pyenv init -)"' >> $HOME/.bashrc && \
    git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv &&\
    echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc && \
    pyenv install 2.7.17 && pyenv install 3.8.2 && \
    pyenv virtualenv 2.7.17 vim2 && pyenv virtualenv 3.8.2 vim

RUN pyenv global vim2 && pip install -U pip && pip install pynvim && \
    pyenv global vim && pip install -U pip && pip install pynvim && \
    pyenv global system

## install vim dependencies
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN git clone https://github.com/yosakax/dotfiles.git $HOME/.dotfiles
RUN ls -l $HOME/ && mkdir -p $HOME/.config/nvim && ln -s $HOME/.dotfiles/init.vim $HOME/.config/nvim/init.vim
