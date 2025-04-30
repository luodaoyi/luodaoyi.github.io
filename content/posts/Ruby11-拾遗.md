---
title: "Ruby11 拾遗"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby11 拾遗-ruby11拾遗"
date: "2018-02-20 14:55:00"
---



## Agenda

  1. Loop
  2. Expression
  3. File Read/Write
  4. Debug
  5. Process & Thread

### Loop

while

    a = 10
    while a > 0
      puts a
      a -= 1
    end

until

    a = 100
    until a == 0
      puts a
      a -= 1
    end

loop

    a = 10
    loop do
      break if a  0

`!~` 正则匹配 是否匹配不到 匹配到返回fals 匹配不到返回true

    /666/i !~ "hello world" # => true

`alias` 别名

    def hello
      "hello"
    end
    alias old_hello hello
    def hello
      "new hello"
    end
    puts old_hello
    puts hello

## File Read/Write 文件读写

  1. `File.read`
  2. `File.readlines`
  3. `File#rewind etc`
  4. `IO.read/write`

File Read

    file = File.open("run.log", "r")
    while line = file.gets
      puts line
    end

File Write

    file = File.open("run.log", "a+")
    file.puts "hello"
    file.close

    File.open("run.log", "a+") do |f|
      f.puts "hello"
    end

## Debug

Debug 工具

  1. ruby debugger
  2. byebug

byebug

    $ gem install byebug

    require "byebug"
    def hello name
      byebug #此处会有断电，然后可以看上下文的变量
      puts name
    end
    hello "world"

## Process & Thread 进程和线程

Process

    pid = Process.fork{
      #...
    }

Thread

    Thread.new{
      #...
    }