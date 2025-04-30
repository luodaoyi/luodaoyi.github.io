---
title: "Ruby6 细节补充"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby6 细节补充-ruby6细节补充"
date: "2018-02-17 11:42:00"
---



## 代码规范

  1. 使用UTF-8编码
  2. 使用空格缩进，不使用tab, 1 tab = 2 spaces
  3. 不需要使用分号(;)和反斜杠()连接代码

Demo

    # basic types
    a = 1
    b = "hello world"
    # one line
    c = ["pear", "cat", "dog"]
    # or multiple lines
    c2 = [
        "pear",
        "cat",
        "dog"
    ]
    d = { name:"world", age:18 }
    d2 = {
        name:"world",
        age:18
    }
    # source layout, conversion
    # with or without()
    def hello(name, age = 18)
        puts "hello #{name}, and age is #{age}"
    end
    def hello name, age = 18
        puts "hello #{name}, and age is #{age}"
    end
    

## 变量类型

  1. local variables 局部变量: a = 1,b = hello
  2. constants 常量: Names = [\&#8217;john\&#8217;,\&#8217;alex\&#8217;]
  3. global variables 全局变量: $platform = \&#8217;mac\&#8217;
  4. instance variables 实例变量: @name = \&#8217;world\&#8217;
  5. class variables 类变量: @@counter = 20

    # variables scope
    # constant
    Name = "world"
    Name = "worlds" # => output wraning
    Name.replace "world_2"  # => safe
    puts Name

    # instance variable and class variable
    class User
        # 相当于定义一个get操作：相当于有一个name的实例变量
        # 使用attr_reader关键字，实现把内部的实例变量 向外部保留一个访问接口
        attr_reader :name
        ## 相当于静态变量
        @@counter = 0
        def initialize name
            @name = name
            @@counter += 1 #记录实例化次数
        end
        def get_counter
            @@counter
        end
    end
    user = User.new "world"
    puts user.name
    puts user.get_counter

    # variables scope
    # global variables
    def hello
        puts $$  #=> process id
        p $: # => ruby loading path
    end
    hello
    

## Boolean表达式

  1. %%, ||, !
  2. And, Or, Not

    #boolean clause
    puts (true and true)
    puts (true and false)
    puts (true or false)
    puts (not true)

    #boolean clause
    a = (false and false || true) # 先|| 再and
    b = (false and false or true) # 优先级相同 先 and 再or
    puts a
    puts b

    #boolean clause
    a = nil
    b = a || 4 # 如果a是成立的(不是false和nim) 那么a赋值给b 否则赋值4给b
    puts b # => 4
    c = b && 5 # 如果b成立那么执行 c = 5
    puts c # => 5
    

    #boolean clause
    # preference
    # and or not 优先级 低于 && || ! =
    a = nil
    b = a or 4 # or 优先级 低于 = 操作符 所以实际吧a赋值给b 然后 or 4
    puts b # => will be nil
    c = b && 5 # b是nil 所有 b&&5 不成立 所以 c =nil
    puts c #=> will be nil

## String,Hash和Array常用方法

    # string
    a = "hello world"
    a.empty? # => false
    a[0] = "a" # => aello world
    a.freeze
    a[0] = "h" # => will raise error
    a = "hello" # =>ok, re-assign value
    

    # string
    a = "hello world"
    a.reverse # => dlrow olleh
    # both of these method have ! version
    a.sub("o", "A") # =>hellA world
    a.gsub("o", "A") # => hellA wArld
    a.start_with? "h" # => true
    a.end_with? "d" # => true
    a.include? "o"

    # string
    a = "hello world"
    b = a.split(" ") # => ["hello", "world"]
    b.join(" ") # => hello world

    # string
    # variable refer
    a = "hello world"
    b = a # 将字符串的引用地址 或者说指针 给了b
    puts b
    b[0] = "A"
    puts a # => Aello world
    puts "-" * 30
    a = "hello world"
    b = a.dup # what"s the difference with String#clone method? 完整复制， 不是引用了
    b[0] = "A"
    puts b  # => Aello world
    puts a  # => hello world
    #output
    hello world
    Aello world
    ------------------------------
    Aello world
    hello world

    # array
    a = ["pear", "cat", "horse"]
    puts a.join(" ") # 数组中必须都是字符串 才可以用字符连接
    a.clear #清空数组
    a.find {|x| x == "horse"} #查找匹配到的
    a.map {|x| x.upcase} # 迭代执行
    a.collect {|x| x.upcase} #map方法的别名
    a.uniq #排除多余重复
    a.flatten #吧二维或者多维转换以为
    a.sort #排序
    a.count #元素数量
    a.delete_if {|x| x == "horse"} #匹配则删除
    a.each {|x| puts x} #遍历

    # hash
    a = {name: "world", age: 18}
    a.each {|key, value| puts key} #遍历
    a.keys # 所有key
    a.values # 所有value
    a.has_key? :name #判断是否有key
    a.delete :name #删除key
    a.delete_if #匹配则删除

## 其他

Buildin Methods

  1. send:private method and method as a variable #调用私有方法，调用的方法名是个遍历的时候 使用send(元编程)
  2. respond_to? #探测实例是否有给定方法
  3. demo

    # send method
    def hello
      puts "hello world"
    end
    send(:hello)

    # respond_to?
    a = "hello world"
    puts a.respond_to?(:length)

## 代码加载机制

### $LOAD_PATH

ruby中的特殊变量 在irb中可以直接输出，当加载模块的时候ruby会在的各个目录中查找加载,如果查找不到会抛出异常

### 命名约束

ruby中每一个文件都是一个独立的文件。文件名和文件中的类名(模块名)对应

    file_name: user_session.rb
    class_name: UserSession