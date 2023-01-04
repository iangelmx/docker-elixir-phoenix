FROM ubuntu:20.04
LABEL maintainer="angel@ninjacom.space"
ARG DEBIAN_FRONTEND=noninteractive

ENV ERLANG_VERSION=22.3.4.22
ENV ELIXIR_VERSION=1.12.3-otp-22
ENV NODE_VERSION=14.17.6
ENV PHOENIX_VERSION=1.5.14

## Adds required deps
RUN apt update
RUN apt install -y curl git
RUN apt install -y wget build-essential autoconf m4 libncurses5-dev libssh-dev unixodbc-dev
## GNOME XML
RUN apt install -y xsltproc fop libxml2-utils libsctp-dev lksctp-tools
# Adds WKHTMLTOPDF
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN mv wkhtmltox/bin/wkhtmlto* /usr/bin/
RUN rm -rf wkhtmltox
## Adds asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf
RUN cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)"
ENV PATH /root/.asdf/bin:/root/.asdf/shims:${PATH}
RUN /bin/bash -c "source ~/.bashrc"

## Adds Erlang
RUN /bin/bash -c "asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git"
ENV KERL_CONFIGURE_OPTIONS --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx --disable-debug --without-javac --enable-darwin-64bit
RUN /bin/bash -c "asdf install erlang $ERLANG_VERSION"
RUN apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN /bin/bash -c "asdf global erlang $ERLANG_VERSION"

## Adds Elixir
RUN /bin/bash -c "asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git"
RUN /bin/bash -c "asdf install elixir $ELIXIR_VERSION"
RUN /bin/bash -c "asdf global elixir $ELIXIR_VERSION"

## Adds Nodejs
RUN /bin/bash -c "asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git"
RUN /bin/bash -c "asdf install nodejs $NODE_VERSION"
RUN /bin/bash -c "asdf global nodejs $NODE_VERSION"

## Final configurations
RUN apt-get install -y inotify-tools
RUN /bin/bash -c "mix local.hex --force"
RUN /bin/bash -c "mix local.rebar --force"
RUN /bin/bash -c "mix archive.install --force hex phx_new $PHOENIX_VERSION"
