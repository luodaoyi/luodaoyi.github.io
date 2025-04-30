---
title: "Ruby5 其他的奇技淫巧"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby5 其他的奇技淫巧-ruby5其他的奇技淫巧"
date: "2018-02-17 04:01:00"
---



## 变量赋值

    # 变量交换
    a = 1
    b = 2
    b,a = a,b
    puts a
    puts b
    puts "-" * 30
    x = [1, 2, 3]
    a, b = x #默认会把数组中的值依次赋值给 a ,b
    puts a
    puts b
    puts "-" * 30
    x = [1, 2, 3]
    a, *b = x #这里a会接受第一个元素 b用了*号 表示接受剩下所有的元素
    puts a
    p b
    #output
    2
    1
    ------------------------------
    1
    2
    ------------------------------
    1
    [2, 3]

## Fixnum & Float

    # number
    puts 1 / 10
    puts 1 / 10.0
    puts "-" * 30
    #output
    0.1
    ------------------------------

## String

    # string
    a = "world"
    b = %Q{
        hello
        #{a}
    }
    # 这里不但可以用 {} 也可以用 ()
    # 但是这里的Q必须是大Q 如果是小q的话 就相当于单引号的效果
    puts b
    puts "-" * 30