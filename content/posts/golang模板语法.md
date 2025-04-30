---
title: "golang模板语法"
categories: [ "其他" ]
tags: [ "develop" ]
draft: false
slug: "golang模板语法-golang模板语法"
date: "2017-03-12 06:32:48"
---



# 模板语法

## with关键字

    type u struct {
            Name string
            Age int
            Sex string
        }
        user:=&u{Name:"asd",Age:20,Sex:"mal"}
        data["user"]=user
        c.HTML(http.StatusOK, "index.html", data)

输出

    
        {{with .user}}
        {{.Name}};
        {{.Age}};
        {{.Sex}}
        {{end}}
    

## 循环打印数组

    nums := []int{1,2,3,4,5,6,7,8,9,0}
    data["nums"]=nums

输出

    
        {{range .nums}}
        {{.}}
        {{end}}
    

## 高级使用-模板变量

    data["abc"] = "helloword-abc"
        c.HTML(http.StatusOK, "index.html", data)

模板变量示例

    
        {{$tempabc := .abc}}
        {{$tempabc}}
    

## 处理简单数据-模板函数