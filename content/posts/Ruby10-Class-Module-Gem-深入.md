---
title: "Ruby10 Class Module Gem 深入"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby10 Class Module Gem 深入-ruby10classmodulegem深入"
date: "2018-02-20 14:24:00"
---



## Agenda

  1. class\_eval & instance\_eval
  2. method_missing
  3. Module as a namespace
  4. Gems
  5. require vs load
  6. $LOAD_PATH

### class_eval

  1. 首先class\_eval是只有类才能调用的，Class#class\_eval
  2. class_eval会重新打开当前类的作用域

    # class_eval
    class User
    end
    User.class_eval do
      attr_accessor :name
      def hello
        "hello"
      end
    end
    user = User.new
    user.name = "world"
    puts user.name
    puts user.hello
    

    # module"s self
    module Management
      def self.track
        "track"
      end
    end
    class User
      include Management
    end
    # User.track # => error
    Management.track
    

    # class_eval in project
    # requirement: we need to execute a class method when module included
    module Manegement
      def self.included base #Manafement模块被其他类Included的时候会执行
        base.extend ClassMethods #User类注入ClassMethod
        base.class_eval do #打开User类
          setup_attribute
        end
      end
     # Manegement 内部模块 当引入Management的时候 会被引用为其他类的类方法
      module ClassMethods
        def setup_attribute
          puts "setup_attribute"
        end
      end
    end
    class User
      include Manegement #目的是在include Management 的时候执行一些方法或者设置
    end
    

### instance_eval

  1. instance_eval 是所有类实例的方法
  2. 打开的是当前实例作用域

    # instance_eval, instance methods and class methods
    # 1. as a question
    class User
    end
    User.class_eval do
      def hello
        "hello"
      end
    end
    User.instance_eval do
      def hi
        "hi"
      end
    end
    puts User.hi
    user = User.new
    puts user.hello
    # puts user.hi #报错

    # instance_eval, singleton_method
    a = "xxx"
    a.instance_eval do
      def to_hello
        self.replace("hello")
      end
    end
    puts a.to_hello
    # b = "world"
    # b.to_hello # => error

    # class_eval as instance_eval
    class User
    end
    User.class_eval do
      def hello
        "hello"
      end
      # works same as instance_eval
      def self.hi
        "hi"
      end
    end
    puts User.new.hello
    puts User.hi

### method_missing

  1. 当当前作用域上下文没有找到方法时就会调用
  2. method_missing方法

    # metho missing
    #
    # 1. how it works
    # 2. ancestors
    # 3. rails"s AR
    class User
      def hello
        "hello from User"
      end
      def method_missing(name, *args)
        "method name is #{name} ,parameters :#{args}"
      end
    end
    user = User.new
    puts user.hello
    puts "-" * 30
    puts user.hi("hello",19)
    

### Namespace

  1. Module
  2. Class
  3. Constants

使用`::`来访问

    # module as a namespace
    module Management
      COMPANY_NAME = "Hello World Company"
      module Track
        def track
          "track from Track module"
        end
      end
      class User
        def hello
          "hello from User class"
        end
      end
    end
    puts Management::COMPANY_NAME
    puts "-" * 30
    include Management::Track
    puts track

## Gems

  1. Ruby的包管理工具，类似于linux的rpm,deb,python的pip,Node的npm,c#的nuget
  2. 社区中Gem包涵盖了各方面开发所需要的工具和组件
  3. 通过gem命令来安装

### gem命令

  1. gem list
  2. gem install
  3. gem uninstall
  4. gem sources

关于墙内安装问题，可以使用ruby china的镜像地址

    gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/

### bundle gem

  1. gem本身会有版本依赖问题
  2. bundle是一个gem，被用来管理其他gems
  3. bundle类似于linux的yum apt等等，是一个gems关系管理工具

### bundle的基本使用

  1. gem install bundler
  2. Gemfile 文件
  3. bundle install/update/show/list

## require vs load

相同点

  1. 都会在$LOAD_PATH下面查找当前要引入的文件

不同点

  1. require 调用文件时不需要`.rb`的文件后缀，而load需要
  2. require 针对童谣的文件只会调用一次，而load会反复调用

    # require vs load
    # 1. print require and load result
    # require "net/http"
    puts require "net/http" # => true
    puts require "net/http" # => false
    # puts load "net/http.rb"
    puts Net::HTTP

### $LOAD_PATH

  1. ruby代码的查找路径为当前的$LOAD_PATH环境变量
  2. ruby文件名命名规则: 文件的名字代表了当前 `class/module`的名字

    # load_path
    # require "track"