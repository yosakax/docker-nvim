FROM ubuntu:22.04
LABEL maintainer="Yasuhiro OSAKA(fallingfluit.gmail.com)"

SHELL ["/bin/bash", "-c"]
ARG UNAME=ubuntu
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND "noninteractive"
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    python3-dev \
    python3-pip \
    python3-venv \
    language-pack-ja-base \
    language-pack-ja \
    locales \
    htop \
    sudo \
    bash-completion
ENV TZ=Asia/Tokyo
RUN locale-gen ja_JP.UTF-8

## install dependencies for pyenv and neovim
RUN apt-get install -y \
    curl \
    build-essential \
    git


WORKDIR /root
RUN curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh &&  apt-get install nodejs -y

## set locale
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8" \
    TZ="Asia/Tokyo"

## create user
RUN useradd -m --uid ${UID} -d /home/${UNAME} --groups sudo  ${UNAME}
RUN echo "${UNAME}:${UNAME}" | chpasswd
RUN echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R ${UNAME}:${UNAME} /home/${UNAME}
RUN usermod -aG sudo ${UNAME}
RUN chsh -s /bin/bash ${UNAME}
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN apt-get autoclean

USER ${UNAME}
WORKDIR /home/${UNAME}
ENV LANG ja_JP.UTF-8
ENV SHELL /bin/bash
ENV HOME /home/${UNAME}

RUN curl -OL https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    tar -zxvf nvim-linux64.tar.gz && \
    echo "export PATH="$PATH:/home/${UNAME}/nvim-linux64/bin"" >> /home/${UNAME}/.bashrc

CMD ["bash"]
