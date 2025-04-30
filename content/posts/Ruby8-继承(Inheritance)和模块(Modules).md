---
title: "Ruby8 继承(Inheritance)和模块(Modules)"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby8 继承(Inheritance)和模块(Modules)-ruby8继承inheritance和模块modules"
date: "2018-02-17 13:02:00"
---



## 继承示例

    # inheritance
    class User
      attr_accessor :name, :age
      def initialize name, age
        @name, @age = name, age
      end
      def panels
        # ||= 操作符， 如果变量不存在 那么就赋值
        @panels ||= ["Profile", "Products"]
      end
    end
    class Admin < User
      def panels
        @panels ||= ["Profile", "Products", "Manage Users", "System Setup"]
      end
    end
    user = User.new("user_1", 18)
    p user.panels
    puts "-" * 30
    admin = Admin.new("admin_1", 28)
    puts admin.name
    p admin.panels
    # 查看这个类的父类
    p Admin.superclass

## 常用關鍵字

super关键字  
调用父类的同名方法  
self關鍵字  
指向當前作用域實例

    # inheritance
    class User
      attr_accessor :name, :age
      def initialize name, age
        @name, @age = name, age
      end
      def panels
        # ||= 操作符， 如果变量不存在 那么就赋值
        @panels ||= ["Profile", "Products"]
      end
      def to_s
        # self指向當前作用域實例
        "#{self.name} os #{self.age}"
      end
      # 定义方法的self代表类函数 (静态函数)
      def self.category
        "User"
      end
      # 一次性定义多个类方法