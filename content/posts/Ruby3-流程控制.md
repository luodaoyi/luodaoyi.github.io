---
title: "Ruby3 流程控制"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby3 流程控制-ruby3流程控制"
date: "2018-02-16 22:52:00"
---



## if/else/elsif


```ruby
a = "hello"
b = false
if a
    p a
elsif b
    p b
else
    p "ok"
end
```


## unless

unless相当于if的反向断言
```ruby
    unless false
        "ok"
    end
    # => "ok"

## if/unless

    a = 1 if a != 1 #如果a不是1 则a复制为1
    b = 2 unless defined?(b) #如果b未定义 那么就定义b赋值为2

## case

    case a
    when 1
        1
    when /hello/
        "hello world"
    when Array
        []
    else
        "ok"
    end

## while

    a = 0
    while a < 100 do
        p a
        a += 1
    end
```

ruby 没有++和&#8211;操作符

## Iterators

```ruby
    for x in [1, 2, 3] do
        p x
    end
    [1, 2, 2].each do |x|
        p x
    end
    10.times {|x| p x}
```