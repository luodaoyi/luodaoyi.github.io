---
title: "Ruby2 Method and Block"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby2 Method and Block-ruby2methodandblock"
date: "2018-02-16 21:55:00"
---



## Method(Function)


```ruby
def hi(name)
    p "hi " + name
end
hi("666") # => "hi 666"
hi "code" #括号省略  => "hi code"
def hello name
    p "hello #{name}"
end
hello "world" # => "hello world"
```


### Method 参数


```ruby
def hi name="code"
    p "hi " +name
end
hi # => "hi code"
def hi name,age=32
    p "#{name} is #{age}"
end
hi "code" # => "code is 32"
hi "code", 54 # => "code is 54"
```


### Method 返回值

凡有方法都有返回值，方法体最后一行代码的返回值默认会做为方法的返回值，也可以显式的使用return关键字


```ruby
def hi
    p "ok"
end
hi # =>nil
def hi
    "ok"
end
hi #=> "ok"
def hi
    return "2"
    1
end
hi # => 2
```


## Block

Block类似于一个方法，可以使用do/en来定义，也可以使用大括号{}


```ruby
File.open("access.log","w+") do |f|
    f.puts "line 1"
end
```


### Block内置方法


```ruby
[1, 2, 3].each do |x|
    p x
end
{a:1,b:2}.each do |x, y|
    p y
end
```


### Block变量作用域


```ruby
#ruby 2.0之前外部变量x的值会被block修改
x = 10
[1, 2, 3].each do |x|
    p x
end
x # =>10
```


### 自定义block


```ruby
def hi name
    yield(name)
end
hi("code"){ |x|
    "hello #{x}"
}
```


yield 为调用外部block的关键字(个人感觉比较像C#的委托调用)

### proc


```ruby
hi = proc{|x| "hello #{x}"}
hi.call("world")
# 等同于
hi = Proc.new {|x| "hello #{world}"}
hi.call("world")
```


proc相当于定义了一个方法变量，可以吧方法当做参数传递（个人感觉比较像C#的委托）

### lambda

lambda和proc非常相似


```ruby
hi =lambda {|x| "hello #{x}"}
hi.call("world")
```


研究lambda和proc的区别

  1. Proc和Lambda都是对象，而Block不是
  2. 参数列表中最多只能有一个Block，但是可以有多个Proc或Lambda
  3. Lambda对参数的检查很严格，而Proc则比较宽松
  4. Proc和Lambda中return关键字的行为是不同的