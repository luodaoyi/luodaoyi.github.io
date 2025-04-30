---
title: "ubuntu 上的ruby安装"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "ubuntu 上的ruby安装-ubuntu上的ruby安装"
date: "2017-03-12 06:13:13"
---



## 安装 rbenv

    git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
    # 用来编译安装 ruby
    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    # 用来管理 gemset, 可选, 因为有 bundler 也没什么必要
    git clone git://github.com/jamis/rbenv-gemset.git  ~/.rbenv/plugins/rbenv-gemset
    # 通过 gem 命令安装完 gem 后无需手动输入 rbenv rehash 命令, 推荐
    git clone git://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
    # 通过 rbenv update 命令来更新 rbenv 以及所有插件, 推荐
    git clone git://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
    # 使用 Ruby China 的镜像安装 Ruby, 国内用户推荐
    git clone git://github.com/AndorChen/rbenv-china-mirror.git ~/.rbenv/plugins/rbenv-china-mirror

然后把下面的代码放到 `~/.bash_profile` 里

    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"

注意 Unubtu请放到 `~/.bashrc` 里, zsh用户是 `~/.zshrc`

# 使用

## 安装 ruby

    rbenv install --list  # 列出所有 ruby 版本
    rbenv install 1.9.3-p392     # 安装 1.9.3-p392
    rbenv install jruby-1.7.3    # 安装 jruby-1.7.3

## 列出版本

    rbenv versions               # 列出安装的版本
    rbenv version                # 列出正在使用的版本

## 设置版本

    rbenv global 1.9.3-p392      # 默认使用 1.9.3-p392
    rbenv shell 1.9.3-p392       # 当前的 shell 使用 1.9.3-p392, 会设置一个 `RBENV_VERSION` 环境变量
    rbenv local jruby-1.7.3      # 当前目录使用 jruby-1.7.3, 会生成一个 `.rbenv-version` 文件