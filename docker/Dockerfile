FROM amazonlinux:2023.4.20240401.1 AS base

FROM base as preinstall
ARG RUBY_VERSION
ARG BUNDLER_VERSION
ARG DOCKER_USER
ARG DOCKER_USER_PASS
ARG DEFAULT_BRANCH
RUN dnf install -y \
  # yarnインストール(webpacker用)
  wget \
  && wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo \
  && dnf install -y \
  # 日本語パッケージインストール
  langpacks-ja.noarch \
  # sudoコマンドを使用可能にする
  sudo \
  # Dockerイメージ転送用 
  tar gzip  \
  # ruby-build用必須ライブラリ追加
  gcc patch bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel \
  # sassc用ライブラリ
  gcc-c++ \
  # webpacker用ライブラリ
  nodejs \
  # 開発用ライブラリ追加
  git tree which \
  # mysqlクライアント(see: https://dev.classmethod.jp/articles/install-mysql-client-to-amazon-linux-2023/)
  # https://dev.mysql.com/downloads/repo/yum/ が最新
  && dnf localinstall -y https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm \
  && dnf install -y mysql mysql-community-devel \
  && dnf clean all

FROM preinstall as add_user

RUN useradd -mU ${DOCKER_USER} \
  # sudo設定追加
  && echo '${DOCKER_USER} ALL=(ALL:ALL) ALL' | EDITOR='tee -a' visudo \
  # sudo権限を付与
  && gpasswd -a ${DOCKER_USER} ${DOCKER_USER} \
  # sudo可能なグループに所属させる。
  && usermod -aG wheel ${DOCKER_USER} \
  # パスワードを設定
  && echo "${DOCKER_USER}:${DOCKER_USER_PASS}" | chpasswd

FROM add_user as change_user

USER ${DOCKER_USER}

WORKDIR /home/${DOCKER_USER}/undecided_game_project

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
  && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc \
  && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
  && source ~/.bashrc \
  && mkdir -p "$(rbenv root)"/plugins \
  && git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build \
  && rbenv install ${RUBY_VERSION} \
  && rbenv global ${RUBY_VERSION} \
  && gem install bundler -v ${BUNDLER_VERSION} \
  && bundle config set path "vendor/bundle" \
  && bundle config set clean "true" \
  && git config --global init.defaultBranch ${DEFAULT_BRANCH} \
  && git init \
  # SSH設定は後ほどするので、ひとまずhttpsでのアクセスとする。
  && git remote add origin https://github.com/Kabenonakaniiru/UndecidedGameProject.git \
  && git pull origin ${DEFAULT_BRANCH} \
  && git branch --set-upstream-to=origin/${DEFAULT_BRANCH} ${DEFAULT_BRANCH} \
  && cp -p .env.sample .env
# TODO: git config --global user.name <name>
# TODO: git config --global user.email <name>

FROM change_user as dev

EXPOSE 3000