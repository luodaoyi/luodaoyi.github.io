---
title: "Ruby7 OOP"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby7 OOP-ruby7oop"
date: "2018-02-17 11:43:00"
---



## Everything is Object 一切皆对象

```ruby

    a = "hello"
    a.class # => String
    b = 3.14
    b.class # => Float
    c = %w[pear cat horse]
    c.class # => Array
```

## Instance Method & Instance Attribute 实例方法，实例属性

  1. Instance Method: 实例方法，成员方法，成员函数
  2. Instance Attribute: 实例变量，成员属性，属性(property)，使用@定义
```ruby
    # class
    class User
      def initialize name, age
        @name = name
        @age = age
      end
      # getter
      def name
        @name
      end
      def age
        @age
      end
    end
    user = User.new("Hello", 18)
    puts user.name
    puts user.age

    # class
    class User
      def initialize name, age
        @name = name
        @age = age
      end
      # getter
      def name
        @name
      end
      def age
        @age
      end
      # setter
      def name= name
        @name = name
      end
      def age= age
        @age = age
      end
    end
    user = User.new("Hello", 18)
    puts user.name
    puts user.age
    puts "-" * 30
    user.name = "hello 2"
    user.age = 20
    puts user.name
    puts user.age
    

    # class, attr_reader, attr_writer
    class User
      attr_reader :name
      attr_reader :age
      attr_writer :name
      attr_writer :age
      def initialize name, age
        @name = name
        @age = age
      end
    end
    user = User.new("Hello", 18)
    puts user.name
    puts user.age
    puts "-" * 30
    user.name = "hello 2"
    user.age = 20
    puts user.name
    puts user.age
    

    # class, method
    class User
      attr_accessor :name
      attr_accessor :age
      def initialize name, age
        @name = name
        @age = age
      end
      def say_hi
        puts "hello  #{@name}, i am #{@age}"
      end
    end
    user = User.new("Hello", 18)
    user.say_hi
```

## Class Method & Class Variable 类方法，类变量

  1. Class Method:类方法，静态方法
  2. Class Variable:类变量, 使用@@定义
```ruby
    # class, method
    class User
      attr_accessor :name
      attr_accessor :age
      @@counter = 0
      def initialize name, age
        @name = name
        @age = age
        @@counter += 1
      end
      def say_hi
        puts "hello  #{@name}, i am #{@age}"
      end
      def self.get_counter
        @@counter
      end
    end
    puts User.get_counter
    user = User.new("Hello", 18)
    user.say_hi
    puts User.get_counter

## Access Control 访问控制

  1. public
  2. protected
  3. private

    # class, method
    class User
      attr_accessor :name
      attr_accessor :age
      def initialize name, age
        @name = name
        @age = age
      end
      def say_hello
        puts "hello..."
        say_hi
        say_hey
      end
      def say_hi
        puts "hello  #{@name}, i am #{@age}"
      end
      def say_hey
        puts "hey, i am #{@name}"
      end
      protected :say_hi, :say_hey
    end
    user = User.new("Hello", 18)
    user.say_hello
```
## Dynamic Ruby 动态特性

### User内幕
```ruby
    # attr_accessor 方法从哪里来的？
    class User
      # ...
    end
    User.class # => class
    # Class.attr_accessor 背后的秘密
    # define_method
    # attr_accessor, define_method
    define_method :hello do
      puts "hello world"
    end
    hello
```
自己实现 attr_accessor
```ruby
    # define_method
    class User
      # attr_accessor :name
      # attr_accessor :age
      def self.setup_accessor var
        define_method var do
          instance_variable_get "@#{var}"
        end
        define_method "#{var}=" do |value|
          instance_variable_set "@#{var}", value
        end
      end
      setup_accessor :name
      setup_accessor :age
      def initialize name,age
        @name = name
        @age = age
      end
    end
    user = User.new "hello", 18
    puts user.name
    puts "-" * 30
    user.name = "hello 2"
    puts user.name
```