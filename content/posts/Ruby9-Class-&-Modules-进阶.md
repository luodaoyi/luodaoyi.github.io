---
title: "Ruby9 Class & Modules 进阶"
categories: [ "ruby" ]
tags: [ "Ruby" ]
draft: false
slug: "Ruby9 Class & Modules 进阶-ruby9classmodules进阶"
date: "2018-02-18 06:52:49"
---



## Ruby的内部类结构

    Array.class # => Class
    Class.class # => Class

### superclass 查看父类

    Array.superclass # =>Object
    Object.superclass # =>BasicObject
    BasicObject.superclass # => nil

### ancestors 查看当前类的继承链

    Array.ancestors # => [Array, Enumerable, Object, Kernel, BasicObject]

### Method Finding 方法查找

    # class structure, method finding
    class User
      def panels
        @panels ||= ["Profile", "Products"]
      end
    end
    class Admin < User
    end
    puts Admin.ancestors
    admin = Admin.new
    p admin.panels
    # 从下往上查找 在admin中查找 找不到往上找User 然后Object 然后Kernel 然后 BasicObject

### Method Overwrite 方法覆盖

  1. class和module可以重新打开
  2. 方法可以重定义

    # 重新打开class
    class User
      def panels
        @panels ||= ["Profile", "Products"]
      end
    end
    class User
      def panels
        "overwrite"
      end
    end
    puts User.ancestors
    admin = User.new
    p admin.panels
    # 从下往上查找 在admin中查找 找不到往上找User 然后Object 然后Kernel 然后 BasicObject

    # overwrite and re-open
    class Array
      def to_hello_word
        "hello #{self.join(", ")}"
      end
    end
    a = %w[cat horse dog]
    puts a.to_hello_word

    # overwrite and re-open
    a = %w[cat horse dog]
    puts a.join(",")
    class Array
      def join
        "hello"
      end
    end
    puts "-" * 30
    puts a.join

## Module

    Array.ancestors # => [Array, Enumerable, Object, Kernel, BasicObject]
    Enumerable.class # => Module
    Module.class # => Class

    # module acts linke a class
    module Management
      def company_notifies
        "company_notifies from management"
      end
    end
    class User
      include Management
      def company_notifies
        puts super
        "company_notifies from user"
      end
    end
    p User.ancestors
    puts "-" * 30
    user = User.new
    puts user.company_notifies

    # module included sequence
    module Management
      def company_notifies
        "company_notifies from management"
      end
    end
    module Track
      def company_notifies
        "company_notifies from track"
      end
    end
    class User
      include Management
      include Track
      def company_notifies
        puts super
        "company_notifies from user"
      end
    end
    p User.ancestors
    puts "-" * 30
    user = User.new
    puts user.company_notifies

    # 1 module included in module
    # 2 module acts as class
    module Management
      def company_notifies
        "company_notifies from management"
      end
    end
    module Track
      include Management
      def company_notifies
        puts super
        "company_notifies from track"
      end
    end
    p Track.ancestors
    puts "-" * 30
    include Track
    puts company_notifies

    # module"s class method
    module Management
      def self.progress
        "progress"
      end
      # you need to include/extend/prepend to use this metod
      def company_notifies
        "company_notifies from management"
      end
    end
    puts Management.progress

### include vs prepend

  1. include 把模块注入当前类的继承链(祖先链) `后面`
  2. prepend 把模块注入当前累的继承链(祖先链) `前面`

    # module include
    # include
    module Management
      def company_notifies
        "company_notifies from management"
      end
    end
    class User
      prepend Management
      # include Management
      def company_notifies
        "company_notifies from user"
      end
    end
    p User.ancestors
    puts "-" * 30
    user = User.new
    puts user.company_notifies

## include和exten方法

当模块被include时会被执行，同事会传递当前作用于的self对象

    # included method
    module Management
      def self.included base
        puts "Management is being included into #{base}"
        base.include InstanceMethods
        base.extend ClasMethods
        module InstalceMethods
          def company_notifies
            "company_notifies from management"
          end
        end
        module Classethods
          def progress
            "progress"
          end
        end
      end
    end
    class User
      include Management
    end
    puts "-" * 30
    user = User.new
    puts user.company_notifies
    puts "-" * 30
    puts User.progress