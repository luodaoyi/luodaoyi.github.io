---
title: "Android逆向-1 dalvik字节码"
categories: [ "Android" ]
tags: [ "安卓逆向" ]
draft: false
slug: "Android逆向-1 dalvik字节码-android逆向-1dalvik字节码"
date: "2020-03-12 09:28:49"
---



# 1 .dalvik字节码

## 1 dalvik寄存器:

  * 32位: 所有寄存器
  * 64位: 使用两个相邻的寄存器

## 2 寄存器的命名法:

  *  `v` : 局部变量寄存器 `v0-vn` 参数寄存器: `vn-vn+m`
  *  `p` : 参数寄存器 `p0-pn` 变量寄存器 `v0-vn`

> 第一种  
> [![][1]][2]
> 
> 第二种  
> [![][3]][4]

## 3 dex文件反汇编工具

`.java`编译成`.class` 再编译成 `<code>.dex`</code> 最后编译得到 smali文件

> .java -> .class -> .dex -> smali

  * `dx.jar` : `.class` 打包成`.dex`
    
    > dx &#8211;dex &#8211;output=Decrypt.dex com/yijinda/demo/Decrypt.class

  * `baksmali.jar`: `.dex`反编译成 `smali`文件
    
    > java -jar baksmali.jar -o smali_out/classes.dex

  * `smali.jar`: `smali` 打包成 `.dex`
    
    > java -jar smali.jar -o smali_out/classes.dex

## 4 dalvik字节码类型

> 基础类型

| Dalvik 类型 | java类型    |
| --------- | --------- |
| B         | byte      |
| C         | char      |
| S         | short     |
| I         | int       |
| `J`       | `long`    |
| F         | float     |
| D         | double    |
| `Z`       | `boolean` |
| V         | void      |
| `L`       | `java类类型` |
| `[`       | `数组类型`    |

> 字段


```java
//字段
Lpackage/name/ObjectName;->FieldName:Ljava/lang/String
//字段格式
类型 (包名类名 /路径);->字段名称:字段类型;
```


> 方法


```java
//方法
Lpackage/name/ObjectName;->MethodName(III)Z
(III)Z: 这部分信息表示的是方法的签名信息
代表的意思是  三个int参数 返回boolean 
```


## 练习:


```java
//分析字段：
//    Lcom/alipay/sdk/app/H5PayActivity;->b:Ljava/lang/String;
//    Lcom/auth/third/accountlink/ui/WebViewActivity;->a:Z
//    Lcom/alipay/sdk/authjs/a;->m:Lorg/json/JSONObject;
// 解答:
package   com.alipay.sdk.app
class H5PayActivity
{
    string b;
}

package com.auth.third.accountlink.ui
class WebViewActivity
{
   bool a;
}

import org.json;
package com.alipay.sdk.authjs
class a
{
    JSONObject m;
}

//分析方法：
//    Lcom/alipay/sdk/j/h;->b()Z
//    Landroid/content/Intent;->getExtras()Landroid/os/Bundle;
//    Lorg/cocos2dx/lua/LoadingAct;->setContentView(I)V
//解答
package com.alipay.sdk.j
class h
{
      public boolean b() {}
}

package android.content
class Intent
{
        public  android.os.Bundle getExtras(){}
}

package org.cocos2dx.lua
class LoadingAct
{
        public void setContentView(int int_1){}
}

```


 [1]: /uploads/2020/03/1584005165-第一种-300x182.png
 [2]: https://luodaoyi.com/?attachment_id=2063
 [3]: /uploads/2020/03/1584005164-第二种-300x168.png
 [4]: https://luodaoyi.com/?attachment_id=2062