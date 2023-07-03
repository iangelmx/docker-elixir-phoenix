FROM ubuntu:20.04
LABEL maintainer="angel@ninjacom.space"
ARG DEBIAN_FRONTEND=noninteractive

ENV ERLANG_VERSION=24.3.4.11
ENV ELIXIR_VERSION=1.14.5-otp-24
ENV NODE_VERSION=14.17.6
ENV PHOENIX_VERSION=1.5.14

## Adds required deps
RUN apt-get update
RUN apt-get install -y curl git
RUN apt-get install -y wget build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev libsctp-dev lksctp-tools
# Adds WKHTMLTOPDF
RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb
RUN sudo apt-get install -y ./wkhtmltox_0.12.6-1.focal_amd64.deb
## Adds asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf
RUN cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)"
ENV PATH /root/.asdf/bin:/root/.asdf/shims:${PATH}
RUN /bin/bash -c "source ~/.bashrc"

## Adds Erlang
RUN /bin/bash -c "asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git"
ENV KERL_CONFIGURE_OPTIONS --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx --disable-debug --enable-darwin-64bit
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
