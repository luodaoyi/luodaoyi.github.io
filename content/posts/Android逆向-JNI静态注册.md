---
title: "Android逆向 JNI静态注册"
categories: [ "Android" ]
tags: [ "JNI","Android逆向" ]
draft: false
slug: "Android逆向 JNI静态注册-android逆向jni静态注册"
date: "2020-04-24 09:06:05"
---



# Android逆向 JNI静态注册

## 1. 新建空白Android项目

打开 ADT 新建Android空白项目 全部默认下一步  
![file][1] 

![file][2] 

![file][3] 

![file][4] 

![file][5] 

![file][6] 

## 2. 新增jni代码

> 使用jni写的需要用native修饰 

![file][7] 

## 3. 生成头文件

首先在ADT中新建 jni文件夹

![file][8] 

右击src文件夹 选择 Properties 查看文件夹路径  
这里为 `C:\Users\asura\source\repos\Android_JNI\02_JNI_register\Jnidemo\src`

![file][9] 

打开命令行 到达指定的目录执行javah命令


```shell
javah -jni -d ../jni com.example.jnidemo.MainActivity
```


刷新ADT后发现jni路径下生成对应的头文件

![file][10] 

### 注意!

如果上述操作完全没错，但依然提示找不到xxx的类文件！需要先使用命令来进行切换


```shell
set classpath=C:\Users\asura\source\repos\Android_JNI\02_JNI_register\Jnidemo\src
```


## 4. 编写c++代码和ndk编译配置文件

在jni文件夹内新建文件

> com\_example\_jnidemo_MainActivity.cpp


```cpp
#include "com_example_jnidemo_MainActivity.h"

JNIEXPORT jstring JNICALL Java_com_example_jnidemo_MainActivity_Hello
  (JNIEnv * env, jobject obj)
{
    return env->NewStringUTF("Hello JNI");
}
```


> Android.mk


```conf
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_ARM_MODE := arm
LOCAL_MODULE    := hello                                    #模块名称
LOCAL_SRC_FILES := com_example_jnidemo_MainActivity.cpp     #源文件名
include $(BUILD_SHARED_LIBRARY)                             #编译为so库文件
```


> Application.mk


```conf
APP_ABI := x86 armeabi-v7a
```


![file][11] 

## 5. 编译ndk代码

命令行进入jni目录下执行编译命令


```shell
ndk-build
```


看到输出.so文件成功则说明编译成功

![file][12] 

## 6. java内加载so库和调用

回到java文件中 编写加载so代码的逻辑


```java
package com.example.jnidemo;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;
import android.widget.Toast;

public class MainActivity extends Activity {

    static {
        System.loadLibrary("hello"); //加载hello模块
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toast.makeText(this,MainActivity.this.Hello(), 1).show(); //调用jni内方法
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    private native String Hello();
}

```


## 7. 编译执行

![file][13] 

## 相关代码

[https://github.com/luodaoyi/Android\_JNI/tree/master/02\_JNI_register][14]

> 如果是用android studio 请看NCK大佬的文章

[安卓逆向4.Android Studio JNI静态注册(一个简单的JNI静态注册流程) &#8211; 凉游浅笔深画眉 &#8211; 博客园][15]

 [1]: /uploads/2020/04/image-1587717449509.png
 [2]: /uploads/2020/04/image-1587717471030.png
 [3]: /uploads/2020/04/image-1587717478228.png
 [4]: /uploads/2020/04/image-1587717487825.png
 [5]: /uploads/2020/04/image-1587717496972.png
 [6]: /uploads/2020/04/image-1587717518155.png
 [7]: /uploads/2020/04/image-1587717844865.png
 [8]: /uploads/2020/04/image-1587718110319.png
 [9]: /uploads/2020/04/image-1587717946024.png
 [10]: /uploads/2020/04/image-1587718161545.png
 [11]: /uploads/2020/04/image-1587718632859.png
 [12]: /uploads/2020/04/image-1587718784810.png
 [13]: /uploads/2020/04/image-1587719087153.png
 [14]: https://github.com/luodaoyi/Android_JNI/tree/master/02_JNI_register "https://github.com/luodaoyi/Android_JNI/tree/master/02_JNI_register"
 [15]: https://www.cnblogs.com/fuhua/p/12695436.html "安卓逆向4.Android Studio JNI静态注册(一个简单的JNI静态注册流程) - 凉游浅笔深画眉 - 博客园"