---
title: "Ruby4 Blocks and Exceptions"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby4 Blocks and Exceptions-ruby4blocksandexceptions"
date: "2018-02-17 00:06:00"
---



## Block 代码块

  1. Block是一个参数
  2. 匿名参数
  3. Callback
  4. 使用do/en或者{}来定义

    {puts "hello"}

Demo:

    # block usage
    def hello
        puts "hello method start"
        yield
        yield
        puts "hello method end"
    end
    hello {puts "i am in block"}
    #output
    hello method start
    i am in block
    i am in block
    hello method end
    

    # yield with parameter
    def hello
        puts "hello method start"
        yield("hello","world")
        puts "hello method end"
    end
    hello {|x,y| puts "i am in block,#{x} #{y}"}
    #output
    hello method start
    i am in block,hello world
    hello method end

    # yield with paramter
    def hello name
        puts "hello method start"
        result = "hello " + name
        yield(result)
        puts "hello method end"
    end
    hello("world"){|x| puts "i am in block,i got #{x}"}
    #output
    hello method start
    i am in block,i got hello world
    hello method end

    # build in methods
    ["cat", "dog","frog"].each do |animal|
        puts animal
    end
    puts "-" * 30
    ["cat","dog","frog"].each{|animal| puts animal}
    #output
    cat
    dog
    frog
    ------------------------------
    cat
    dog
    frog
    

    # build in methods
    10.times do |t|
        puts t
    end
    puts "-" * 30
    ("a".."d").each { |char| puts char}
    #output
    1
    2
    3
    4
    5
    6
    7
    8
    9
    ------------------------------
    a
    b
    c
    d

    # varibale scope
    # before ruby2.0
    x = 1
    [1, 2, 3].each { |x| puts x}
    puts x # => x will be 3,which is incorrect
    #output
    1
    2
    3
    1
    如果是在ruby2之前的版本 那么外部的变量x会被改变

    # varibale scope
    # 如果是2.0版本之后 puts x会报错
    sum = 0
    [1, 2, 3].each { |x| sum += x}
    puts sum
    # puts x
    #output
    6

    # block return value
    class Array
        def find
            each do |value|
                return value if yield (value)
            end
            nil
        end
    end
    puts [1, 2, 3].find { |x| x == 2 }
    #output
    2

    # block as named parameter
    def hello name, &block
        puts "hello #{name}, from method"
        block.call(name)
    end
    hello("world") {|x| puts "hello #{x} form block"}
    #output
    hello world, from method
    hello world form block

    # yield with parameter
    def hello
        puts "hello method start"
        yield("hello","world")
        puts "hello method end"
    end
    hello {|x,y| puts "i am block ,#{x},#{y}"}
    #output
    hello method start
    i am block ,hello,world
    hello method end

    # block_given?
    def hello
        if block_given?
            yield
        else
            puts "hello from method"
        end
    end
    hello
    puts "-" * 30
    hello {puts "hello from block"}
    #output
    hello from method
    ------------------------------
    hello from block

    # block can be closure
    def counter
        sum = 0
        # 代码库接收了一个参数x 如果x没有定义那么x为1 然后 sum +=x
        proc {|x| x = 1 unless x; sum +=x }
    end
    c2 = counter
    puts c2.call(1) #1
    puts c2.call(2)
    puts c2.call(3)
    # 这里 closure 为闭包
    #
    #output
    1
    3
    6

    # new method to create block
    # name is required
    hello = -> (name){"hello #{name}"}
    puts hello.call("world")
    puts "-" * 30
    # name is required
    hello3 = lambda {|name| "hello #{name}"}
    puts hello3.call("world")
    puts "-" * 30
    hello2 = proc {|name| "hello #{name}"}
    puts hello2.call
    puts hello2.call("world")
    # lambda和proc区别 proc可以不传参数 lambda 更像是一个方法，必须传递参数
    #output
    hello world
    ------------------------------
    hello world
    ------------------------------
    hello
    hello world

## Exceptions 异常

All Exception inherited from `Exception Class`

> 所有异常都继承自`Exception`类

常见Exception

  1. StandardError
  2. SyntaxError
  3. RuntimeError
  4. ArgumentError
  5. NameError
  6. etc.

### ruby抓取Exception

    # exception
    def hello name
        raise name #抛出异常
    end
    hello # =>ArgumentError
    hello("world") # =>RuntimeError

    # exception catch
    def hello
        raise
    end
    begin
        hello
    rescue RuntimeError
        puts "got it"
    end

    # exception catch
    def hello
        raise
    end
    begin
        hello
    rescue => e #出现异常捕获给e
        puts "catch exception with name :#{e.class}"
    else #没有发生异常
        # ...
    ensure #确保不论有没有发生异常
        # ...
    end