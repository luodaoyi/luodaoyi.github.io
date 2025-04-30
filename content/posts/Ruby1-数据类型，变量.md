---
title: "Ruby1 数据类型，变量"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby1 数据类型，变量-ruby1数据类型变量"
date: "2018-02-16 21:55:00"
---



  1. 整数类型: `3,222`
  2. 小数: `3.14`
  3. 字符串: `hello,world`
  4. 布尔类型: `true(TrueClass),false(FalseClass)`
  5. 数组: `[1,2],["hello","hello world"]`
  6. Hash(字典): `{"name"=>"luo","age"=>24},{:name=>"daoyi",:age=>24}`
  7. Symbol(符号): `:a,:hello,:"hello world"`
  8. Range: `1..10,1...10`(三个点不包括10本身)
  9. 正则: `/hello/i`

## String 字符串


```ruby
a = "hello" #=> hello
b = "world" #=> world
a.class #=> String
a + " " + b #=> hello world
"#{a} #{b}" #=> hello world
```


### string method


```ruby
"hello world".length #=>11
"hello world".capitalize #=> Hello world
"hello world".gsub("world","gril").upcase #=> HELLO GIRL
```


## 变量赋值


```ruby
a = "hello" # => hello
a.object_id # => 70353313681980
a.replace("hello2") # => "hello2"
a.object_id # => 70353313681980
a = "hello"
a.object_id # => 70353313549380
```


当a 使用replace时候仍然是原本的引用地址，所以Object_id不变  
但是当a重新赋值为hello 的时候，a的引用地址发生了变化 object_id就改变了

## 以!结尾的方法


```ruby
a = "hello" # => hello
a.capitalize # => Hello
a # => hello
a.capitalize! #=> Hello
a # => Hello
```


  1. ！结尾的方法会改变变量资深
  2. 这只是个约束
  3. 在Rails中！的方法也被用来表示该方法会抛出异常

## 以？结尾的方法


```ruby
a = "hello" # => hello
a.is_a?(String) #=> true
```


  1. ？的方法会返回true|false
  2. 这只是一个约束

## nil

什么是nil


```ruby
a = nil # => nil
a.nil? # => true
```


在ruby中nil和false都是不成立的意思，或者否的意思 其他一切都为true

## 双引号和单引号


```ruby
a = "hello" # => hello
b = "hello" # => hello
a == b # => true
c = "world" # => world
a = "hello #{c}" # => hello world
a = "hello #{c}" # => hello \#{c}
```


双引号中的变量会被解释,单引号不会  
反引号，直接运行shell命令

## Array


```ruby
a = [1,2,"hello"] # => [1,2,"hello"]
a.length # =>3
```


数组中可以放置任意类型

### array常用方法


```ruby
a = [1,2,"hello"]
a.length # =>3
a.size # =>3
a.first # =>1
a.last # =>hello
b = ["world"] # => ["world"]
c = a + b # => [1,2"hello","world"]
b *3 # => ["world","world","world"]
c - a # =>["world"]
```


这些方法并不会改变数组本身


```ruby
a = [] # => []
a.push(1) # => [1]
a.push(2) # => [1,2]
a.unshift(3) # => [3,1,2]
a.pop # => 2
a.shift # => 3
a #=> 1
```


所有这些方法都会改变数组本身

Array 奇技淫巧


```ruby
a = [] # =>[]
a [3]
a.concat([4,5]) # => [3,4,5]
a.index(4) #=> 1
a[0] = 1 # => 1
a.max # => 5 
```


## ruby中的方法


```ruby
a = 1 # => 1
a + 2 # => 3 
```


在这里+ 只是一个方法，2是传递给方法的参数  
可以解释为 a 拥有 `+`这样一个方法 2收传递给+方法的参数

## Hash


```ruby
a = {"name" => "luo","age"=>24,"hobbies" => ["coding","video game","music"]}
a["name"] # => "luo"
```


hash是无序的，数组是有序的

### Hash 常用方法


```ruby
a = {"name" => "luo","age"=>24,"hobbies" => ["coding","video game","music"]}
a.keys # => ["name", "age", "hobbies"]
a.values # => ["luo", 24, ["coding", "video game", "music"]]
a.delete("hobbies") # => ["coding", "video game", "music"]
a["cellphone"] = "16666666666" # => "16666666666"
```


### Hash的其他定义方式


```ruby
a ={name:"luo",age:24,hobbies:["coding","video game","music"]}
# => {:name=>"luo", :age=>24, :hobbies=>["coding", "video game", "music"]}
```


Json的定义方式，顺应web前端的发展趋势

## Symbol


```ruby
a = :hello # => :hello
b = "#{a} world" # => "hello world"
c = :"hello world" # => :"hello world"
c.object_id # => 1160948
c = :"hello world" # => :"hello world"
c.object_id # => 1160948
```


Symbol是String的补充，可以看做为字符串来使用，但是Symbol和String在本质上还是不同的，在 Ruby中Symbol经常被用来作为hash的key和一些变化不频繁的字符串来使用

### Symbol和hash


```ruby
a ={:name => "luo",:age=>24,:hobbies =>["coding","video game","music"]}
a[:name] # => "luo"
```


## Range


```ruby
a = 1..10 # => 1..10
a.to_a.size # => 10
b = 1...10 # => 1...10
b.to_a.size # => 9
c = :a..:z # => :a..:z
d = a.to_a + c.to_a
# => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o, :p, :q, :r, :s, :t, :u, :v, :w, :x, :y, :z]
```


## Regular Expression 正则类型


```ruby
a =/hello/ # => /hello/
"hello world" =~ a  # => 0
email_re = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i # => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
email_re.match("111@qq.com") # => #
```